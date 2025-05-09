import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data that holds login state
class AuthState {
  final bool isAuthenticated;
  final String role;
  AuthState({required this.isAuthenticated, required this.role});
}

/// Notifier to load/save login state
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier()
      : super(AuthState(isAuthenticated: false, role: 'Patient')) {
    _loadFromPrefs(); // <-- Load when app starts
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool('isAuthenticated') ?? false;
    final role = prefs.getString('userRole') ?? 'Patient';
    state = AuthState(isAuthenticated: isAuth, role: role);
  }

  Future<void> setAuthenticated(bool value, [String? role]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', value);
    if (role != null) await prefs.setString('userRole', role);

    state = AuthState(isAuthenticated: value, role: role ?? state.role);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.setString('userRole', 'Patient');
    state = AuthState(isAuthenticated: false, role: 'Patient');
  }
}

/// Riverpod provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(),
);
