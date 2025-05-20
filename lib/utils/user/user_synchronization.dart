import 'package:CuraDocs/utils/user/user_singleton.dart';
import 'package:CuraDocs/utils/providers/user_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper class to synchronize the UserSingleton with the Riverpod UserProvider.
///
/// This class ensures that user data stays consistent between the singleton pattern
/// and the provider pattern in the application.
class UserSynchronizer {
  /// Initialize the UserSingleton and sync it with the UserProvider
  static Future<void> initialize(WidgetRef ref) async {
    await UserSingleton().initialize();

    // Get current user from provider
    final userFromProvider = ref.read(userProvider);

    // If provider has a user but singleton doesn't, sync from provider to singleton
    if (userFromProvider != null && !UserSingleton().isLoggedIn) {
      await UserSingleton().setUser(userFromProvider);
    }
    // If singleton has a user but provider doesn't, sync from singleton to provider
    else if (UserSingleton().isLoggedIn && userFromProvider == null) {
      ref.read(userProvider.notifier).setUser(UserSingleton().user);
    }
  }

  /// Sync changes from provider to singleton and vice versa
  static void syncUser(WidgetRef ref) {
    final userFromProvider = ref.read(userProvider);

    // Sync from provider to singleton
    if (userFromProvider != null) {
      UserSingleton().syncWithProvider(userFromProvider);
    }
  }

  /// Register listener to keep the singleton in sync with provider changes
  static void setupSyncListener(WidgetRef ref) {
    ref.listen(userProvider, (previous, next) {
      if (next != null) {
        UserSingleton().syncWithProvider(next);
      } else {
        UserSingleton().clearUser();
      }
    });
  }

  /// Clear user from both singleton and provider (for logout)
  static Future<void> clearUser(WidgetRef ref) async {
    await UserSingleton().clearUser();
    await ref.read(userProvider.notifier).clearUser();
  }
}
