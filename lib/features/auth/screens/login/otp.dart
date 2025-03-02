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

  Future<void> _verify() async {
    //   if (_formKey.currentState!.validate()) {
    //     setState(() => _isLoading = true);

    //     final authRepository = AuthRepository();
    //     await authRepository.signInWithPass(
    //       context,
    //       _emailController.text,
    //     );

    //     setState(() => _isLoading = false);
    //   }
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
                      "We have sent an OTP to your registered mobile number and email, please enter any one of them.",
                      style: TextStyle(
                        fontSize: 14,
                        color: color3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildOtpFields(),
              const SizedBox(height: 40),
              _buildVerifyButton(),
              const SizedBox(height: 26),
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
                  onPressed: () {
                    setState(() {
                      _isResendActive = false;
                      _resendTimer = 30;
                    });
                    _startResendTimer();
                    // Resend OTP logic
                  },
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
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: () {
        // Get the complete OTP
        final otp = _controllers.map((c) => c.text).join();
        // Verify OTP logic
        if (otp.length == 6) {
          // Proceed with verification
          _isLoading ? null : _verify();
        } else {
          // Show error
          showSnackBar(
            context: context,
            message: 'Please enter the complete 6-digit OTP',
          );
        }
      },
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Verify',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 50,
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
}
