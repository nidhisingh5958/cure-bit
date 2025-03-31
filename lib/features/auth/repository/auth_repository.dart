// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:CuraDocs/features/auth/repository/api_const.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:CuraDocs/utils/routes/router.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';

// Helper method to validate email
bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}

// Helper method to validate phone number
bool _isValidPhoneNumber(String phoneNumber) {
  final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
  return phoneRegex.hasMatch(phoneNumber);
}

String hashedOtp = '';

Future<bool> verify(String hashedPassword, String plainPassword) async {
  return BCrypt.checkpw(plainPassword, hashedPassword);
}

class AuthRepository {
  // sign in with password
  Future<void> signInWithPass(
    BuildContext context,
    String input,
    String password,
    String role, {
    String? countryCode,
  }) async {
    try {
      // Select the appropriate API endpoint based on role
      final String apiEndpoint = role == 'Doctor' ? login_api_doc : login_api;

      print('Email: $input');
      print('Country Code: $countryCode');
      print('Password: $password');

      // Initialize an empty map to hold login payload
      Map<String, dynamic> loginPayload = {};

      if (_isValidEmail(input)) {
        // Email login
        loginPayload = {
          'email': input,
          'password': password,
        };
      } else if (_isValidPhoneNumber(input)) {
        // Phone number login
        loginPayload = {
          'phone_number': input,
          'country_code': countryCode ?? '+91',
          // default country code is of India
          'password': password,
        };
      } else {
        showSnackBar(
            context: context, message: 'Invalid email or phone number');
        return;
      }

      // Make API request with role-specific endpoint
      Response response = await post(Uri.parse(apiEndpoint),
          body: jsonEncode(loginPayload),
          headers: {
            'Content-Type': 'application/json',
          });

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        try {
          // Parse the response body to check for any error messages
          Map<String, dynamic> responseData = jsonDecode(response.body);

          // Check if response contains an error field or success status
          if (responseData.containsKey('error')) {
            showSnackBar(context: context, message: responseData['error']);
            return;
          }

          // Set user as authenticated with the specific role
          await AppRouter.setAuthenticated(true, role);
          showSnackBar(context: context, message: 'Login successful');

          // Router will redirect to appropriate home screen based on role
          if (role == 'Doctor') {
            context.goNamed(RouteConstants.doctorHome);
          } else {
            context.goNamed(RouteConstants.home);
          }
        } catch (e) {
          // Handle JSON parse error
          showSnackBar(
              context: context, message: 'Invalid response from server');
        }
      } else if (response.statusCode == 401) {
        showSnackBar(context: context, message: 'Invalid email or password');
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
      } else {
        showSnackBar(
            context: context, message: 'Login failed. Please try again.');
      }
    } on FormatException {
      showSnackBar(context: context, message: 'Invalid response format');
    } on TimeoutException {
      showSnackBar(
          context: context,
          message: 'Connection timeout. Please check your internet');
    } catch (e) {
      print("Login error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Login failed. Please try again.');
    }
  }

