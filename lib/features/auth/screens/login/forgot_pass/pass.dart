import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/auth/repository/auth_repository.dart';
import 'package:CuraDocs/utils/providers/auth_controllers.dart';
import 'package:CuraDocs/utils/providers/auth_providers.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordInputScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const PasswordInputScreen({super.key, this.extra});

  @override
  ConsumerState<PasswordInputScreen> createState() =>
      _PasswordInputScreenState();
}

class _PasswordInputScreenState extends ConsumerState<PasswordInputScreen> {
  late final authController;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  late String _identifier;
  late String _role;
  late bool _fromForgotPassword;
  String? _resetToken;

  @override
  void initState() {
    super.initState();
    authController = ref.read(authStateProvider.notifier);
    // Extract data from router
    if (widget.extra != null) {
      _identifier = widget.extra!['identifier'] ?? '';
      _role = widget.extra!['role'] ?? 'Patient';
      _fromForgotPassword = widget.extra!['fromForgotPassword'] ?? false;
      _resetToken = widget.extra!['resetToken'];
    } else {
      _identifier = '';
      _role = 'Patient';
      _fromForgotPassword = false;
    }

    // If resetToken wasn't passed through extra, try to get it from SharedPreferences
    if (_fromForgotPassword && _resetToken == null) {
      _loadResetToken();
    }
  }

  Future<void> _loadResetToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _resetToken = prefs.getString('resetToken');
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackBar(
        context: context,
        message: 'Passwords do not match',
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      if (_fromForgotPassword) {
        // Check if reset token is available
        if (_resetToken == null) {
          showSnackBar(
            context: context,
            message:
                'Reset token not found. Please try the reset process again.',
          );
          return;
        }

        // Create instance of AuthRepository
        final authRepository = AuthRepository();

        // Call reset password method with token
        await authRepository.resetPassword(
          context: context,
          identifier: _identifier,
          password: _passwordController.text,
          role: _role,
          notifier: ref.read(authController),
          token: _resetToken!,
        );

        if (mounted) {
          // Clear the stored reset token
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('resetToken');

          showSnackBar(
            context: context,
            message:
                'Password reset successfully. Please login with your new password.',
          );

          // Navigate to login page
          context.go(RouteConstants.login);
        }
      } else {
        // Use the signup controller for signup flow
        final signUpController = ref.read(signUpControllerProvider);
        // Note: You'll need to adapt this code based on your actual signup flow
        // This is a placeholder for your existing signup logic
        // await signUpController.signUp(...);

        // Navigate to appropriate screen after signup
        if (mounted) {
          if (_role == 'Doctor') {
            context.go(RouteConstants.doctorHome);
          } else {
            context.go(RouteConstants.home);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context: context,
          message: 'Error: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        elevation: 0,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      _fromForgotPassword ? "Reset Password" : "Create Account",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _fromForgotPassword
                          ? "Please enter your new password below."
                          : "Fill your information below or register with a social account.",
                      style: TextStyle(
                        fontSize: 14,
                        color: grey600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildPasswordField(
                            controller: _passwordController,
                            hint: 'Password',
                            isVisible: _isPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible);
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hint: 'Confirm Password',
                            isVisible: _isConfirmPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() => _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible);
                            },
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(
                                    _fromForgotPassword
                                        ? 'Reset Password'
                                        : 'Submit',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black.withOpacity(0.8),
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Password must contain at least one uppercase letter';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Password must contain at least one number';
            }
            return null;
          },
    );
  }
}
