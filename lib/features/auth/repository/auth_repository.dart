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

class AuthRepository {
  // sign in with password
  Future<void> signInWithPass(
    BuildContext context,
    String email,
    String password,
    String role,
  ) async {
    try {
      // Select the appropriate API endpoint based on role
      final String apiEndpoint = role == 'Doctor' ? login_api_doc : login_api;

      // Make API request with role-specific endpoint
      Response response = await post(Uri.parse(apiEndpoint),
          body: jsonEncode({
            'email': email,
            'password': password,
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
    try {
      // Select the appropriate API endpoint based on role
      final String apiEndpoint = role == 'Doctor' ? signup_api_doc : signup_api;

      // API request
      Response response = await post(Uri.parse(apiEndpoint),
          body: jsonEncode({
            'email': email,
            'password': password,
            'first_name': firstName,
            'last_name': lastName,
            'phone_number': phonenumber,
            'country_code': countrycode,
          }),
          headers: {
            'Content-Type': 'application/json',
          });

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
      showSnackBar(context: context, message: 'Invalid response format');
    } on TimeoutException {
      showSnackBar(
          context: context,
          message: 'Connection timeout. Please check your internet');
    } catch (e) {
      print("Signup error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Sign up failed. Please try again.');
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
