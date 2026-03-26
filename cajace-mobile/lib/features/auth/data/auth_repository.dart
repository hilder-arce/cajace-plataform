import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/secure_storage.dart';
import '../domain/user_model.dart';

final secureStorageProvider = Provider<AppSecureStorage>((ref) {
  return AppSecureStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(secureStorage: ref.watch(secureStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required AppSecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  final ApiClient _apiClient;
  final AppSecureStorage _secureStorage;

  Future<UserModel> login(String email, String password) async {
    try {
      await _apiClient.dio.post<dynamic>(
        ApiEndpoints.login,
        data: <String, dynamic>{'email': email, 'password': password},
      );
      return await getProfile();
    } catch (error) {
      throw Exception(_mapError(error, fallback: 'No se pudo iniciar sesion.'));
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post<dynamic>(ApiEndpoints.logout);
      await _apiClient.clearCookies();
      await _secureStorage.clearSession();
    } catch (error) {
      await _apiClient.clearCookies();
      await _secureStorage.clearSession();
      throw Exception(
          _mapError(error, fallback: 'No se pudo cerrar la sesion.'));
    }
  }

  Future<void> logoutAll() async {
    try {
      await _apiClient.dio.post<dynamic>(ApiEndpoints.logoutAll);
      await _apiClient.clearCookies();
      await _secureStorage.clearSession();
    } catch (error) {
      await _apiClient.clearCookies();
      await _secureStorage.clearSession();
      throw Exception(
        _mapError(error, fallback: 'No se pudieron cerrar todas las sesiones.'),
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post<dynamic>(
        ApiEndpoints.forgotPassword,
        data: <String, dynamic>{'email': email},
      );
    } catch (error) {
      throw Exception(
        _mapError(error, fallback: 'No se pudo iniciar la recuperacion.'),
      );
    }
  }

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      await _apiClient.dio.post<dynamic>(
        ApiEndpoints.verifyCode,
        data: <String, dynamic>{'email': email, 'codigo': code},
      );
    } catch (error) {
      throw Exception(
        _mapError(error, fallback: 'No se pudo validar el codigo.'),
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      await _apiClient.dio.post<dynamic>(
        ApiEndpoints.resetPassword,
        data: <String, dynamic>{
          'email': email,
          'codigo': code,
          'password': password,
        },
      );
    } catch (error) {
      throw Exception(
        _mapError(error, fallback: 'No se pudo restablecer la contrasena.'),
      );
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(ApiEndpoints.me);
      final payload = _extractUserPayload(response.data);
      final user = UserModel.fromJson(payload);
      await _secureStorage.saveUser(user);
      return user;
    } catch (error) {
      throw Exception(
          _mapError(error, fallback: 'No se pudo cargar el perfil.'));
    }
  }

  Map<String, dynamic> _extractUserPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic> &&
          nestedData['usuario'] is Map<String, dynamic>) {
        return nestedData['usuario'] as Map<String, dynamic>;
      }

      if (data['user'] is Map<String, dynamic>) {
        return data['user'] as Map<String, dynamic>;
      }

      if (data['usuario'] is Map<String, dynamic>) {
        return data['usuario'] as Map<String, dynamic>;
      }

      return data;
    }

    return const <String, dynamic>{};
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
    if (message.isEmpty) {
      return fallback;
    }

    return message;
  }
}
