import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignUpForm extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const SignUpForm({super.key, this.extra});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEmailVerified = false;
  bool _showOtpField = false;
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isPhoneVerified = false;
  bool _showPhoneOtpField = false;
  final _phoneOtpController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChecked = false;
  bool _isLoading = false;
  bool _isVerifyingEmail = false;
  bool _isVerifyingPhone = false;

  String firstname = '';
  String lastname = '';
  String email = '';
  String phone = '';
  String password = '';
  Country? country;
  late String _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
    country = Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'India',
      example: '9123456789',
      displayName: 'India (IN) [+91]',
      displayNameNoCountryCode: 'India (IN)',
      e164Key: '91-IN-0',
    );
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

// submit form
  void _submitForm() async {
    if (!_formKey.currentState!.validate() || !_isChecked) {
      // Show message if terms not checked
      if (!_isChecked) {
        showSnackBar(
          context: context,
          message: 'Please accept the Terms and Conditions',
        );
      }
      return;
    }

    // Only proceed if both email and phone are verified
    if (!_isEmailVerified) {
      showSnackBar(
        context: context,
        message: 'Please verify your email before continuing',
      );
      return;
    }

    if (!_isPhoneVerified) {
      showSnackBar(
        context: context,
        message: 'Please verify your phone number before continuing',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackBar(
        context: context,
        message: 'Passwords do not match',
      );
      return;
    }

    if (country == null) {
      showSnackBar(
        context: context,
        message: 'Please select a country code',
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final authRepository = AuthRepository();
      await authRepository.signUp(
        context,
        _firstnameController.text,
        _lastnameController.text,
        _emailController.text,
        country!.phoneCode,
        _phoneController.text,
        _passwordController.text,
        _role,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        message: 'Error during signup: ${e.toString()}',
      );
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _phoneOtpController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _requestEmailOtp() async {
    // Validate email before showing OTP field
    final emailValue = _emailController.text;
    if (emailValue.isNotEmpty &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailValue)) {
      setState(() {
        _showOtpField = true;
      });

      // Here you would typically call your API to send OTP
      // For demo purposes, we'll just use a delay
      showSnackBar(
        context: context,
        message: 'OTP sent to your email',
      );
    } else {
      showSnackBar(context: context, message: 'Please enter a valid email');
    }
  }

// Add this method to verify OTP
  Future<void> _verifyEmailOtp() async {
    // In a real app, you'd verify the OTP with your backend
    // For this example, we'll just simulate verification

    setState(() {
      _isVerifyingEmail = true;
    });

    try {
      //  await authRepository.verifyEmailOtp(_emailController.text, _otpController.text);

      // For demo, we'll consider "123456" as correct OTP
      if (_otpController.text == "123456") {
        setState(() {
          _isEmailVerified = true;
          _showOtpField = false; // Hide OTP field after verification
        });
        showSnackBar(
          context: context,
          message: 'Email verified successfully',
        );
      } else {
        showSnackBar(
          context: context,
          message: 'Invalid OTP, please try again',
        );
      }
    } finally {
      setState(() {
        _isVerifyingEmail = false;
      });
    }
  }

  //  request Phone OTP
  Future<void> _requestPhoneOtp() async {
    // Validate phone before showing OTP field
    final phoneValue = _phoneController.text;
    if (phoneValue.isNotEmpty) {
      setState(() {
        _showPhoneOtpField = true;
      });

      // Here you would typically call your API to send OTP
      showSnackBar(
        context: context,
        message: 'OTP sent to +${country?.phoneCode ?? '00'} $phoneValue',
      );
    } else {
      showSnackBar(
        context: context,
        message: 'Please enter a valid phone number',
      );
    }
  }

// verify Phone OTP
  Future<void> _verifyPhoneOtp() async {
    // In a real app, you'd verify the OTP with your backend

    setState(() {
      _isVerifyingPhone = true;
    });

    try {
      //  await authRepository.verifyEmailOtp(_emailController.text, _otpController.text);

      // For demo, we'll consider "123456" as correct OTP
      if (_phoneOtpController.text == "123456") {
        setState(() {
          _isPhoneVerified = true;
          _showPhoneOtpField = false; // Hide OTP field after verification
        });
        showSnackBar(
          context: context,
          message: 'Phone number verified successfully',
        );
      } else {
        showSnackBar(
          context: context,
          message: 'Invalid OTP, please try again',
        );
      }
    } finally {
      setState(() {
        _isVerifyingPhone = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNameField(),
          const SizedBox(height: 14),
          _buildEmailFieldWithVerification(),
          const SizedBox(height: 14),
          _buildPhoneNumberField(),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _passwordController,
            hint: 'Password',
            isVisible: _isPasswordVisible,
            onVisibilityToggle: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _confirmPasswordController,
            hint: 'Confirm Password',
            isVisible: _isConfirmPasswordVisible, // This is correct
            onVisibilityToggle: () {
              setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
            },
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTermsCheckbox(),
          const SizedBox(height: 20),
          _buildSignUpButton(),
        ],
      ),
    );
  }

// name field
  Widget _buildNameField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: _firstnameController,
            decoration: InputDecoration(
              hintText: 'First Name',
            ),
            style: TextStyle(
              fontSize: 14,
              color: color1,
            ),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
            onSaved: (value) => firstname = value!,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _lastnameController,
            decoration: InputDecoration(
              hintText: 'Last Name',
            ),
            style: TextStyle(
              fontSize: 14,
              color: color1,
            ),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
            onSaved: (value) => lastname = value!,
          ),
        ),
      ],
    );
  }

