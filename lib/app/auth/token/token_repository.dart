// Enhanced TokenRepository with better persistence and refresh logic
import 'dart:async';
import 'dart:convert';
import 'package:CuraDocs/app/auth/api_const.dart';
import 'package:CuraDocs/app/auth/token/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/utils/snackbar.dart';

final tokenRepositoryProvider = Provider((ref) => TokenRepository());

class TokenRepository {
  // Cache access token expiry time to avoid unnecessary refreshes
  DateTime? _accessTokenExpiryTime;

  // Store tokens in memory for quick access
  String? _accessToken;
  String? _refreshToken;
  String? _userRole;

  // Prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  // Check if access token is expired or about to expire (buffer of 2 minutes)
  bool get isAccessTokenExpired {
    if (_accessTokenExpiryTime == null) return true;
    return DateTime.now()
        .isAfter(_accessTokenExpiryTime!.subtract(const Duration(minutes: 2)));
  }

  // Check if access token exists and is valid
  bool get hasValidAccessToken {
    return _accessToken != null && !isAccessTokenExpired;
  }

  // Initialize tokens from storage on app start
  Future<void> initializeTokens() async {
    try {
      _accessToken = await SecureStorageService.getAccessToken();
      _refreshToken = await SecureStorageService.getRefreshToken();
      _accessTokenExpiryTime =
          await SecureStorageService.getAccessTokenExpiry();
      _userRole = await SecureStorageService.getUserRole();

      debugPrint('Tokens initialized from storage');
      debugPrint('Access token exists: ${_accessToken != null}');
      debugPrint('Refresh token exists: ${_refreshToken != null}');
      debugPrint('Token expired: $isAccessTokenExpired');
      debugPrint('User role: $_userRole');
    } catch (e) {
      debugPrint('Error initializing tokens: $e');
    }
  }

  // Get tokens with automatic refresh if needed
  Future<TokenPair?> getTokens() async {
    // Initialize if not done already
    if (_accessToken == null && _refreshToken == null) {
      await initializeTokens();
    }

    // If we have a valid access token, return it
    if (hasValidAccessToken) {
      return TokenPair(
        accessToken: _accessToken!,
        refreshToken: _refreshToken!,
        expiryTime: _accessTokenExpiryTime!,
      );
    }

    // Try to refresh if we have a refresh token
    if (_refreshToken != null) {
      final refreshed = await refreshAccessToken();
      if (refreshed && hasValidAccessToken) {
        return TokenPair(
          accessToken: _accessToken!,
          refreshToken: _refreshToken!,
          expiryTime: _accessTokenExpiryTime!,
        );
      }
    }

    return null;
  }

  // Get the stored access token with automatic refresh
  Future<String?> getAccessToken() async {
    final tokens = await getTokens();
    return tokens?.accessToken;
  }

