import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:country_picker/country_picker.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChecked = false;
  bool _isLoading = false;

  String name = '';
  String email = '';
  String phone = '';
  String password = '';
  Country? country;

// submit form
  void _submitForm() async {
    if (_formKey.currentState!.validate() && _isChecked) {
      setState(() => _isLoading = true);

      try {
        await Future.delayed(const Duration(seconds: 2)); // Simulating API call
        _formKey.currentState!.save();

        // Navigate to profile setup
        if (mounted) {
          context.goNamed(RouteConstants.signUpProfile);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Privacy Policy'),
          backgroundColor: error,
        ),
      );
    }
  }

// country picker
  void pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country _country) {
        setState(() => country = _country);
      },
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(
            hint: 'Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
            onSaved: (value) => name = value!,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onSaved: (value) => email = value!,
          ),
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
            isVisible: _isConfirmPasswordVisible,
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

  Widget _buildInputField({
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
      ),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

// phonenumber field
  Widget _buildPhoneNumberField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Phone Number',
        prefixText: country != null ? '+${country!.phoneCode} ' : '+00 ',
        prefixStyle: TextStyle(
          fontSize: 14,
          color: color1,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.arrow_drop_down,
            color: color2,
          ),
          onPressed: pickCountry,
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
      onSaved: (value) {
        // Save the full phone number including country code
        String countryCode = country != null ? '+${country!.phoneCode}' : '+00';
        phone = '$countryCode${value!}';
      },
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
