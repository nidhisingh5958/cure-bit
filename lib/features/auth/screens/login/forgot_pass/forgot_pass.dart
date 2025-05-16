import 'package:CuraDocs/utils/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/auth/repository/auth_repository.dart';
import 'package:CuraDocs/features/auth/screens/login/login_otp/otp_sheet.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/utils/snackbar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const ForgotPasswordScreen({super.key, this.extra});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  late String _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "Forgot Password",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "Don't worry! It happens. Please enter the email address associated with your account to reset your password.",
                    style: TextStyle(
                      fontSize: 14,
                      color: grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                EnhancedForgotPassForm(role: _role),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EnhancedForgotPassForm extends ConsumerStatefulWidget {
  final String role;

  const EnhancedForgotPassForm({super.key, required this.role});

  @override
  ConsumerState<EnhancedForgotPassForm> createState() =>
      _EnhancedForgotPassFormState();
}

class _EnhancedForgotPassFormState
    extends ConsumerState<EnhancedForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _resetToken;
  late String _role;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Create an instance of AuthRepository
        final authRepository = AuthRepository();

        // Request password reset and get token
        _resetToken = await authRepository.requestPasswordReset(
          context,
          _emailController.text,
          widget.role,
        );

        if (_resetToken != null && mounted) {
          // Store the token for later use
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('resetToken', _resetToken!);

          // Show the OTP entry bottom sheet to verify the email
          _showOtpBottomSheet();
        }
      } catch (e) {
        if (mounted) {
          showSnackBar(
              context: context,
              message:
                  'Failed to send password reset request. Please try again.');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showOtpBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return OtpEntrySheet(
          role: _role,
          identifier: _emailController.text,
          onVerificationComplete: () async {
            Navigator.of(context).pop();

            // Then set the authentication state
            ref.read(authStateProvider.notifier).setAuthenticated(true, _role);

            // Show success message
            if (mounted) {
              showSnackBar(
                context: context,
                message: 'OTP verified successfully',
              );
            }

            // Use the correct context for navigation
            if (mounted) {
              // Redirect based on user role
              if (_role == 'Doctor') {
                context.go(RouteConstants.doctorHome);
              } else {
                context.go(RouteConstants.home);
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            decoration: InputDecoration(
              hintText: 'Email',
            ),
            style: TextStyle(
              fontSize: 14,
              color: black,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Remember your password? ",
                style: TextStyle(
                  fontSize: 14,
                  color: grey600,
                ),
              ),
              GestureDetector(
                onTap: () => context.goNamed(RouteConstants.login),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: black.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