  // Save tokens after login or refresh
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required Duration accessTokenDuration,
    String? userRole,
  }) async {
    try {
      // Calculate expiry time
      final expiryTime = DateTime.now().add(accessTokenDuration);

      // Save tokens to secure storage
      await SecureStorageService.storeAccessToken(accessToken);
      await SecureStorageService.storeRefreshToken(refreshToken);
      await SecureStorageService.storeAccessTokenExpiry(expiryTime);

      if (userRole != null) {
        await SecureStorageService.storeUserRole(userRole);
        _userRole = userRole;
      }

      // Update in-memory values
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _accessTokenExpiryTime = expiryTime;

      debugPrint('Tokens saved successfully');
      debugPrint('Access token expires at: $expiryTime');
    } catch (e) {
      debugPrint('Error saving tokens: $e');
      rethrow;
    }
  }

  // Get the stored refresh token
  Future<String?> getRefreshToken() async {
    if (_refreshToken != null) {
      return _refreshToken;
    }

    // Load from storage if not in memory
    await initializeTokens();
    return _refreshToken;
  }

  // Get user role
  Future<String?> getUserRole() async {
    if (_userRole != null) {
      return _userRole;
    }

    _userRole = await SecureStorageService.getUserRole();
    return _userRole;
  }

  // Clear tokens on logout
  Future<void> clearTokens() async {
    try {
      // Clear from secure storage
      await SecureStorageService.clearAll();

      // Clear in-memory values
      _accessToken = null;
      _refreshToken = null;
      _accessTokenExpiryTime = null;
      _userRole = null;

      debugPrint('All tokens cleared');
    } catch (e) {
      debugPrint('Error clearing tokens: $e');
    }
  }

  // Refresh the access token using the refresh token
  Future<bool> refreshAccessToken({BuildContext? context}) async {
    // If already refreshing, wait for completion
    if (_isRefreshing && _refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    // Start refresh process
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      debugPrint('Attempting to refresh access token');

      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        debugPrint('No refresh token available');
        _completeRefresh(false);
        return false;
      }

      // Determine the correct endpoint based on user role
      final userRole = await getUserRole();
      final refreshTokenUrl =
          userRole == 'Doctor' ? refresh_token_doc : refresh_token_patient;

      try {
        final response = await http.post(
          Uri.parse(refreshTokenUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $refreshToken',
          },
        ).timeout(const Duration(seconds: 15));

        debugPrint('Refresh token response: ${response.statusCode}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData['access_token'] != null) {
            await saveTokens(
              accessToken: responseData['access_token'],
              refreshToken: responseData['refresh_token'] ?? refreshToken,
              accessTokenDuration: Duration(
                seconds: responseData['expires_in'] ?? 3600, // Default 1 hour
              ),
              userRole: responseData['user_role'] ?? userRole,
            );

            debugPrint('Token refreshed successfully');
            _completeRefresh(true);
            return true;
          } else {
            debugPrint('Access token not found in response');
            _completeRefresh(false);
            return false;
          }
        } else {
          _handleRefreshTokenError(response, context);
          _completeRefresh(false);
          return false;
        }
      } catch (e) {
        debugPrint('HTTP error during token refresh: $e');
        if (context != null && context.mounted) {
          showSnackBar(
            context: context,
            message: 'Connection error. Please check your network.',
          );
        }
        _completeRefresh(false);
        return false;
      }
    } catch (e) {
      debugPrint('Unexpected error refreshing token: $e');
      _completeRefresh(false);
      return false;
    }
  }

  // Complete the refresh process
  void _completeRefresh(bool success) {
    _isRefreshing = false;
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete(success);
    }
    _refreshCompleter = null;
  }

  // Handle refresh token errors
  void _handleRefreshTokenError(
      http.Response response, BuildContext? context) async {
    String errorMessage = 'Session expired. Please log in again.';
    bool requiresLogout = true;

    try {
      final errorData = jsonDecode(response.body);
      final errorDetail =
          errorData['error'] ?? errorData['message'] ?? 'Unknown error';

      switch (response.statusCode) {
        case 401:
          switch (errorDetail.toLowerCase()) {
            case 'refresh token expired':
            case 'invalid refresh token':
            case 'refresh token required':
              errorMessage = 'Your session has expired. Please log in again.';
              break;
            case 'invalid device fingerprint':
              errorMessage =
                  'Security alert: Session accessed from a different device.';
              break;
            default:
              errorMessage = 'Authentication error. Please log in again.';
          }
          break;
        case 403:
          errorMessage = 'Access denied. Please log in again.';
          break;
        case 500:
          errorMessage = 'Server error. Please try again later.';
          requiresLogout = false; // Don't logout for server errors
          break;
        default:
          errorMessage = 'Authentication error. Please log in again.';
      }

      debugPrint(
          'Refresh token error: $errorDetail (Status: ${response.statusCode})');
    } catch (e) {
      debugPrint('Error parsing refresh token error response: $e');
    }

    // Clear tokens if required
    if (requiresLogout) {
      await clearTokens();
    }

    // Show error message if context is provided
    if (context != null && context.mounted && requiresLogout) {
      showSnackBar(context: context, message: errorMessage);
    }
  }

  // Check if user has valid authentication
  Future<bool> isAuthenticated() async {
    final tokens = await getTokens();
    return tokens != null;
  }

  // Force refresh token (useful for app resume)
  Future<bool> forceRefreshToken({BuildContext? context}) async {
    if (_refreshToken == null) {
      await initializeTokens();
    }

    if (_refreshToken != null) {
      return await refreshAccessToken(context: context);
    }

    return false;
  }
}

// Token pair class for better organization
class TokenPair {
  final String accessToken;
  final String refreshToken;
  final DateTime expiryTime;

  TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiryTime,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  bool get isNearExpiry =>
      DateTime.now().isAfter(expiryTime.subtract(const Duration(minutes: 5)));
}

// Enhanced SecureStorageService with role storage
extension SecureStorageServiceExtension on SecureStorageService {
  static const String _userRoleKey = 'user_role';

  static Future<void> storeUserRole(String role) async {
    await SecureStorageService.storage.write(key: _userRoleKey, value: role);
  }

  static Future<String?> getUserRole() async {
    return await SecureStorageService.storage.read(key: _userRoleKey);
  }
}
