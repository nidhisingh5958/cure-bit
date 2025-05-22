import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/app/auth/auth_repository.dart';
import 'package:CuraDocs/utils/providers/auth_providers.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final primaryColor = grey800;

// OTP entry bottom sheet
class OtpEntrySheet extends ConsumerStatefulWidget {
  final String identifier;
  final VoidCallback onVerificationComplete;
  final String? countryCode;
  final String role;
  final bool isForgotPassword; // Flag to identify which flow we're in

  const OtpEntrySheet({
    super.key,
    required this.identifier,
    required this.onVerificationComplete,
    this.countryCode,
    required this.role,
    this.isForgotPassword = false, // Default is regular OTP login
  });

  @override
  ConsumerState<OtpEntrySheet> createState() => _OtpEntrySheetState();
}

class _OtpEntrySheetState extends ConsumerState<OtpEntrySheet> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isResendActive = false;
  int _resendTimer = 60;
  bool _isLoading = false;
  late String _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _startResendTimer();

    // Set up focus listeners to prevent skipping fields
    for (int i = 0; i < _focusNodes.length; i++) {
      final node = _focusNodes[i];
      node.addListener(() {
        if (node.hasFocus) {
          // If a field gets focus but the previous field is empty (except for first field)
          if (i > 0 && _controllers[i - 1].text.isEmpty) {
            // Move focus back to the previous empty field
            _focusNodes[i].unfocus();
            _focusNodes[i - 1].requestFocus();
          }
        }
      });
    }

    // Request focus on first field after building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('userRole') ?? 'Patient'; // Default to Patient
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _isResendActive = true;
        });
      }
    });
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResendActive = false;
      _resendTimer = 60;
      _isLoading = true;
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);

      if (widget.isForgotPassword) {
        // For forgot password flow, request password reset again
        final hashedOtp = await authRepository.requestPasswordReset(
          context,
          widget.identifier,
          widget.role,
        );

        if (hashedOtp != null && mounted) {
          // Store the new hashed OTP
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('hashedOtp', hashedOtp);

          // Start the timer again
          _startResendTimer();

          showSnackBar(
              context: context, message: 'Reset OTP sent to your email');
        } else {
          showSnackBar(
              context: context,
              message: 'Failed to resend OTP. Please try again.');
        }
      } else {
        // Regular OTP login flow
        await authRepository.sendOtp(
          context,
          widget.identifier,
          widget.role,
          countryCode: widget.countryCode,
        );

        // Start the timer again
        _startResendTimer();

        showSnackBar(context: context, message: 'OTP sent successfully');
      }
    } catch (e) {
      showSnackBar(
          context: context, message: 'Failed to send OTP. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    // Get the complete OTP
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length == 6) {
      setState(() => _isLoading = true);

      try {
        // Call verification API
        final authRepository = ref.read(authRepositoryProvider);

        // For forgot password flow, we just need to verify the OTP is correct
        // We don't need to authenticate the user yet
        if (widget.isForgotPassword) {
          // Just verify the OTP matches what we expect
          bool isVerified = await authRepository.verifyResetOtp(
            context,
            widget.identifier,
            otp,
          );

          if (isVerified) {
            // Clear all OTP fields
            for (var controller in _controllers) {
              controller.clear();
            }

            // OTP verification successful, call the callback to redirect to password reset screen
            widget.onVerificationComplete();
          } else {
            // Clear OTP fields on failure
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();

            showSnackBar(
              context: context,
              message: 'Invalid OTP. Please try again.',
            );
          }
        } else {
          // Regular login flow
          await authRepository.verifyOtp(
            context,
            widget.identifier,
            otp,
            widget.role,
            ref.read(authStateProvider.notifier),
          );

          // Call the callback to notify parent
          widget.onVerificationComplete();
        }
      } catch (e) {
        debugPrint('OTP verification error: ${e.toString()}');

        // Clear OTP fields on error
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        showSnackBar(
          context: context,
          message: 'OTP verification failed. Please try again.',
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      // Show error
      showSnackBar(
        context: context,
        message: 'Please enter the complete 6-digit OTP',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding for keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Make the container take up to 70% of screen height
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        bottom: bottomPadding + 16,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.isForgotPassword ? "Verify Reset Code" : "Enter OTP",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            widget.isForgotPassword
                ? "A 6-digit verification code has been sent to ${widget.identifier}. Please enter it below to reset your password."
                : "A 6-digit OTP has been sent to ${widget.identifier}. Please enter it below.",
            style: TextStyle(
              fontSize: 14,
              color: grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildOtpFields(),
          const SizedBox(height: 30),
          _buildVerifyButton(),
          const SizedBox(height: 20),
          _buildResendButton(),
        ],
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 40,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: grey400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _verifyOTP,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              widget.isForgotPassword ? "Verify" : "Verify OTP",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
    );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: _isResendActive ? _resendOTP : null,
      child: Text(
        _isResendActive ? "Resend OTP" : "Resend in $_resendTimer seconds",
        style: TextStyle(
          color: _isResendActive ? primaryColor : grey400,
          fontSize: 14,
        ),
      ),
    );
  }
}
