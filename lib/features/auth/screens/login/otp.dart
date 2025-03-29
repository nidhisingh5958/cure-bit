import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/auth/screens/login/otp_sheet.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:CuraDocs/features/auth/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const OtpScreen({this.extra, Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  bool _isLoading = false;
  late String _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
    // country = Country(
    //   phoneCode: '91',
    //   countryCode: 'IN',
    //   e164Sc: 0,
    //   geographic: true,
    //   level: 1,
    //   name: 'India',
    //   example: '9123456789',
    //   displayName: 'India (IN) [+91]',
    //   displayNameNoCountryCode: 'India (IN)',
    //   e164Key: '91-IN-0',
    // );
  }

  @override
  void dispose() {
    _inputController.dispose();
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

  Future<void> _sendOTP() async {
    if (_inputController.text.isEmpty) {
      showSnackBar(
          context: context, message: 'Please enter your phone number or email');
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
      return 'Please enter your phone number or email';
    }

    // Email validation (simple check for @)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // Phone validation (simple check for numbers only)
    final phoneRegex = RegExp(r'^\d+$');

    // If it's not email or phone, assume it's a user ID
    if (!emailRegex.hasMatch(value) &&
        !phoneRegex.hasMatch(value) &&
        value.length < 3) {
      return 'Please enter a valid phone number or email';
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
                      "To sign in using OTP, please enter your phone number or email.",
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
        hintText: 'Enter Phone Number or Email',
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
