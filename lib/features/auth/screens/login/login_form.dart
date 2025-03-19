import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/auth/repository/auth_repository.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/utils/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const LoginForm({Key? key, this.extra}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late String _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    // First check if role is passed in through router
    if (widget.extra != null && widget.extra!.containsKey('role')) {
      _role = widget.extra!['role'];
    } else {
      // Otherwise load from shared preferences
      final prefs = await SharedPreferences.getInstance();
      _role = prefs.getString('userRole') ?? 'Patient'; // Default to Patient
    }
    setState(() {});
  }

  Future<void> _handleLogin() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() => _isLoading = true);

        final authRepository = AuthRepository();
        await authRepository.signInWithPass(
          context,
          _inputController.text,
          _passwordController.text,
          _role,
        );
        await AppRouter.setAuthenticated(true, _role);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print(e);
    }
  }

  // validator for handling multiple input types
  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number, user ID, or email';
    }

    // Email validation (simple check for @)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // Phone validation (simple check for numbers only)
    final phoneRegex = RegExp(r'^\d+$');

    // If it's not email or phone, assume it's a user ID
    if (!emailRegex.hasMatch(value) &&
        !phoneRegex.hasMatch(value) &&
        value.length < 3) {
      return 'Please enter a valid phone number, user ID, or email';
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
          _buildInputField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 14),
          _buildForgotPassword(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 30),
          _buildLoginWithOtp(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return TextFormField(
      controller: _inputController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: _validateInput,
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

  Widget _buildLoginWithOtp() {
    return Center(
      child: TextButton(
        onPressed: () {
          context.goNamed(RouteConstants.otp);
        },
        child: Text(
          'Sign In with OTP',
          style: TextStyle(fontSize: 16, color: color2),
        ),
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
