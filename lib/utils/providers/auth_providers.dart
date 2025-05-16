import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth state provider
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});

// Auth state class
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? authToken;
  final String? userRole;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.authToken,
    this.userRole,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? authToken,
    String? userRole,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      authToken: authToken ?? this.authToken,
      userRole: userRole ?? this.userRole,
    );
  }
}

// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final role = prefs.getString('userRole');

      if (token != null) {
        state = state.copyWith(
          isAuthenticated: true,
          authToken: token,
          userRole: role,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setAuthenticated(bool isAuthenticated, String role) {
    state = state.copyWith(isAuthenticated: isAuthenticated);
  }

  void setUserRole(String role) {
    state = state.copyWith(userRole: role);
  }

  void setAuthToken(String token) {
    state = state.copyWith(authToken: token);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');

      state = AuthState();
    } catch (e) {
      // Handle logout error
    }
  }
}
