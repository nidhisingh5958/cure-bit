import 'package:CuraDocs/components/routes/route_constants.dart';
import 'package:CuraDocs/screens/signUp/sign_up_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Custom color constants
class AppColors {
  static const background = Color(0xFFF4F6F5);
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/icons/main_logo.png',
                      height: 165,
                    ),
                  ),
                  // const SizedBox(height: 12),
                  Text(
                    "Create Account",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign up to continue to your health journey",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
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
