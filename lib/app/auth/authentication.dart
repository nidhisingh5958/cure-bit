import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _authError;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get authError => _authError;

  // Sign up with email and password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _authError = null;
      notifyListeners();

      // Add your API call here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Validate email format
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password strength
      if (!_isPasswordStrong(password)) {
        throw Exception('Password does not meet security requirements');
      }

      _isAuthenticated = true;

      return true;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _authError = null;
      notifyListeners();

      // Add your API call here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      _isAuthenticated = true;
      return true;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Add your logout API call here
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Password validation
  bool _isPasswordStrong(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  // Rate limiting for login attempts
  final Map<String, List<DateTime>> _loginAttempts = {};

  bool _canAttemptLogin(String email) {
    final attempts = _loginAttempts[email] ?? [];
    final now = DateTime.now();

    // Remove attempts older than 15 minutes
    attempts.removeWhere(
        (attempt) => now.difference(attempt) > const Duration(minutes: 15));

    // Allow max 5 attempts in 15 minutes
    if (attempts.length >= 5) {
      return false;
    }

    attempts.add(now);
    _loginAttempts[email] = attempts;
    return true;
  }
}
