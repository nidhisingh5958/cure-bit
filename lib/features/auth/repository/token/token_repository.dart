// TokenRepository: Handles all token storage, retrieval, and refresh logic.
import 'dart:async';
import 'dart:convert';
import 'package:CuraDocs/features/auth/repository/api_const.dart';
import 'package:CuraDocs/features/auth/repository/token/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/utils/snackbar.dart';

final String refreshTokenUrl =
    Role == 'Doctor' ? refresh_token_doc : refresh_token_patient;

mixin Role {
  static String? userRole;
}

final tokenRepositoryProvider = Provider((ref) => TokenRepository());

class TokenRepository {
  // Cache access token expiry time to avoid unnecessary refreshes
  DateTime? _accessTokenExpiryTime;

  // Store tokens in memory for quick access
  String? _accessToken;
  String? _refreshToken;

  // Add to TokenRepository class
  bool _isRefreshing = false;

  // Check if access token is expired or about to expire (buffer of 1 minutes)
  bool get isAccessTokenExpired {
    if (_accessTokenExpiryTime == null) return true;
    return DateTime.now()
        .isAfter(_accessTokenExpiryTime!.subtract(const Duration(minutes: 1)));
  }

  // Get the stored access token
  Future<String?> getAccessToken() async {
    if (_accessToken != null && !isAccessTokenExpired) {
      return _accessToken;
    }

    // Try to refresh the token if we have a refresh token
    final refreshToken = await getRefreshToken();
    if (refreshToken != null) {
      final result = await refreshAccessToken();
      if (result) {
        return _accessToken;
      }
    }

    return null;
  }

  // Save tokens after login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required Duration accessTokenDuration,
  }) async {
    // Calculate expiry time
    final expiryTime = DateTime.now().add(accessTokenDuration);

    // Save tokens to secure storage
    await SecureStorageService.storeAccessToken(accessToken);
    await SecureStorageService.storeRefreshToken(refreshToken);
    await SecureStorageService.storeAccessTokenExpiry(expiryTime);

    // Update in-memory values
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _accessTokenExpiryTime = expiryTime;
  }

  // Get the stored refresh token
  Future<String?> getRefreshToken() async {
    if (_refreshToken != null) {
      return _refreshToken;
    }

    // Load refresh token from secure storage
    _refreshToken = await SecureStorageService.getRefreshToken();

    // Also load access token and expiry time if not loaded yet
    if (_accessToken == null) {
      _accessToken = await SecureStorageService.getAccessToken();
      _accessTokenExpiryTime =
          await SecureStorageService.getAccessTokenExpiry();
    }

    return _refreshToken;
  }

  // Clear tokens on logout
  Future<void> clearTokens() async {
    // Clear from secure storage
    await SecureStorageService.clearAll();

    // Clear in-memory values
    _accessToken = null;
    _refreshToken = null;
    _accessTokenExpiryTime = null;
  }

  // Refresh the access token using the refresh token
  Future<bool> refreshAccessToken({BuildContext? context}) async {
    if (_isRefreshing) {
      // Wait for ongoing refresh to complete with timeout
      int attempts = 0;
      while (_isRefreshing && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      return _accessToken != null && !isAccessTokenExpired;
    }

    _isRefreshing = true;
    try {
      debugPrint('Attempting to refresh access token');

      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        debugPrint('No refresh token available');
        return false;
      }

      try {
        final response = await http.post(
          Uri.parse(refreshTokenUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $refreshToken',
          },
        ).timeout(const Duration(seconds: 10)); // Add timeout

        debugPrint('Refresh token response: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode == 200) {
          // Parse the new tokens
          final responseData = jsonDecode(response.body);

          // Save the new tokens
          if (responseData['access_token'] != null) {
            await saveTokens(
              accessToken: responseData['access_token'],
              refreshToken: responseData['refresh_token'] ?? refreshToken,
              accessTokenDuration: const Duration(hours: 1),
            );
            debugPrint('Token refreshed successfully');

            // Force update of Role.userRole if appropriate
            if (responseData['user_role'] != null) {
              Role.userRole = responseData['user_role'];
              debugPrint('Updated user role to: ${Role.userRole}');
            }

            return true;
          }
          debugPrint('Access token not found in response');
          return false;
        } else {
          // Handle different error cases
          _handleRefreshTokenError(response, context);
          return false;
        }
      } catch (e) {
        debugPrint('Error during HTTP request for token refresh: $e');
        if (context != null && context.mounted) {
          showSnackBar(
            context: context,
            message: 'Connection error. Please check your network.',
          );
        }
        return false;
      }
    } catch (e) {
      debugPrint('Unexpected error refreshing token: $e');
      if (context != null && context.mounted) {
        showSnackBar(
          context: context,
          message: 'Authentication error. Please log in again.',
        );
      }
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // Handle different refresh token error responses
  void _handleRefreshTokenError(
      http.Response response, BuildContext? context) async {
    String errorMessage = 'Session expired. Please log in again.';
    bool requiresLogout = true;

    try {
      final errorData = jsonDecode(response.body);
      final errorDetail =
          errorData['error'] ?? errorData['message'] ?? 'Unknown error';

      switch (errorDetail) {
        case 'Refresh token required':
          errorMessage = 'Authentication error. Please log in again.';
          break;
        case 'Refresh token expired':
          errorMessage = 'Your session has expired. Please log in again.';
          break;
        case 'Invalid device fingerprint':
          errorMessage =
              'Security alert: Session accessed from a different device.';
          break;
        case 'Invalid session id':
          errorMessage = 'Invalid session. Please log in again.';
          break;
        case 'expected str but provided int':
          errorMessage =
              'Technical error. Please try again or contact support.';
          debugPrint(
              'CRITICAL ERROR: Data type mismatch - Contact Backend Team');
          break;
        case 'Nonetype object are not iterable':
          errorMessage =
              'Technical error. Please try again or contact support.';
          debugPrint(
              'CRITICAL ERROR: Database access error - Contact Backend Team');
          break;
        case 'internal server error':
          errorMessage = 'Server error. Please try again later.';
          debugPrint('Server error - Contact DevOps Team');
          break;
        case 'Endpoint Timeout error':
          errorMessage = 'Connection timeout. Please try again later.';
          debugPrint('Timeout error - Contact DevOps Team');
          break;
        default:
          errorMessage = 'Authentication error. Please log in again.';
      }
    } catch (e) {
      debugPrint('Error parsing error response: $e');
    }

    // Clear tokens since they're invalid
    if (requiresLogout) {
      await clearTokens();
    }

    // Show error message if context is provided
    if (context != null && context.mounted) {
      showSnackBar(context: context, message: errorMessage);
    }
  }
}
