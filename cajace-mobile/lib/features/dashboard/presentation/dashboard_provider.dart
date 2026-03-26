import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(apiClient: ref.watch(apiClientProvider));
});

final profileProvider = FutureProvider<UsuarioProfile>((ref) async {
  return ref.read(dashboardRepositoryProvider).getProfile();
});

final unreadCountProvider = StateProvider<int>((ref) => 0);

final notificationsProvider = FutureProvider<List<NotificacionItem>>((
  ref,
) async {
  return ref.read(dashboardRepositoryProvider).getNotifications();
});

final wsProvider = StateNotifierProvider<WsNotifier, WsState>((ref) {
  return WsNotifier(ref);
});

class DashboardRepository {
  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UsuarioProfile> getProfile() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(ApiEndpoints.me);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'];
        if (nestedData is Map<String, dynamic> &&
            nestedData['usuario'] is Map<String, dynamic>) {
          return UsuarioProfile.fromJson(
            nestedData['usuario'] as Map<String, dynamic>,
          );
        }
      }

      throw Exception('Respuesta de perfil invalida.');
    } catch (error) {
      throw Exception(
        _mapError(error, fallback: 'No se pudo cargar el perfil.'),
      );
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.notificationsUnread,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return int.tryParse((data['total'] ?? 0).toString()) ?? 0;
      }

      return 0;
    } catch (error) {
      throw Exception(
        _mapError(error, fallback: 'No se pudo cargar el contador.'),
      );
    }
  }

  Future<List<NotificacionItem>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.notificationsMine,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map(
              (item) =>
                  NotificacionItem.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      return const <NotificacionItem>[];
    } catch (error) {
      throw Exception(
        _mapError(error, fallback: 'No se pudieron cargar las notificaciones.'),
      );
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _apiClient.dio.patch<dynamic>(ApiEndpoints.notificationMarkRead(id));
    } catch (error) {
      throw Exception(
        _mapError(error, fallback: 'No se pudo actualizar la notificacion.'),
      );
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _apiClient.dio.patch<dynamic>(ApiEndpoints.notificationsMarkAll);
    } catch (error) {
      throw Exception(
        _mapError(error, fallback: 'No se pudieron actualizar las alertas.'),
      );
    }
  }

  String _mapError(Object error, {required String fallback}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final dynamic message = data['message'] ?? data['error'];
        if (message is List && message.isNotEmpty) {
          return message.first.toString();
        }
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }

      if (error.message != null && error.message!.isNotEmpty) {
        return error.message!;
      }
    }

    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isEmpty ? fallback : message;
  }
}

enum WsConnectionStatus { connecting, connected, reconnecting, disconnected }

class WsState {
  const WsState({
    required this.status,
    this.errorMessage,
  });

  const WsState.connecting()
      : status = WsConnectionStatus.connecting,
        errorMessage = null;

  final WsConnectionStatus status;
  final String? errorMessage;
}

class WsNotifier extends StateNotifier<WsState> {
  WsNotifier(this._ref) : super(const WsState.connecting()) {
    unawaited(_initialize());
  }

  final Ref _ref;
  io.Socket? _socket;
  Timer? _reconnectTimer;
  bool _disposed = false;

  Future<void> _initialize() async {
    await _loadUnreadCount();
    await connect();
  }

  Future<void> connect() async {
    if (_disposed) {
      return;
    }

    state = WsState(
      status: _socket == null
          ? WsConnectionStatus.connecting
          : WsConnectionStatus.reconnecting,
    );

    _reconnectTimer?.cancel();
    _disposeSocket();

    try {
      final apiClient = _ref.read(apiClientProvider);
      final cookieHeader = await apiClient.buildCookieHeader(
        Uri.parse(AppConstants.socketBaseUrl),
      );

      final options = io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .enableForceNew();

      if (cookieHeader != null && cookieHeader.isNotEmpty) {
        options.setExtraHeaders(<String, dynamic>{'Cookie': cookieHeader});
      }

      final socket = io.io(AppConstants.socketBaseUrl, options.build());
      _socket = socket;

      socket.onConnect((_) {
        state = const WsState(status: WsConnectionStatus.connected);
      });

      socket.onDisconnect((_) {
        if (_disposed) {
          return;
        }

        state = const WsState(status: WsConnectionStatus.disconnected);
        _scheduleReconnect();
      });

      socket.onConnectError((dynamic error) {
        if (_disposed) {
          return;
        }

        state = WsState(
          status: WsConnectionStatus.reconnecting,
          errorMessage: error.toString(),
        );
        _scheduleReconnect();
      });

      socket.onError((dynamic error) {
        if (_disposed) {
          return;
        }

        state = WsState(
          status: WsConnectionStatus.reconnecting,
          errorMessage: error.toString(),
        );
      });

      socket.on('notification', (dynamic _) {
        final notifier = _ref.read(unreadCountProvider.notifier);
        notifier.state = notifier.state + 1;
        _ref.invalidate(notificationsProvider);
      });

      socket.on('role_permissions_updated', (dynamic _) {
        _ref.invalidate(profileProvider);
      });

      socket.on('logout_session', (dynamic _) {
        unawaited(_handleRemoteLogout());
      });

      socket.connect();
    } catch (error) {
      state = WsState(
        status: WsConnectionStatus.reconnecting,
        errorMessage: error.toString(),
      );
      _scheduleReconnect();
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final total = await _ref.read(dashboardRepositoryProvider).getUnreadCount();
      _ref.read(unreadCountProvider.notifier).state = total;
    } catch (_) {}
  }

  Future<void> _handleRemoteLogout() async {
    try {
      await _ref.read(authProvider.notifier).logout();
    } catch (_) {}

    AppNavigator.goToLogin();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer?.isActive == true) {
      return;
    }

    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      if (_disposed) {
        return;
      }

      unawaited(connect());
    });
  }

  void _disposeSocket() {
    _socket?.dispose();
    _socket = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _disposeSocket();
    super.dispose();
  }
}
