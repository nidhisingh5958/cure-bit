import 'package:CuraDocs/features/auth/screens/signUp/sign_up_screen.dart';
import 'package:CuraDocs/features/auth/landing/splash_screen.dart';

import 'package:CuraDocs/features/patient/settings/support/contact_us.dart';
import 'package:CuraDocs/utils/routes/doctor_routes.dart';
import 'package:CuraDocs/utils/routes/patients_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CuraDocs/features/auth/landing/role.dart';
import 'package:CuraDocs/features/auth/screens/login/forgot_pass.dart';
import 'package:CuraDocs/features/auth/screens/login/login_screen.dart';
import 'package:CuraDocs/features/auth/landing/onboarding_screen.dart';
import 'package:CuraDocs/features/auth/screens/login/otp.dart';

import 'package:CuraDocs/utils/routes/components/navigation_keys.dart';

const bool isDev = true; // Set to false before release

class AppRouter {
  // SharedPreferences keys
  static const String _isFirstLaunchKey = 'isFirstLaunch';
  static const String _isAuthenticatedKey = 'isAuthenticated';
  static const String _userRoleKey = 'userRole';

  static late bool _isFirstLaunch;
  static late bool _isAuthenticated;
  static late String _userRole;

  // Initialize the router with necessary checks
  static Future<GoRouter> initRouter() async {
    final prefs = await SharedPreferences.getInstance();

    if (isDev) {
      _isFirstLaunch = false;
      _isAuthenticated = true;
      _userRole = 'Patient'; // or 'Doctor'
    } else {
      _isFirstLaunch = prefs.getBool(_isFirstLaunchKey) ?? true;
      _isAuthenticated = prefs.getBool(_isAuthenticatedKey) ?? false;
      _userRole = prefs.getString(_userRoleKey) ?? 'Patient';

      if (_isFirstLaunch) {
        await prefs.setBool(_isFirstLaunchKey, false);
      }
    }

    // // Load preferences
    // final prefs = await SharedPreferences.getInstance();
    // _isFirstLaunch = prefs.getBool(_isFirstLaunchKey) ?? true;
    // _isAuthenticated = prefs.getBool(_isAuthenticatedKey) ?? false;
    // _userRole = prefs.getString(_userRoleKey) ?? 'Patient';

    // // If this is the first launch, set the flag for future
    // if (_isFirstLaunch) {
    //   await prefs.setBool(_isFirstLaunchKey, false);
    // }

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: isDev ? '/home' : '/',
      debugLogDiagnostics: true,
      routes: [
        // Auth and onboarding routes (outside shell)
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.splash,
          path: '/',
          builder: (context, state) => SplashScreen(),
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
          builder: (context, state) => SignUpScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.login,
          path: '/login',
          builder: (context, state) => LoginScreen(),
          routes: [
            GoRoute(
              name: RouteConstants.forgotPass,
              path: 'forgot-password',
              builder: (context, state) => ForgotPasswordScreen(),
            ),
            GoRoute(
              name: RouteConstants.otp,
              path: 'otp',
              builder: (context, state) => OtpScreen(),
            ),
          ],
        ),

        GoRoute(
            path: '/contactUs',
            name: RouteConstants.contactUs,
            builder: (context, state) {
              return const ContactUsScreen();
            }),

        // Add all patient routes
        ...patientRoutes,

        // Add all doctor routes
        ...doctorRoutes,
      ],
      // Redirect logic
      redirect: (BuildContext context, GoRouterState state) {
        // Always allow access to splash screen
        if (state.matchedLocation == '/') {
          return null;
        }

        // Check if user is trying to access auth routes
        final isGoingToAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation.startsWith('/login/') ||
            state.matchedLocation == '/sign-up' ||
            state.matchedLocation == '/onboarding' ||
            state.matchedLocation == '/role';

        // If authenticated, prevent going to auth routes
        if (_isAuthenticated && isGoingToAuthRoute) {
          // Redirect to the appropriate dashboard based on role
          return _userRole == 'Doctor' ? '/doctor/home' : '/home';
        }

        // If not authenticated, prevent access to protected routes
        if (!_isAuthenticated && !isGoingToAuthRoute) {
          // First-time users should see onboarding
          if (_isFirstLaunch) {
            return '/onboarding';
          }
          // Send to role selection first
          return '/role';
        }

        // No redirects needed
        return null;
      },
      refreshListenable: AuthStateNotifier(),
    );
  }

  // Method to set user as authenticated
  static Future<void> setAuthenticated(bool value, [String? role]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAuthenticatedKey, value);
    _isAuthenticated = value;

    // If role is provided, save it
    if (role != null) {
      await prefs.setString(_userRoleKey, role);
      _userRole = role;
    }

    // Notify listeners to refresh the router
    AuthStateNotifier().notifyListeners();
  }

  // Method to get the current user role
  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey) ?? 'Patient';
  }
}

// Class to notify the router when auth state changes
class AuthStateNotifier extends ChangeNotifier {
  static final AuthStateNotifier _instance = AuthStateNotifier._internal();

  factory AuthStateNotifier() => _instance;

  AuthStateNotifier._internal();

  // Override to prevent potential memory issues
  @override
  void dispose() {
    // Don't call super.dispose() as this is a singleton
  }
}

// Initialize the router
final routerFuture = AppRouter.initRouter();
