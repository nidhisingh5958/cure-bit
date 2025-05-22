import 'package:CuraDocs/app/auth/auth_repository.dart';
import 'package:CuraDocs/app/auth/token/token_lifeguard.dart';
import 'package:CuraDocs/utils/providers/auth_providers.dart';
import 'package:CuraDocs/utils/routes/router.dart';
import 'package:CuraDocs/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nameProvider = Provider<String>((ref) => 'Cura Docs');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create provider container
  final container = ProviderContainer();

  // Get required providers
  final authRepo = container.read(authRepositoryProvider);
  final authNotifier = container.read(authStateProvider.notifier);

  try {
    debugPrint('=== App Initialization Started ===');
    debugPrint('Initializing app authentication state...');

    // Restore authentication state before running the app
    await authRepo.restoreAuthState(authNotifier);

    debugPrint('Authentication state restored successfully');
    debugPrint('=== App Initialization Complete ===');
  } catch (e) {
    debugPrint('Error during auth state restoration: $e');
    // Continue with app launch even if restoration fails
    // The user will be redirected to login screen by the router
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start token lifeguard service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop token lifeguard service
    try {
      ref.read(tokenLifeguardProvider).stopPeriodicRefresh();
      debugPrint('Token lifeguard service stopped');
    } catch (e) {
      debugPrint('Error stopping token lifeguard: $e');
    }
    super.dispose();
  }

  void _initializeServices() {
    try {
      // Start token lifeguard service
      ref.read(tokenLifeguardProvider).startPeriodicRefresh();
      debugPrint('Token lifeguard service started successfully');
    } catch (e) {
      debugPrint('Error starting token lifeguard: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('=== App Lifecycle Change ===');
    debugPrint('App lifecycle state changed to: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
        debugPrint('App is transitioning between foreground and background');
        break;
      case AppLifecycleState.detached:
        debugPrint('App is being destroyed');
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        debugPrint('App is hidden (iOS specific)');
        break;
    }
  }

  void _handleAppResumed() {
    debugPrint('=== App Resumed ===');
    debugPrint('App resumed - checking authentication state');

    try {
      // Check current authentication state
      final authState = ref.read(authStateProvider);
      debugPrint(
          'Current auth state - isAuthenticated: ${authState.isAuthenticated}');
      debugPrint('Current auth state - userRole: ${authState.userRole}');

      if (authState.isAuthenticated) {
        // Force refresh token when app comes to foreground
        debugPrint('User is authenticated, checking token validity...');
        ref.read(tokenLifeguardProvider).forceRefresh();

        // Also refresh authentication state to ensure tokens are still valid
        final authRepo = ref.read(authRepositoryProvider);
        final authNotifier = ref.read(authStateProvider.notifier);

        // Check and refresh token if needed
        authRepo.refreshTokenOnAppResume(authNotifier);
      } else {
        debugPrint('User is not authenticated, no token refresh needed');
      }

      // Resume token lifeguard if it was paused
      ref.read(tokenLifeguardProvider).resumePeriodicRefresh();
    } catch (e) {
      debugPrint('Error handling app resume: $e');
    }
  }

  void _handleAppPaused() {
    debugPrint('=== App Paused ===');
    debugPrint('App paused - preserving authentication state');

    try {
      // Optionally pause periodic refresh to save battery
      // Note: We don't stop it completely so tokens can still be refreshed if needed
      ref.read(tokenLifeguardProvider).pausePeriodicRefresh();
      debugPrint('Token lifeguard paused to conserve battery');
    } catch (e) {
      debugPrint('Error handling app pause: $e');
    }
  }

  void _handleAppDetached() {
    debugPrint('=== App Detached ===');
    debugPrint('App is being destroyed - cleaning up resources');

    try {
      // Stop token lifeguard completely
      ref.read(tokenLifeguardProvider).stopPeriodicRefresh();
      debugPrint('Token lifeguard stopped due to app destruction');
    } catch (e) {
      debugPrint('Error handling app detached: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncRouter = ref.watch(routerFutureProvider);

    return asyncRouter.when(
      loading: () => MaterialApp(
        title: 'Cura Docs',
        theme: theme(),
        home: const Scaffold(
          body: AppLoadingWidget(),
        ),
      ),
      error: (error, stack) {
        debugPrint('=== Router Error ===');
        debugPrint('Router error: $error');
        debugPrint('Stack trace: $stack');

        return MaterialApp(
          title: 'Cura Docs',
          theme: theme(),
          home: AppErrorWidget(
            title: 'App Error',
            message:
                'Something went wrong during app initialization. Please restart the app.',
            error: error.toString(),
            onRetry: () {
              // Force rebuild the router
              ref.invalidate(routerFutureProvider);
            },
          ),
        );
      },
      data: (router) => MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        title: 'Cura Docs',
        theme: theme(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}

// Enhanced loading widget with better user experience
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Checking authentication state',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced error handling widget with retry functionality
class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? error;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Technical Details'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null) ...[
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  OutlinedButton.icon(
                    onPressed: () {
                      // Force app restart - this is a basic implementation
                      // In a real app, you might want to use a package like restart_app
                      debugPrint('App restart requested by user');
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Restart App'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
