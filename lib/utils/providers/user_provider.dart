import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CureBit/services/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider that stores the current user
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    // Load user from shared preferences when initialized
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');

    if (userJson != null) {
      try {
        state = UserModel.fromJson(userJson);
      } catch (e) {
        // If there's an error parsing the JSON, clear it
        await prefs.remove('current_user');
      }
    }
  }

  // Set user details
  Future<void> setUser(UserModel user) async {
    state = user;

    // Save to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', user.toJson());
  }

  // Update user details
  Future<void> updateUser({
    String? cin,
    String? name,
    String? email,
    String? token,
    String? role,
  }) async {
    if (state == null) return;

    // Create updated user model
    final updatedUser = state!.copyWith(
      cin: cin ?? state!.cin,
      name: name ?? state!.name,
      email: email ?? state!.email,
      token: token ?? state!.token,
      role: role ?? state!.role,
    );

    // Update state
    state = updatedUser;

    // Save to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', updatedUser.toJson());
  }

  // Clear user (for logout)
  Future<void> clearUser() async {
    state = null;

    // Remove from persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  Future<UserModel?> getUser() async {
    return state;
  }
}
