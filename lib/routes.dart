import 'package:cure_bit/screens/login/login_screen.dart';
import 'package:cure_bit/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  OnboardingScreen.routeName: (context) => OnboardingScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
};
