import 'package:CuraDocs/app/auth/auth_repository.dart';
import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
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

  @override
  void initState() {
    super.initState();
    authController = ref.read(authStateProvider.notifier);
    // Extract data from router
    if (widget.extra != null) {
      _identifier = widget.extra!['identifier'] ?? '';
      _role = widget.extra!['role'] ?? 'Patient';
      _fromForgotPassword = widget.extra!['fromForgotPassword'] ?? false;
    } else {
      _identifier = '';
      _role = 'Patient';
      _fromForgotPassword = false;
    }

    debugPrint('PasswordInputScreen initialized:');
    debugPrint('Identifier: $_identifier');
    debugPrint('Role: $_role');
    debugPrint('From Forgot Password: $_fromForgotPassword');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackBar(context: context, message: 'Passwords do not match');
      return;
    }

    try {
      setState(() => _isLoading = true);

      if (_fromForgotPassword) {
        // Use the Provider to get the AuthRepository instance
        final authRepository = ref.read(authRepositoryProvider);

        // Validate inputs before making API call
        if (_identifier.isEmpty) {
          showSnackBar(context: context, message: 'Invalid email address');
          return;
        }

        if (_passwordController.text.length < 8) {
          showSnackBar(
              context: context,
              message: 'Password must be at least 8 characters long');
          return;
        }

        debugPrint('Calling resetPassword with:');
        debugPrint('Identifier: $_identifier');
        debugPrint('Role: $_role');

        await authRepository.resetPassword(
          context: context,
          identifier: _identifier,
          password: _passwordController.text,
          role: _role,
          notifier: authController,
        );

        // Note: The resetPassword method handles navigation to login screen
        // and clearing of stored tokens internally
      } else {
        // Handle regular account creation if needed
        showSnackBar(
          context: context,
          message: 'Account creation flow not implemented yet',
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Password reset error: ${e.toString()}');
        showSnackBar(context: context, message: 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        elevation: 0,
        onBackPressed: () {
          if (_fromForgotPassword) {
            // Clear stored OTP when going back
            _clearStoredData();
          }
          Navigator.pop(context);
        },
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
                          ? "Please enter your new password below. Make sure it's strong and secure."
                          : "Fill your information below or register with a social account.",
                      style: TextStyle(
                        fontSize: 14,
                        color: grey600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_fromForgotPassword && _identifier.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        "Resetting password for: $_identifier",
                        style: TextStyle(
                          fontSize: 12,
                          color: color2,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildPasswordField(
                            controller: _passwordController,
                            hint: 'New Password',
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
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
                          if (_fromForgotPassword) ...[
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      _clearStoredData();
                                      context.goNamed(RouteConstants.login);
                                    },
                              child: Text(
                                'Cancel and return to login',
                                style: TextStyle(
                                  color: grey600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
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
        prefixIcon: Icon(
          Icons.lock_outline,
          color: grey600,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: grey600,
          ),
          onPressed: onVisibilityToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color2, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
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
            if (!RegExp(r'[a-z]').hasMatch(value)) {
              return 'Password must contain at least one lowercase letter';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Password must contain at least one number';
            }
            return null;
          },
    );
  }

  Future<void> _clearStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('hashedOtp');
      debugPrint('Cleared stored OTP data');
    } catch (e) {
      debugPrint('Error clearing stored data: ${e.toString()}');
    }
  }
}
