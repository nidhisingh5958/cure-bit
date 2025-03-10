import 'package:CuraDocs/features/auth/repository/api_const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:CuraDocs/utils/routes/router.dart';
import 'package:CuraDocs/utils/snackbar.dart';

class AuthRepository {
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

      await Future.delayed(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        // Set user as authenticated with the specific role
        await AppRouter.setAuthenticated(true, role);
        showSnackBar(context: context, message: 'Login successful');
        // Router will automatically redirect to appropriate home screen based on role
      } else {
        showSnackBar(
            context: context, message: 'Login failed. Please try again.');
      }
    } catch (e) {
      print("failed");
      showSnackBar(
          context: context, message: 'Login failed. Please try again.');
    }
  }

  Future<void> signInWithOtp(
    BuildContext context,
    String email,
    String otp,
    String role,
  ) async {
    try {
      // Simulate network request
      Response response = await post(Uri.parse(loginWithOtp_api),
          body: jsonEncode({
            'email': email,
            'otp': otp,
          }),
          headers: {
            'Content-Type': 'application/json',
          });
      await Future.delayed(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        // Set user as authenticated
        await AppRouter.setAuthenticated(true, role);
        showSnackBar(context: context, message: 'Login successful');
        // Router will automatically redirect to home screen
      } else {
        showSnackBar(
            context: context, message: 'Login failed. Please try again.');
      }
    } catch (e) {
      print("failed");
      showSnackBar(
          context: context, message: 'Login failed. Please try again.');
    }
  }

  Future<void> signUp(
    BuildContext context,
    String fullName,
    String email,
    String phonenumber,
    String password,
    String role,
  ) async {
    try {
      // Simulate network request
      Response response = await post(Uri.parse(signup_api),
          body: jsonEncode({
            'full_name': fullName,
            'email': email,
            'phone_number': phonenumber,
            'password': password,
          }),
          headers: {
            'Content-Type': 'application/json',
          });
      await Future.delayed(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        // Set user as authenticated
        await AppRouter.setAuthenticated(true, role);
        showSnackBar(context: context, message: 'Sign up successful');
        // Router will automatically redirect to home screen
      } else {
        showSnackBar(
            context: context, message: 'Sign up failed. Please try again.');
      }
    } catch (e) {
      print("failed");
      showSnackBar(
          context: context, message: 'Sign up failed. Please try again.');
    }
  }

  // Add a sign out method
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
