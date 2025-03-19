import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:CuraDocs/features/auth/repository/auth_repository.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _inputController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_inputController.text.isEmpty) {
      showSnackBar(
          context: context,
          message: 'Please enter your phone number, user ID, or email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Here you would call your API to send the OTP
      // For example:
      // await AuthRepository().sendOTP(context, _inputController.text);

      // For now, we'll simulate success
      await Future.delayed(Duration(seconds: 1));

      // Show success message
      showSnackBar(context: context, message: 'OTP sent successfully');

      setState(() => _isLoading = false);

      // Show the OTP entry bottom sheet
      _showOtpBottomSheet();
    } catch (e) {
      showSnackBar(
          context: context, message: 'Failed to send OTP. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  void _showOtpBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return OtpEntrySheet(
          identifier: _inputController.text,
          onVerificationComplete: () {
            // Handle successful verification
            Navigator.pop(context); // Close the bottom sheet
            // Navigate to the next screen or perform other actions
          },
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: color1),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    // headings and intro
                    Text(
                      "OTP Verification",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "To sign in using OTP, please enter your phone number, user ID, or email.",
                      style: TextStyle(
                        fontSize: 14,
                        color: color3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildInputField(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildSendOtpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return TextFormField(
      controller: _inputController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: _validateInput,
      decoration: InputDecoration(
        hintText: 'Enter Phone Number, CIN, or Email',
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
      ),
    );
  }

  Widget _buildSendOtpButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _sendOTP,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              'Send OTP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}

// OTP entry bottom sheet
class OtpEntrySheet extends StatefulWidget {
  final String identifier;
  final VoidCallback onVerificationComplete;

  const OtpEntrySheet({
    Key? key,
    required this.identifier,
    required this.onVerificationComplete,
  }) : super(key: key);

  @override
  State<OtpEntrySheet> createState() => _OtpEntrySheetState();
}

class _OtpEntrySheetState extends State<OtpEntrySheet> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isResendActive = false;
  int _resendTimer = 30;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
      _resendTimer = 30;
      _isLoading = true;
    });

    try {
      // Here you would call your API to resend the OTP
      // For example:
      // await AuthRepository().sendOTP(context, widget.identifier);

      // For now, we'll simulate success
      await Future.delayed(Duration(seconds: 1));

      showSnackBar(context: context, message: 'OTP resent successfully');
      setState(() => _isLoading = false);
      _startResendTimer();
    } catch (e) {
      showSnackBar(
          context: context, message: 'Failed to resend OTP. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    // Get the complete OTP
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length == 6) {
      setState(() => _isLoading = true);

      try {
        // Call your verification API
        final authRepository = AuthRepository();

        // For example, assuming your app uses the role from somewhere
        String role =
            'Patient'; // This should come from your app state or route param

        await authRepository.signInWithOtp(
          context,
          widget.identifier,
          otp,
          role,
        );

        // Call the callback to notify parent
        widget.onVerificationComplete();
      } catch (e) {
        showSnackBar(
          context: context,
          message: 'OTP verification failed. Please try again.',
        );
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
            "Enter OTP",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            "We have sent an OTP to your registered mobile number and email, please enter any one of them.",
            style: TextStyle(
              fontSize: 14,
              color: color3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildOtpFields(),
          const SizedBox(height: 30),
          _buildVerifyButton(),
          const SizedBox(height: 20),
          if (!_isResendActive) ...[
            Center(
              child: Text(
                'Resend code in ${_resendTimer}s',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14,
                ),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: _resendOTP,
              child: Text(
                'Resend Code',
                style: TextStyle(
                  color: color2,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 45,
          height: 60,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: color3,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: color2,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // When a digit is entered
                if (index < 5) {
                  // Move to next field if this isn't the last one
                  _focusNodes[index + 1].requestFocus();
                } else {
                  // This is the last field, unfocus to hide keyboard
                  _focusNodes[index].unfocus();
                  // Auto-verify when all digits are entered
                  final otp = _controllers.map((c) => c.text).join();
                  if (otp.length == 6) {
                    _verifyOTP();
                  }
                }
              } else if (value.isEmpty && index > 0) {
                // When a digit is deleted, move to previous field
                _focusNodes[index - 1].requestFocus();
              }
            },
            style: TextStyle(
                fontSize: 16, color: color1, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            showCursor: true, // Show cursor for better visibility
            cursorColor: color3,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _verifyOTP,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              'Verify',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