// email field with verification
  Widget _buildEmailFieldWithVerification() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  suffixIcon: _isEmailVerified
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : (!_showOtpField && _emailController.text.isNotEmpty
                          ? TextButton(
                              onPressed: _requestEmailOtp,
                              child: Text('Verify',
                                  style:
                                      TextStyle(color: color3, fontSize: 14)),
                            )
                          : null),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: color1,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  if (!_isEmailVerified) {
                    return 'Please verify your email';
                  }
                  return null;
                },
                onChanged: (value) {
                  // If email is changed after verification, reset verification
                  if (_isEmailVerified) {
                    setState(() {
                      _isEmailVerified = false;
                    });
                  }
                },
                onSaved: (value) => email = value!,
              ),
            ),
            // if (_isEmailVerified)
            //   Padding(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            //     child: Container(
            //       width: 12,
            //       height: 12,
            //       decoration: const BoxDecoration(
            //         color: Colors.green,
            //         shape: BoxShape.circle,
            //       ),
            //     ),
            //   ),
          ],
        ),

        // OTP field that appears conditionally
        if (_showOtpField)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      hintText: 'Enter OTP',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: color3,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: color1,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    buildCounter: (context,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isVerifyingEmail ? null : _verifyEmailOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  child: _isVerifyingEmail
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: color4),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: color4,
                            fontSize: 14,
                          ),
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }

// phonenumber field with verification
  Widget _buildPhoneNumberField() {
    return Column(
      children: [
        IntlPhoneField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: 'Phone Number',
            suffixIcon: _isPhoneVerified
                ? const Icon(Icons.check_circle, color: Colors.green)
                : (!_showPhoneOtpField && _phoneController.text.isNotEmpty
                    ? TextButton(
                        onPressed: _requestPhoneOtp,
                        child: Text('Verify', style: TextStyle(color: color3)),
                      )
                    : null),
          ),
          initialCountryCode: 'IN', // Default to India
          style: TextStyle(
            fontSize: 14,
            color: color1,
          ),
          onChanged: (phone) {
            // If phone is changed after verification, reset verification
            if (_isPhoneVerified) {
              setState(() {
                _isPhoneVerified = false;
              });
            }
            // Update the phone controller with just the number part
            _phoneController.text = phone.number;
          },
          onCountryChanged: (country) {
            setState(() {
              this.country = Country(
                phoneCode: country.dialCode
                    .replaceAll('+', ''), // Along with + sign country code
                countryCode: country.code,
                e164Sc: 0,
                geographic: true,
                level: 1,
                name: country.name,
                example: '',
                displayName:
                    '${country.name} (${country.code}) [${country.dialCode}]',
                displayNameNoCountryCode: '${country.name} (${country.code})',
                e164Key: '${country.dialCode.substring(1)}-${country.code}-0',
              );
            });
          },
          validator: (phoneField) {
            if (phoneField == null || phoneField.number.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!_isPhoneVerified) {
              return 'Please verify your phone number';
            }
            return null;
          },
        ),

        // OTP field that appears conditionally
        if (_showPhoneOtpField)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneOtpController,
                    decoration: InputDecoration(
                      hintText: 'Enter Phone OTP',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: color3,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: color1,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    buildCounter: (context,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isVerifyingPhone ? null : _verifyPhoneOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  child: _isVerifyingPhone
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: color4),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(color: color4, fontSize: 14),
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }

// password field
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
            color: color2,
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
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

// terms and conditions
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (value) => setState(() => _isChecked = value!),
          activeColor: color3,
          focusColor: color3,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isChecked = !_isChecked),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: color2, fontSize: 14),
                children: [
                  const TextSpan(text: 'Accept '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      color: color1,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  // const TextSpan(text: ' and '),
                  // TextSpan(
                  //   text: 'Privacy Policy',
                  //   style: TextStyle(
                  //     color: primary,
                  //     decoration: TextDecoration.underline,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

// sign up button
  Widget _buildSignUpButton() {
    return SizedBox(
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        child: _isLoading
            ? const CircularProgressIndicator(color: color4)
            : const Text(
                'Sign Up',
              ),
      ),
    );
  }
}
