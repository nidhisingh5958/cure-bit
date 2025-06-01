// Auth Middleware: Checks if the user is authenticated and if the token is valid before allowing access to protected routes.
import 'package:CureBit/app/auth/token/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:CureBit/utils/providers/auth_providers.dart';
import 'package:CureBit/utils/routes/route_constants.dart';

class AuthMiddleware extends ConsumerWidget {
  final Widget child;
  final String redirectRoute;
  final bool requiresAuth;
  final String? requiredRole;

  const AuthMiddleware({
    super.key,
    required this.child,
    this.redirectRoute = 'login',
    this.requiresAuth = true,
    this.requiredRole,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final tokenRepository = ref.watch(tokenRepositoryProvider);

    // Check if we're already loading the auth state
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check if route requires authentication
    if (requiresAuth) {
      if (!authState.isAuthenticated) {
        // Not authenticated, redirect
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.goNamed(redirectRoute);
        });
        return const SizedBox.shrink();
      }

      // Check if specific role is required
      if (requiredRole != null && authState.userRole != requiredRole) {
        // Wrong role, redirect
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Redirect to appropriate home based on role
          if (authState.userRole == 'Doctor') {
            context.goNamed(RouteConstants.doctorHome);
          } else {
            context.goNamed(RouteConstants.home);
          }
        });
        return const SizedBox.shrink();
      }

      // Check if token needs refreshing
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Try to refresh token if needed, but don't block the UI
        tokenRepository.refreshAccessToken(context: context);
      });
    } else if (authState.isAuthenticated) {
      // Route doesn't require auth but user is authenticated
      // Typically used for login/signup routes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Redirect to appropriate home based on role
        if (authState.userRole == 'Doctor') {
          context.goNamed(RouteConstants.doctorHome);
        } else {
          context.goNamed(RouteConstants.home);
        }
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
