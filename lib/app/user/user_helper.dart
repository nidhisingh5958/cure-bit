import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/app/models/user_model.dart';
import 'package:CuraDocs/utils/providers/user_provider.dart';

/// Helper class to easily access user data throughout the app
class UserHelper {
  /// Get the current logged-in user
  static UserModel? getCurrentUser(WidgetRef ref) {
    return ref.watch(userProvider);
  }

  /// Get a specific user attribute safely
  static T? getUserAttribute<T>(WidgetRef ref, String attribute,
      {T? defaultValue}) {
    final user = ref.watch(userProvider);
    if (user == null) return defaultValue;

    switch (attribute) {
      case 'name':
        return user.name as T?;
      case 'email':
        return user.email as T?;
      case 'cin':
        return user.cin as T?;
      case 'role':
        return user.role as T?;
      default:
        return defaultValue;
    }
  }

  /// Check if the current user is a doctor
  static bool isDoctor(WidgetRef ref) {
    final user = ref.watch(userProvider);
    return user?.role == 'Doctor';
  }

  /// Check if the current user is a patient
  static bool isPatient(WidgetRef ref) {
    final user = ref.watch(userProvider);
    return user?.role == 'Patient';
  }

  /// Build a widget based on the user's role
  static Widget buildForRole({
    required WidgetRef ref,
    required Widget Function() forDoctor,
    required Widget Function() forPatient,
    Widget Function()? forAnonymous,
  }) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return forAnonymous?.call() ?? const SizedBox();
    }

    if (user.role == 'Doctor') {
      return forDoctor();
    } else {
      return forPatient();
    }
  }
}
