import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:CuraDocs/features/auth/repository/token/token_repository.dart';
import 'package:CuraDocs/utils/providers/auth_providers.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class AnimatedSplashWidget extends ConsumerStatefulWidget {
  const AnimatedSplashWidget({super.key});

  @override
  _AnimatedSplashWidgetState createState() => _AnimatedSplashWidgetState();
}

class _AnimatedSplashWidgetState extends ConsumerState<AnimatedSplashWidget> {
  @override
  void initState() {
    super.initState();
    // Pre-check auth while animation is playing
    _preCheckAuth();
  }

  Future<void> _preCheckAuth() async {
    // Get token repository
    final tokenRepository = ref.read(tokenRepositoryProvider);

    // Try to refresh the token in background
    await tokenRepository.refreshAccessToken();
  }

  void _navigateBasedOnAuth(BuildContext context) async {
    // Get token repository
    final tokenRepository = ref.read(tokenRepositoryProvider);

    // Check if token is valid
    final tokenValid = await tokenRepository.refreshAccessToken();

    if (!mounted) return;

    if (tokenValid) {
      // Token is valid, get user role
      final authState = ref.read(authStateProvider);

      // Navigate to appropriate home screen
      if (authState.userRole == 'Doctor') {
        context.goNamed(RouteConstants.doctorHome);
      } else {
        context.goNamed(RouteConstants.home);
      }
    } else {
      // Token is invalid or doesn't exist, navigate to login
      context.goNamed(RouteConstants.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size.width * 0.7,
            height: size.height * 0.4,
            child: LottieBuilder.network(
              "https://lottie.host/0cc77978-be77-40e3-ae43-88f61d301e3e/u8rForcq9G.json",
              fit: BoxFit.contain,
            ),
          )
        ],
      ),
      nextScreen:
          Container(), // Empty container as we'll handle navigation in the callback
      splashIconSize: size.height * 0.7,
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: const Color.fromARGB(255, 15, 107, 228),
      duration: 2500, // Animation duration in milliseconds
      animationDuration: const Duration(milliseconds: 1000),
      // Handle navigation after animation completes
      disableNavigation: true,
      function: () async => _navigateBasedOnAuth(context),
    );
  }
}
