import 'package:CureBit/app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// A singleton class that provides global access to the current user.
///
/// This class maintains a single instance of the current user throughout the app
/// and provides methods to manage the user state. It's designed to work alongside
/// the existing UserNotifier provider approach, offering a simpler global access pattern
/// when the provider context is not available.
class UserSingleton {
  // Private constructor
  UserSingleton._internal();

  // Singleton instance
  static final UserSingleton _instance = UserSingleton._internal();

  // Factory constructor to return the singleton instance
  factory UserSingleton() {
    return _instance;
  }

  // Current user instance
  UserModel? _user;

  // Getter for the current user
  UserModel get user => _user ?? _getDefaultUser();

  // Check if a user is logged in
  bool get isLoggedIn => _user != null;

  // Default user when none is set (prevents null issues)
  UserModel _getDefaultUser() {
    return UserModel(
      cin: '',
      name: '',
      email: '',
      token: '',
      role: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Initialize the singleton with user data
  Future<void> initialize() async {
    await _loadFromStorage();
  }

  // Set the current user
  Future<void> setUser(UserModel user) async {
    _user = user;
    await _saveToStorage();
    debugPrint('User set in singleton: ${user.name}');
  }

  // Update user details
  Future<void> updateUser({
    String? cin,
    String? name,
    String? email,
    String? token,
    String? role,
  }) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      cin: cin,
      name: name,
      email: email,
      token: token,
      role: role,
      updatedAt: DateTime.now(),
    );

    await _saveToStorage();
  }

  // Clear the current user (for logout)
  Future<void> clearUser() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_singleton');
  }

  // Load user from SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_singleton');

      if (userJson != null) {
        _user = UserModel.fromJson(userJson);
        debugPrint('User loaded from storage: ${_user?.name}');
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
      // If there's an error loading, clear the stored data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_singleton');
    }
  }

  // Save user to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      if (_user == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_singleton', _user!.toJson());
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  // Sync with the user provider
  void syncWithProvider(UserModel? providerUser) {
    if (providerUser != null) {
      _user = providerUser;
      _saveToStorage();
    }
  }
}
