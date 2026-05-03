import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier(ref.read(authServiceProvider));
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AuthState.initial());

  Future<void> login(String emailOrPhone, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _authService.login(emailOrPhone, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register(UserProfile userProfile, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _authService.register(userProfile, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void logout() {
    state = const AuthState.initial();
  }
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserProfile? user;
  final String? error;

  // ✅ FIX: Initialize ALL final fields here
  const AuthState._({
    required this.isLoading,
    required this.isAuthenticated,
    this.user,
    this.error,
  });

  const AuthState.initial()
    : this._(isLoading: false, isAuthenticated: false, user: null, error: null);

  const AuthState.loading()
    : this._(isLoading: true, isAuthenticated: false, user: null, error: null);

  const AuthState.authenticated(UserProfile user)
    : this._(isLoading: false, isAuthenticated: true, user: user, error: null);

  const AuthState.error(String error)
    : this._(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: error,
      );
}
