import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:CuraDocs/screens/login/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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

      //  yahan change hoga abhi home screen hai
      nextScreen: LoginScreen(),
      splashIconSize: size.height * 0.7,
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Color.fromARGB(255, 15, 107, 228),
    );
  }
}
