import 'package:CuraDocs/app/auth/token/token_repository.dart';
import 'package:CuraDocs/utils/providers/auth_providers.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimatedSplashWidget extends ConsumerStatefulWidget {
  const AnimatedSplashWidget({super.key});

  @override
  _AnimatedSplashWidgetState createState() => _AnimatedSplashWidgetState();
}

class _AnimatedSplashWidgetState extends ConsumerState<AnimatedSplashWidget> {
  bool _navigationInitiated = false;

  @override
  void initState() {
    super.initState();
    // Let's make sure widget is mounted before scheduling navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Schedule navigation after the animation duration
      Future.delayed(const Duration(milliseconds: 3500), () {
        if (mounted) {
          _navigateBasedOnAuth(context);
        }
      });
    });
  }

  Future<bool> _checkFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isFirstTime = prefs.getBool('is_first_time') ?? true;

      // If it's first time, set the flag to false for next time
      if (isFirstTime) {
        await prefs.setBool('is_first_time', false);
      }

      debugPrint("Is first time user: $isFirstTime");
      return isFirstTime;
    } catch (e) {
      debugPrint("Error checking first-time user status: $e");
      return true; // Default to showing onboarding if there's an error
    }
  }

  Future<void> _navigateBasedOnAuth(BuildContext context) async {
    // Prevent multiple navigation attempts
    if (_navigationInitiated) return;
    _navigationInitiated = true;

    debugPrint("Starting navigation logic");

    try {
      // First check if this is the first time the app is being opened
      bool isFirstTimeUser = await _checkFirstTimeUser();

      if (isFirstTimeUser) {
        debugPrint("First time user detected, navigating to onboarding");
        if (mounted) {
          context.goNamed(RouteConstants.onboarding);
          return; // Important to return here to prevent further navigation
        }
        return;
      }

      // Check token state more reliably
      // Force refresh tokens first if needed
      final tokenNotifier = ref.read(tokenStateProvider.notifier);
      final tokenState = ref.read(tokenStateProvider);

      // Check if we have a refresh token
      final hasRefreshToken = tokenState.refreshToken != null;
      debugPrint("Has refresh token: $hasRefreshToken");

      // Get auth state to check initialization status
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.isAuthenticated;
      final userRole = authState.userRole;

      debugPrint(
          "Auth state: isAuthenticated=$isAuthenticated, userRole=$userRole");

      if (hasRefreshToken) {
        // We have a refresh token, try to validate it explicitly
        try {
          final tokenRepository = ref.read(tokenRepositoryProvider);
          final isValidToken =
              await tokenRepository.refreshAccessToken(context: context);
          debugPrint("Token refresh result: $isValidToken");

          if (isValidToken) {
            // Token is valid, check if user role is set
            // Re-read auth state as it might have been updated
            final updatedAuthState = ref.read(authStateProvider);

            if (updatedAuthState.isAuthenticated &&
                updatedAuthState.userRole != null) {
              debugPrint(
                  "User authenticated as ${updatedAuthState.userRole}, navigating to home");

              // Use a small delay to ensure all state updates are processed
              await Future.delayed(const Duration(milliseconds: 100));

              if (mounted) {
                if (updatedAuthState.userRole == 'Doctor') {
                  context.goNamed(RouteConstants.doctorHome);
                } else {
                  context.goNamed(RouteConstants.home);
                }
              }
            } else {
              debugPrint("Token valid but role not set, going to login");
              if (mounted) {
                context.goNamed(RouteConstants.login);
              }
            }
          } else {
            // Token is invalid, go to login
            debugPrint("Invalid token, navigating to login");
            if (mounted) {
              context.goNamed(RouteConstants.login);
            }
          }
        } catch (e) {
          debugPrint("Error refreshing token: $e");
          if (mounted) {
            context.goNamed(RouteConstants.login);
          }
        }
      } else {
        // No refresh token, show role selection for new user journey
        debugPrint("No refresh token found, navigating to role selection");
        if (mounted) {
          context.goNamed(RouteConstants.role);
        }
      }
    } catch (e) {
      debugPrint("Error during navigation: $e");
      // Fallback navigation in case of error
      if (mounted) {
        context.goNamed(RouteConstants.role);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 107, 228),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.7,
                  height: size.height * 0.4,
                  child: LottieBuilder.network(
                    "https://lottie.host/0cc77978-be77-40e3-ae43-88f61d301e3e/u8rForcq9G.json",
                    fit: BoxFit.contain,
                    frameRate: FrameRate.max,
                    onLoaded: (composition) {
                      debugPrint("Lottie animation loaded successfully");
                    },
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
