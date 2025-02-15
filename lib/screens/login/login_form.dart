import 'package:CuraDocs/components/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  final color = Colors.grey.shade600;
  final color1 = Colors.black;
  final color2 = Colors.black.withOpacity(0.8);

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
        // Simulate login delay
        await Future.delayed(const Duration(seconds: 2));
        // Add your login logic here

        if (mounted) {
          context.pushNamed(RouteConstants.otp);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
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
          Text(
            ' Email',
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          _buildEmailField(),
          const SizedBox(height: 20),
          Text(
            ' Password',
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRememberMeForgotPassword(),
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
        hintText: 'Enter your email',
        // prefixIcon: Icon(Icons.email_outlined, color: color2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
        hintText: 'Enter your password',
        // prefixIcon: Icon(Icons.lock_outline, color: color2),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: color2,
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
      ),
    );
  }

  Widget _buildRememberMeForgotPassword() {
    return Row(
      children: [
        const Spacer(),
        TextButton(
          onPressed: () => context.pushNamed(RouteConstants.forgotPass),
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: color1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      // prefixIcon: Icon(Icons.lock_outline, color: color2),
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black54,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
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
