import 'package:cure_bit/screens/forgot_pass/forgot_pass.dart';
import 'package:cure_bit/screens/login/login_screen.dart';
import 'package:cure_bit/screens/onboarding_screen.dart';
import 'package:cure_bit/screens/otp.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  OnboardingScreen.routeName: (context) => OnboardingScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  OtpScreen.routeName: (context) => OtpScreen(),
};
