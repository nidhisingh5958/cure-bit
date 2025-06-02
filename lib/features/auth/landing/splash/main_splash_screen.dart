import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/features/auth/landing/splash/splash_screen_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainSplashScreen extends ConsumerStatefulWidget {
  const MainSplashScreen({super.key});

  @override
  _MainSplashScreenState createState() => _MainSplashScreenState();
}

class _MainSplashScreenState extends ConsumerState<MainSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Initial delay for logo splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Proceed to animated splash screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AnimatedSplashWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo
            Image.asset(
              'assets/images/logo.png',
              height: 200,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: transparent,
            ),
          ],
        ),
      ),
    );
  }
}
