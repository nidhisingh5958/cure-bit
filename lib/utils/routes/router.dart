import 'dart:async';
import 'package:CuraDocs/common/contact_us.dart';
import 'package:CuraDocs/features/auth/landing/splash/main_splash_screen.dart';
import 'package:CuraDocs/features/auth/repository/auth_middleware.dart';
import 'package:CuraDocs/features/auth/screens/login/forgot_pass/pass.dart';
import 'package:CuraDocs/features/auth/screens/signUp/sign_up_screen.dart';

import 'package:CuraDocs/common/report_a_problem.dart';
import 'package:CuraDocs/utils/providers/auth_providers.dart';

import 'package:CuraDocs/utils/routes/doctor_routes.dart';
import 'package:CuraDocs/utils/routes/patients_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/features/auth/landing/role.dart';
import 'package:CuraDocs/features/auth/screens/login/forgot_pass/forgot_pass.dart';
import 'package:CuraDocs/features/auth/screens/login/login_screen.dart';
import 'package:CuraDocs/features/auth/landing/onboarding_screen.dart';
import 'package:CuraDocs/features/auth/screens/login/login_otp/otp.dart';
import 'package:CuraDocs/utils/routes/components/navigation_keys.dart';

const bool isDev = true; // Set to false before release

class AuthState {
  final bool isAuthenticated;
  final String? role;

  AuthState({
    required this.isAuthenticated,
    this.role,
  });
}

class AppRouter {
  static Future<GoRouter> initRouter(FutureProviderRef<GoRouter> ref) async {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: isDev ? '/home' : '/',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.splash,
          path: '/',
          builder: (context, state) => const MainSplashScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.onboarding,
          path: '/onboarding',
          builder: (context, state) => OnboardingScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.role,
          path: '/role',
          builder: (context, state) => RoleScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.signUp,
          path: '/sign-up',
          builder: (context, state) => AuthMiddleware(
            requiresAuth: false,
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.login,
          path: '/login',
          builder: (context, state) => AuthMiddleware(
            requiresAuth: false,
            child: const LoginScreen(),
          ),
          routes: [
            GoRoute(
              name: RouteConstants.forgotPass,
              path: 'forgot-password',
              builder: (context, state) => AuthMiddleware(
                requiresAuth: false,
                child: const ForgotPasswordScreen(),
              ),
              routes: [
                GoRoute(
                  name: RouteConstants.passReset,
                  path: 'password-reset',
                  builder: (context, state) => AuthMiddleware(
                    child: PasswordInputScreen(),
                    requiresAuth: false,
                  ),
                ),
              ],
            ),
            GoRoute(
              name: RouteConstants.otp,
              path: 'otp',
              builder: (context, state) => AuthMiddleware(
                requiresAuth: false,
                child: const OtpScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/contactUs',
          name: RouteConstants.contactUs,
          builder: (context, state) => AuthMiddleware(
            requiresAuth: false,
            child: const ContactUsScreen(),
          ),
        ),
        GoRoute(
          path: '/reportProblem',
          name: RouteConstants.reportProblem,
          builder: (context, state) => AuthMiddleware(
            requiresAuth: false,
            child: const ReportAProblemScreen(),
          ),
        ),
        ...patientRoutes,
        ...doctorRoutes,
      ],
      redirect: (context, state) {
        if (isDev) {
          return null;
        }

        final auth = ref.read(authStateProvider);

        final isGoingToAuthRoute = state.matchedLocation.startsWith('/login') ||
            state.matchedLocation.startsWith('/sign-up') ||
            state.matchedLocation.startsWith('/onboarding') ||
            state.matchedLocation.startsWith('/role');

        // Skip authentication checks for splash screen
        if (state.matchedLocation == '/') {
          return null; // Always allow access to splash screen
        }

        if (auth.isAuthenticated && isGoingToAuthRoute) {
          return auth.userRole == 'Doctor' ? '/doctor/home' : '/home';
        }

        if (!auth.isAuthenticated &&
            !isGoingToAuthRoute &&
            state.matchedLocation != '/') {
          return '/role';
        }

        return null;
      },
      refreshListenable: GoRouterRefreshStream(
        ref.watch(authStateProvider.notifier).stream,
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerFutureProvider = FutureProvider<GoRouter>((ref) async {
  return await AppRouter.initRouter(ref);
});
