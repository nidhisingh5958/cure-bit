import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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

  bool get hasValidTokens {
    return accessToken != null && refreshToken != null && !isAccessTokenExpired;
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

      debugPrint('Token state initialized from storage');
      debugPrint('Has access token: ${accessToken != null}');
      debugPrint('Has refresh token: ${refreshToken != null}');
      debugPrint('Token expired: ${state.isAccessTokenExpired}');
    } catch (e) {
      debugPrint('Error initializing token state: $e');
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

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);
      await prefs.setString(
          'accessTokenExpiryTime', expiryTime.toIso8601String());

      debugPrint('Tokens saved to storage successfully');
    } catch (e) {
      debugPrint('Error saving tokens to storage: $e');
    }
  }

  void clearTokens() async {
    state = TokenState();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('accessTokenExpiryTime');

      debugPrint('Tokens cleared from storage');
    } catch (e) {
      debugPrint('Error clearing tokens from storage: $e');
    }
  }
}

// Enhanced auth state provider with better persistence
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});

// Auth state class (enhanced with more detailed state)
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? authToken;
  final String? userRole;
  final DateTime? lastAuthCheck;
  final bool isInitialized;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.authToken,
    this.userRole,
    this.lastAuthCheck,
    this.isInitialized = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? authToken,
    String? userRole,
    DateTime? lastAuthCheck,
    bool? isInitialized,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      authToken: authToken ?? this.authToken,
      userRole: userRole ?? this.userRole,
      lastAuthCheck: lastAuthCheck ?? this.lastAuthCheck,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get shouldRefreshAuth {
    if (lastAuthCheck == null) return true;
    return DateTime.now().difference(lastAuthCheck!).inMinutes > 5;
  }
}

// Enhanced auth state notifier with better initialization
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState()) {
    _initialize();
  }

  // Stream controller for GoRouter refresh notifications
  static final StreamController<AuthState> _streamController =
      StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get stream => _streamController.stream;

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      debugPrint('Initializing auth state from storage...');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final role = prefs.getString('userRole');
      final refreshToken = prefs.getString('refreshToken');
      final lastAuthCheckStr = prefs.getString('lastAuthCheck');

      DateTime? lastAuthCheck;
      if (lastAuthCheckStr != null) {
        lastAuthCheck = DateTime.parse(lastAuthCheckStr);
      }

      // Check if we have valid authentication data
      bool isAuthenticated = false;
      if (refreshToken != null && role != null) {
        // We have a refresh token and role, which indicates the user was authenticated
        isAuthenticated = true;
        debugPrint('Found valid auth data in storage');
        debugPrint('User role: $role');
        debugPrint('Has refresh token: ${refreshToken.isNotEmpty}');
        debugPrint('Last auth check: $lastAuthCheck');
      } else {
        debugPrint('No valid auth data found in storage');
      }

      state = state.copyWith(
        isAuthenticated: isAuthenticated,
        authToken: token,
        userRole: role,
        lastAuthCheck: lastAuthCheck,
        isLoading: false,
        isInitialized: true,
      );

      // Notify router about initial auth state
      _notifyRouterOfAuthChange();

      debugPrint('Auth state initialization complete');
      debugPrint('Is authenticated: $isAuthenticated');
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
    }
  }

  void setAuthenticated(bool isAuthenticated, String role) {
    debugPrint('Setting authentication state: $isAuthenticated, role: $role');

    state = state.copyWith(
      isAuthenticated: isAuthenticated,
      userRole: role,
      lastAuthCheck: DateTime.now(),
    );

    _persistAuthState();
    _notifyRouterOfAuthChange();
  }

  void setUserRole(String role) {
    debugPrint('Setting user role: $role');
    state = state.copyWith(userRole: role);
    _persistAuthState();
  }

  void setAuthToken(String token) {
    debugPrint('Setting auth token');
    state = state.copyWith(
      authToken: token,
      lastAuthCheck: DateTime.now(),
    );
    _persistAuthState();
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  Future<void> logout() async {
    debugPrint('Logging out user - clearing all auth state');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('refreshToken');
      await prefs.remove('accessTokenExpiryTime');
      await prefs.remove('userRole');
      await prefs.remove('lastAuthCheck');
      await prefs.remove('user'); // Clear user data as well

      state = AuthState(isInitialized: true);

      _notifyRouterOfAuthChange();
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Even if there's an error, clear the in-memory state
      state = AuthState(isInitialized: true);
      _notifyRouterOfAuthChange();
    }
  }

  // Persist auth state to storage
  Future<void> _persistAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (state.authToken != null) {
        await prefs.setString('authToken', state.authToken!);
      }

      if (state.userRole != null) {
        await prefs.setString('userRole', state.userRole!);
      }

      if (state.lastAuthCheck != null) {
        await prefs.setString(
            'lastAuthCheck', state.lastAuthCheck!.toIso8601String());
      }

      debugPrint('Auth state persisted to storage');
    } catch (e) {
      debugPrint('Error persisting auth state: $e');
    }
  }

  // Notify router of authentication changes
  void _notifyRouterOfAuthChange() {
    if (!_streamController.isClosed) {
      _streamController.add(state);
      debugPrint('Router notified of auth state change');
    }
  }

  // Update auth state and notify router (used by GoRouter)
  void updateAuthState({
    required bool isAuthenticated,
    String? userRole,
  }) {
    debugPrint('Updating auth state and notifying router');

    state = state.copyWith(
      isAuthenticated: isAuthenticated,
      userRole: userRole,
      lastAuthCheck: DateTime.now(),
    );

    _persistAuthState();
    _notifyRouterOfAuthChange();
  }

  // Refresh authentication check timestamp
  void refreshAuthCheck() {
    state = state.copyWith(lastAuthCheck: DateTime.now());
    _persistAuthState();
  }

  // Check if authentication state needs refreshing
  bool needsAuthRefresh() {
    return state.shouldRefreshAuth;
  }

  @override
  void dispose() {
    if (!_streamController.isClosed) {
      _streamController.close();
    }
    super.dispose();
  }
}

// Alternative auth state notifier provider for compatibility
final authStateNotifierProvider = authStateProvider;

// Provider to check if auth is initialized (useful for splash screens)
final authInitializedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isInitialized;
});

// Provider to get current user role
final currentUserRoleProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.userRole;
});

// Provider to check if user is doctor
final isDoctorProvider = Provider<bool>((ref) {
  final userRole = ref.watch(currentUserRoleProvider);
  return userRole == 'Doctor';
});

// Provider to check if tokens need refresh
final needsTokenRefreshProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.shouldRefreshAuth;
});
