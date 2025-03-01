import 'dart:convert';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Simulate network request
        Response response = await post(
            Uri.parse(
                'https://lb0ejwoox7.execute-api.us-east-1.amazonaws.com/Dev/auth/patient/login'),
            body: jsonEncode({
              'email': _emailController.text,
              'password': _passwordController.text,
            }),
            headers: {
              'Content-Type': 'application/json',
            });
        await Future.delayed(const Duration(seconds: 1));
        // Add your login logic here

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful'),
              backgroundColor: Colors.green,
            ),
          );
          GoRouter.of(context).go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("failed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email, CIN, or phone number is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid phone number, CIN, or email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 14),
          _buildForgotPassword(),
          const SizedBox(height: 24),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: _validateEmail,
      decoration: InputDecoration(
        hintText: 'Phone Number, CIN, or email',
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      validator: _validatePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: color2,
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Row(
      children: [
        const Spacer(),
        TextButton(
          onPressed: () => context.pushNamed(RouteConstants.forgotPass),
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: color1,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      child:
          // _isLoading
          //     ? const SizedBox(
          //         height: 20,
          //         width: 20,
          //         child: CircularProgressIndicator(strokeWidth: 2),
          //       )
          //     :
          const Text(
        'Sign In',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// error message
class FormError extends StatelessWidget {
  const FormError({
    super.key,
    required this.errors,
  });

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        errors.length,
        (index) => formErrorText(error: errors[index]),
      ),
    );
  }

  Row formErrorText({error}) {
    return Row(
      children: [
        Image(image: AssetImage("assets/icons/error.png")),
        SizedBox(width: 20),
        Text(error),
      ],
    );
  }
}
