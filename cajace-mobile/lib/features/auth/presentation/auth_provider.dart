import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_events.dart';
import '../../../core/utils/secure_storage.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

final loginPasswordVisibilityProvider = StateProvider<bool>((ref) => true);

enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  const AuthState.loading({this.user})
      : status = AuthStatus.loading,
        errorMessage = null;

  const AuthState.authenticated(UserModel this.user)
      : status = AuthStatus.authenticated,
        errorMessage = null;

  const AuthState.error(String this.errorMessage)
      : status = AuthStatus.error,
        user = null;

  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  bool get isAuthenticated => user != null;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
  notifier.restoreSession();
  return notifier;
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository, this._storage)
      : super(const AuthState.initial()) {
    _unauthorizedSubscription = SessionEvents.unauthorizedStream.listen((_) {
      state = const AuthState.initial();
    });
  }

  final AuthRepository _repository;
  final AppSecureStorage _storage;
  late final StreamSubscription<void> _unauthorizedSubscription;

  Future<void> restoreSession() async {
    if (state.status == AuthStatus.loading) {
      return;
    }

    state = AuthState.loading(user: state.user);
    try {
      final cachedUser = await _storage.readUser();
      if (cachedUser == null) {
        state = const AuthState.initial();
        return;
      }

      final user = await _repository.getProfile();
      state = AuthState.authenticated(user);
    } catch (_) {
      try {
        await _storage.clearSession();
      } catch (_) {}
      state = const AuthState.initial();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(email, password);
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState.error(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    state = AuthState.loading(user: state.user);
    try {
      await _repository.logout();
    } catch (_) {}
    state = const AuthState.initial();
  }

  Future<void> logoutAll() async {
    state = AuthState.loading(user: state.user);
    try {
      await _repository.logoutAll();
    } catch (error) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      return;
    }
    state = const AuthState.initial();
  }

  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) {
      return;
    }

    state = AuthState.loading(user: state.user);
    try {
      final user = await _repository.getProfile();
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    if (state.user != null) {
      state = AuthState.authenticated(state.user!);
      return;
    }

    state = const AuthState.initial();
  }

  void reset() {
    state = const AuthState.initial();
  }

  @override
  void dispose() {
    _unauthorizedSubscription.cancel();
    super.dispose();
  }
}