  // send OTP
  Future<void> sendOtp(
    BuildContext context,
    String identifier,
    String role, {
    String? countryCode,
  }) async {
    try {
      // Select the appropriate API endpoint based on role
      final String apiEndpoint =
          role == 'Doctor' ? loginWithOtp_api_doc : loginWithOtp_api;

      print(
          'Sending OTP to $identifier with role $role and country code $countryCode');

      // Initialize an empty map to hold login payload
      Map<String, dynamic> loginPayload = {};

      if (_isValidEmail(identifier)) {
        // Email login
        loginPayload = {
          'email': identifier,
        };
      } else if (_isValidPhoneNumber(identifier)) {
        // Phone number login
        loginPayload = {
          'phone_number': identifier,
          'country_code': countryCode ?? '+91',
          // default country code is of India
        };
      } else {
        showSnackBar(
            context: context, message: 'Invalid email or phone number');
        return;
      }

      Response response = await post(Uri.parse(apiEndpoint),
          body: jsonEncode(loginPayload),
          headers: {
            'Content-Type': 'application/json',
          });

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('API Endpoint: $apiEndpoint');

      // Parse response
      if (response.statusCode == 200) {
        showSnackBar(context: context, message: 'OTP sent successfully');
      } else if (response.statusCode == 400) {
        showSnackBar(context: context, message: 'Invalid input data');
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
      } else {
        showSnackBar(
            context: context, message: 'Failed to send OTP. Please try again.');
      }
    } on FormatException {
      showSnackBar(context: context, message: 'Invalid response format');
    } on TimeoutException {
      showSnackBar(
          context: context,
          message: 'Connection timeout. Please check your internet');
    } catch (e) {
      print("Send OTP error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Failed to send OTP. Please try again.');
    }
  }

  // sign in with OTP
  Future<void> verifyOtp(
    BuildContext context,
    String identifier,
    String otp,
    String role,
  ) async {
    try {
      final String apiEndpoint = role == 'Doctor'
          ? (identifier.contains('@') || identifier.contains(RegExp(r'[a-z]'))
              ? verifyLoginWithOtp_api_email_doc
              : verifyLoginWithOtp_api_email)
          : (identifier.contains(RegExp(r'^\+?[0-9]{10,15}$'))
              ? verifyLoginWithOtp_api_phone_doc
              : verifyLoginWithOtp_api_phone);

      print('Verifying OTP for $identifier with role $role');
      print('OTP: $otp');
      print('API Endpoint: $apiEndpoint');

      // Initialize an empty map to hold login payload
      Map<String, dynamic> loginPayload = {};

      if (_isValidEmail(identifier)) {
        // Email login
        loginPayload = {
          'email': identifier,
          'otp': otp,
        };
      } else if (_isValidPhoneNumber(identifier)) {
        // Phone number login
        loginPayload = {
          'phone_number': identifier,
          'otp': otp,
        };
      } else {
        showSnackBar(
            context: context, message: 'Invalid email or phone number');
        return;
      }

      // API request
      Response response = await post(Uri.parse(apiEndpoint),
          body: jsonEncode({loginPayload}),
          headers: {
            'Content-Type': 'application/json',
          });

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Parse response
      if (response.statusCode == 200) {
        try {
          // Parse the response body to check for any error messages
          Map<String, dynamic> responseData = jsonDecode(response.body);

          // Check if response contains an error field or success status
          if (responseData.containsKey('error')) {
            showSnackBar(context: context, message: responseData['error']);
            return;
          }

          // Set user as authenticated with the specific role
          await AppRouter.setAuthenticated(true, role);
          showSnackBar(context: context, message: 'Login successful');

          // Router will redirect to appropriate home screen based on role
          if (role == 'Doctor') {
            context.goNamed(RouteConstants.doctorHome);
          } else {
            context.goNamed(RouteConstants.home);
          }
        } catch (e) {
          // Handle JSON parse error
          showSnackBar(
              context: context, message: 'Invalid response from server');
        }
      } else if (response.statusCode == 401) {
        showSnackBar(context: context, message: 'Invalid or expired OTP');
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
      } else {
        showSnackBar(
            context: context, message: 'Login failed. Please try again.');
      }
    } on FormatException {
      showSnackBar(context: context, message: 'Invalid response format');
    } on TimeoutException {
      showSnackBar(
          context: context,
          message: 'Connection timeout. Please check your internet');
    } catch (e) {
      print("OTP login error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Login failed. Please try again.');
    }
  }

  // normal sign up
  Future<void> signUp(
    BuildContext context,
    String firstName,
    String lastName,
    String email,
    String countrycode,
    String phonenumber,
    String password,
    String role,
  ) async {
    print('Signup Data:');
    print('First Name: $firstName');
    print('Last Name: $lastName');
    print('Email: $email');
    print('Country Code: $countrycode');
    print('Phone Number: $phonenumber');
    print('Password: $password');
    print('Role: $role');
    try {
      // Select the appropriate API endpoint based on role
      final String apiEndpoint = role == 'Doctor' ? signup_api_doc : signup_api;

      final Map<String, dynamic> payload = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'country_code': countrycode,
        'phone_number': phonenumber,
        'password': password,
      };

      // API request
      final response = await post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // Parse the response body to check for any error messages
          Map<String, dynamic> responseData = jsonDecode(response.body);

          // Check if response contains an error field or success status
          if (responseData.containsKey('error')) {
            showSnackBar(context: context, message: responseData['error']);
            return;
          }

          // Set user as authenticated with the specific role
          await AppRouter.setAuthenticated(true, role);
          showSnackBar(context: context, message: 'Sign up successful');

          // Router will redirect to appropriate home screen based on role
          if (role == 'Doctor') {
            context.goNamed(RouteConstants.doctorHome);
          } else {
            context.goNamed(RouteConstants.home);
          }
        } catch (e) {
          // Handle JSON parse error
          showSnackBar(
              context: context, message: 'Invalid response from server');
        }
      } else if (response.statusCode == 400) {
        // Try to parse validation errors
        try {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          String errorMessage = responseData.containsKey('error')
              ? responseData['error']
              : 'Sign up failed. Please check your information.';
          showSnackBar(context: context, message: errorMessage);
        } catch (e) {
          showSnackBar(context: context, message: 'Invalid input data');
        }
      } else if (response.statusCode == 409) {
        showSnackBar(
            context: context, message: 'User with this email already exists');
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
      } else {
        showSnackBar(
            context: context, message: 'Sign up failed. Please try again.');
      }
    } on FormatException {
      print(email);
      showSnackBar(
        context: context,
        message: 'Invalid response format',
      );
    } on TimeoutException {
      showSnackBar(
          context: context,
          message: 'Connection timeout. Please check your internet');
    } catch (e) {
      print("Signup error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Sign up failed. Please try again. $e');
    }
  }

