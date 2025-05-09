import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/features/auth/repository/auth_repository.dart';

// final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
//   return UserNotifier();
// });

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
