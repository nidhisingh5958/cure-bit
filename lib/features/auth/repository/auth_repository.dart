// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:CuraDocs/features/auth/repository/api_const.dart';
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

  // sign in with OTP
  Future<void> signInWithOtp(
    BuildContext context,
    String email,
    String otp,
    String role,
  ) async {
    try {
      // API request
      Response response = await post(Uri.parse(loginWithOtp_api_email),
          body: jsonEncode({
            'email': email,
            'otp': otp,
          }),
          headers: {
            'Content-Type': 'application/json',
          });

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