  Future<bool> signupOtp(
    BuildContext context,
    String identifier,
    String? countryCode,
  ) async {
    try {
      final String apiEndpoint = signupOtp_api;

      print('Sending OTP to $identifier with country code $countryCode');
      print('API Endpoint: $apiEndpoint');

      // Initialize an empty map to hold login payload
      Map<String, dynamic> payload = {};

      if (_isValidEmail(identifier)) {
        // Email login
        payload = {
          'email': identifier,
        };
      } else if (_isValidPhoneNumber(identifier)) {
        // Phone number login
        payload = {
          'phone_number': identifier,
          'country_code': countryCode ?? '+91',
        };
      } else {
        showSnackBar(
            context: context, message: 'Invalid email or phone number');
        return false;
      }

      // API request
      Response response = await post(Uri.parse(apiEndpoint),
          body: jsonEncode(payload),
          headers: {
            'Content-Type': 'application/json',
          });

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Parse response
      if (response.statusCode == 200) {
        try {
          // Parse the response body to check for any error messages
          Map<String, dynamic> responseData = jsonDecode(response.body);

          // Check if response contains an error field
          if (responseData.containsKey('error')) {
            showSnackBar(context: context, message: responseData['error']);
            return false;
          } else {
            // Extract the hashed OTP from the response
            if (responseData.containsKey('otp')) {
              hashedOtp = responseData['otp'];
              showSnackBar(context: context, message: 'OTP sent successfully');
              return true;
            } else {
              showSnackBar(
                  context: context, message: 'OTP not received from server');
              return false;
            }
          }
        } catch (e) {
          // Handle JSON parse error
          showSnackBar(
              context: context, message: 'Invalid response from server');
          return false;
        }
      } else {
        String errorMsg = 'Failed to send OTP. Please try again.';

        if (response.statusCode == 401) {
          errorMsg = 'Authentication failed';
        } else if (response.statusCode >= 500) {
          errorMsg = 'Server error. Please try again later';
        }

        showSnackBar(context: context, message: errorMsg);
        return false;
      }
    } catch (e) {
      print("Signup OTP error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Failed to send OTP. Please try again.');
      return false;
    }
  }

  Future<bool> verifySignupOtp(
    BuildContext context,
    String identifier,
    String plainOtp,
    String? countryCode,
  ) async {
    try {
      if (!_isValidEmail(identifier) && !_isValidPhoneNumber(identifier)) {
        showSnackBar(
            context: context, message: 'Invalid email or phone number');
        return false;
      }

      // Use the verify function to check the OTP
      bool isMatch = await verify(hashedOtp, plainOtp);

      if (isMatch) {
        print('OTP verified successfully');
        return true;
      } else {
        showSnackBar(context: context, message: 'Invalid OTP');
        return false;
      }
    } catch (e) {
      print("Verify OTP error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Verification failed. Please try again.');
      return false;
    }
  }

// sign out method
  Future<void> signOut(BuildContext context) async {
    try {
      // Clear authentication state
      await AppRouter.setAuthenticated(false, '');
      showSnackBar(context: context, message: 'Signed out successfully');
    } catch (e) {
      showSnackBar(
          context: context, message: 'Sign out failed. Please try again.');
    }
  }
}
