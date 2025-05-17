import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Token state provider
final tokenStateProvider =
    StateNotifierProvider<TokenStateNotifier, TokenState>((ref) {
  return TokenStateNotifier();
});

// Token state class
class TokenState {
  final String? accessToken;
  final String? refreshToken;
  final DateTime? accessTokenExpiryTime;
  final bool isLoading;

  TokenState({
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiryTime,
    this.isLoading = false,
  });

  TokenState copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiryTime,
    bool? isLoading,
  }) {
    return TokenState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiryTime:
          accessTokenExpiryTime ?? this.accessTokenExpiryTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAccessTokenExpired {
    if (accessTokenExpiryTime == null) return true;
    return DateTime.now()
        .isAfter(accessTokenExpiryTime!.subtract(const Duration(minutes: 5)));
  }
}

// Token state notifier
class TokenStateNotifier extends StateNotifier<TokenState> {
  TokenStateNotifier() : super(TokenState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final refreshToken = prefs.getString('refreshToken');
      final expiryTimeStr = prefs.getString('accessTokenExpiryTime');

      DateTime? expiryTime;
      if (expiryTimeStr != null) {
        expiryTime = DateTime.parse(expiryTimeStr);
      }

      state = state.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiryTime: expiryTime,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiryTime,
  }) async {
    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiryTime: expiryTime,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString(
        'accessTokenExpiryTime', expiryTime.toIso8601String());
  }

  void clearTokens() async {
    state = TokenState();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('accessTokenExpiryTime');
  }
}

// Existing auth state provider (keep this unchanged)
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});

// Auth state class (keep this unchanged)
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

// Auth state notifier (update to include token management)
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
      final refreshToken = prefs.getString('refreshToken');

      if (refreshToken != null) {
        // We have a refresh token, which might mean the user is authenticated
        // The actual token validation will happen when they access protected routes
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
    state = state.copyWith(isAuthenticated: isAuthenticated, userRole: role);
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
      await prefs.remove('refreshToken');
      await prefs.remove('accessTokenExpiryTime');

      state = AuthState();
    } catch (e) {
      // Handle logout error
    }
  }
}

// Extension methods for AuthStateNotifier to support GoRouter
extension AuthStateNotifierExtension on AuthStateNotifier {
  // Stream controller for GoRouter refresh stream
  static final StreamController<AuthState> _controller =
      StreamController<AuthState>.broadcast();

  // Get the stream for GoRouter to listen to
  Stream<AuthState> get stream => _controller.stream;

  // Update auth state and notify listeners (used by GoRouter)
  void updateAuthState({
    required bool isAuthenticated,
    String? userRole,
  }) {
    // Update state
    state = state.copyWith(
      isAuthenticated: isAuthenticated,
      userRole: userRole,
    );

    // Notify GoRouter about the change
    _controller.add(state);
  }

  // Clean up resources
  @override
  void dispose() {
    _controller.close();
  }
}
