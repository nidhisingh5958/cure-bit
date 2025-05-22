//  SecureStorageService: Handles secure storage of tokens.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accessTokenExpiryKey = 'access_token_expiry';
  static const String _userRoleKey = 'user_role';

  // Store access token
  static Future<void> storeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Store refresh token
  static Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Store access token expiry
  static Future<void> storeAccessTokenExpiry(DateTime expiry) async {
    await _storage.write(
        key: _accessTokenExpiryKey, value: expiry.toIso8601String());
  }

  // Get access token expiry
  static Future<DateTime?> getAccessTokenExpiry() async {
    final expiryStr = await _storage.read(key: _accessTokenExpiryKey);
    if (expiryStr != null) {
      return DateTime.parse(expiryStr);
    }
    return null;
  }

  // Store user role
  static Future<void> storeUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  // Clear all tokens and user data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static final storage = FlutterSecureStorage();
}
