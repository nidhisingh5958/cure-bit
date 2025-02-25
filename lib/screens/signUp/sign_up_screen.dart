import 'package:CuraDocs/screens/signUp/sign_up_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/routes/route_constants.dart';

final Color color1 = Colors.black;
final Color color2 = Colors.black.withOpacity(0.8);
final Color color3 = Colors.grey.shade600;

// Custom color constants
class AppColors {
  static const textDark = Color(0xFF2D3142);
  static const error = Color(0xFFE63946);
  static const success = Color(0xFF2EC4B6);
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Create Account",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color1,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Fill your information below or register with a social account.",
                    style: TextStyle(
                      fontSize: 14,
                      color: color3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  SignUpForm(),
                  const SizedBox(height: 16),
                  _buildLoginLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        TextButton(
          onPressed: () => context.goNamed(RouteConstants.login),
          child: Text(
            'Login',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
