import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/auth/repository/auth_repository.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:CuraDocs/utils/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginForm extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const LoginForm({Key? key, this.extra}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+91');
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  Country? country;
  late String _role;

  // enum to track login method
  LoginMethod _loginMethod = LoginMethod.email;

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

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _countryCodeController.dispose();
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

        // Pass the login method to the sign-up function
        await authRepository.signInWithPass(
          context,
          _loginMethod == LoginMethod.email
              ? _emailController.text
              : _phoneController.text,
          _passwordController.text,
          _role,
          countryCode: _loginMethod == LoginMethod.phone
              ? _countryCodeController.text
              : null,
        );
        await AppRouter.setAuthenticated(true, _role);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print(e);
      setState(() => _isLoading = false);
    }
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
          // Login Method Toggle
          _buildLoginMethodToggle(),
          const SizedBox(height: 20),

          _loginMethod == LoginMethod.email
              ? _buildEmailField()
              : _buildPhoneField(),

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

  //  Widget to toggle between email and phone login
  Widget _buildLoginMethodToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Email Toggle
        ChoiceChip(
          label: Text(
            'Email',
            style: TextStyle(
              color: _loginMethod == LoginMethod.email
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          selected: _loginMethod == LoginMethod.email,
          onSelected: (_) {
            setState(() {
              _loginMethod = LoginMethod.email;
              // Clear input when switching
              _emailController.clear();
              _phoneController.clear();
            });
          },
          selectedColor: color2,
        ),
        const SizedBox(width: 20),
        // Phone Toggle
        ChoiceChip(
          label: Text(
            'Phone',
            style: TextStyle(
              color: _loginMethod == LoginMethod.phone
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          selected: _loginMethod == LoginMethod.phone,
          onSelected: (_) {
            setState(() {
              _loginMethod = LoginMethod.phone;
              // Clear input when switching
              _phoneController.clear();
              _countryCodeController.clear();
              _passwordController.clear();
            });
          },
          selectedColor: color2,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (email) {
        if (email == null || email.isEmpty) {
          return 'Please enter your email address';
        }
        final emailRegex =
            RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(email)) {
          return 'Please enter a valid email address';
        }
      },
      decoration: InputDecoration(
        hintText: 'Enter your email address',
      ),
      style: TextStyle(
        fontSize: 14,
        color: color1,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      children: [
        IntlPhoneField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onChanged: (phoneField) {
            setState(() {
              _phoneController.text = phoneField.number;
            });
          },
          validator: (phoneField) {
            if (phoneField == null || phoneField.number.isEmpty) {
              return 'Please enter your phone number';
            }
          },
          showCountryFlag: false,
          decoration: InputDecoration(
            hintText: 'Enter your phone number',
            prefixIcon: _loginMethod == LoginMethod.phone
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      _countryCodeController.text,
                      style: TextStyle(color: color1),
                    ),
                  )
                : null,
          ),
          style: TextStyle(
            fontSize: 14,
            color: color1,
          ),
          initialCountryCode: 'IN',
          onCountryChanged: (country) {
            setState(() {
              this.country = Country(
                phoneCode: country.dialCode, // Remove the + symbol
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
        ),
      ],
    );
  }

  // Password field
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

enum LoginMethod {
  email,
  phone,
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
