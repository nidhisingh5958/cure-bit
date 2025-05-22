import 'package:CuraDocs/features/auth/landing/splash/splash_screen_animation.dart';
import 'package:CuraDocs/app/auth/token/token_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/utils/providers/auth_providers.dart';

class MainSplashScreen extends ConsumerStatefulWidget {
  const MainSplashScreen({Key? key}) : super(key: key);

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
      backgroundColor: const Color.fromARGB(255, 15, 107, 228),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo
            Image.asset(
              'assets/images/logo.png',
              height: 120,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
