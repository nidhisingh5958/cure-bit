// File: auth_repository.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:CuraDocs/features/auth/repository/api_const.dart';
import 'package:CuraDocs/models/user_model.dart';
import 'package:CuraDocs/utils/providers/auth_providers.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}

bool _isValidPhoneNumber(String phoneNumber) {
  // Allow any sequence of digits (no minimum length check)
  final phoneRegex = RegExp(r'^\d+$');
  return phoneRegex.hasMatch(phoneNumber);
}

String hashedOtp = '';

// Function to verify the hashed password
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
    required AuthStateNotifier notifier,
  }) async {
    try {
      // Select the appropriate API endpoint based on role
      final String apiEndpoint = role == 'Doctor' ? login_api_doc : login_api;

      debugPrint('Email: $input');
      debugPrint('Country Code: $countryCode');
      debugPrint('Password: $password');

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

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

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
          notifier.setAuthenticated(true, role);

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
      debugPrint("Login error: ${e.toString()}");
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

      debugPrint(
          'Sending OTP to $identifier with role $role and country code $countryCode');

      // Initialize an empty map to hold login payload
      Map<String, dynamic> loginPayload = {};

      if (_isValidEmail(identifier)) {
        // Email login
        loginPayload = {
          'email': identifier,
        };
      } else if (_isValidPhoneNumber(identifier)) {
        loginPayload = {
          'country_code': countryCode ?? '+91',
          'phone_number': identifier.trim(), // Remove any whitespace
        };
      } else {
        showSnackBar(context: context, message: 'Invalid $identifier');
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
      };

      debugPrint('Request payload: ${jsonEncode(loginPayload)}');

      Response response = await post(
        Uri.parse(apiEndpoint),
        body: jsonEncode(loginPayload),
        headers: headers,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('API Endpoint: $apiEndpoint');

      // Parse response
      if (response.statusCode == 200) {
        // Store the hashed OTP if available in the response
        try {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData.containsKey('otp')) {
            hashedOtp = responseData['otp'];
            debugPrint('Received hashed OTP: $hashedOtp');
          }
        } catch (e) {
          debugPrint('Error parsing response: ${e.toString()}');
        }

        showSnackBar(context: context, message: 'OTP sent successfully');
      } else if (response.statusCode == 400) {
        showSnackBar(context: context, message: 'Invalid input data');
      } else if (response.statusCode == 422) {
        // Added specific handling for 422 Unprocessable Entity
        showSnackBar(
            context: context,
            message: 'Invalid data format. Please check your inputs.');
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
      debugPrint("Send OTP error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Failed to send OTP. Please try again.');
    }
  }

  Future<void> verifyOtp(
    BuildContext context,
    String identifier,
    String otp,
    String role,
    AuthStateNotifier notifier,
  ) async {
    try {
      debugPrint('Verifying OTP for $identifier with role $role');
      debugPrint('Entered OTP: $otp');
      debugPrint('Stored hashed OTP: $hashedOtp');

      // First check if we have the hashed OTP to verify against
      if (hashedOtp.isEmpty) {
        debugPrint("No hashed OTP found, falling back to API verification");

        await _verifyOtpWithApi(context, identifier, otp, role, notifier);
        return;
      }

      // Verify the OTP using BCrypt
      bool isMatch = await verify(hashedOtp, otp);
      debugPrint('OTP verification result: $isMatch');

      if (isMatch) {
        notifier.setAuthenticated(true, role);

        showSnackBar(context: context, message: 'Login successful');

        // Router will redirect to appropriate home screen based on role
        if (role == 'Doctor') {
          context.goNamed(RouteConstants.doctorHome);
        } else {
          context.goNamed(RouteConstants.home);
        }
      } else {
        showSnackBar(context: context, message: 'Invalid or expired OTP');
      }
    } catch (e) {
      debugPrint("OTP verification error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Verification failed. Please try again.');
    }
  }

  // Original API-based OTP verification as fallback
  Future<void> _verifyOtpWithApi(
    BuildContext context,
    String identifier,
    String otp,
    String role,
    AuthStateNotifier notifier,
  ) async {
    try {
      final String apiEndpoint = role == 'Doctor'
          ? (identifier.contains('@') || identifier.contains(RegExp(r'[a-z]'))
              ? verifyLoginWithOtp_api_email_doc
              : verifyLoginWithOtp_api_email)
          : (identifier.contains(RegExp(r'^\+?[0-9]{10,15}$'))
              ? verifyLoginWithOtp_api_phone_doc
              : verifyLoginWithOtp_api_phone);

      debugPrint('API Verification - API Endpoint: $apiEndpoint');

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
          body: jsonEncode(loginPayload),
          headers: {
            'Content-Type': 'application/json',
          });

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

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
          notifier.setAuthenticated(true, role);

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
    } catch (e) {
      debugPrint("API OTP verification error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Verification failed. Please try again.');
    }
  }

  // normal sign up
  Future<UserModel> signUp(
    BuildContext context,
    String firstName,
    String lastName,
    String email,
    String countrycode,
    String phonenumber,
    String password,
    String role,
    AuthStateNotifier notifier,
  ) async {
    debugPrint('Signup Data:');
    debugPrint('First Name: $firstName');
    debugPrint('Last Name: $lastName');
    debugPrint('Email: $email');
    debugPrint('Country Code: $countrycode');
    debugPrint('Phone Number: $phonenumber');
    debugPrint('Password: $password');
    debugPrint('Role: $role');
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

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode != 201) {
        throw jsonDecode(response.body)['error'] ?? 'Unknown error';
      } else {
        debugPrint('Signup successful');
      }

      // Set user as authenticated with the specific role
      notifier.setAuthenticated(true, role);

      showSnackBar(context: context, message: 'Sign up successful');

      // Router will redirect to appropriate home screen based on role
      if (role == 'Doctor') {
        context.goNamed(RouteConstants.doctorHome);
      } else {
        context.goNamed(RouteConstants.home);
      }

      return UserModel.fromJson(response.body);
    } on FormatException {
      debugPrint(email);
      showSnackBar(
        context: context,
        message: 'Invalid response format',
      );
      throw Exception('Invalid response format');
    } on TimeoutException {
      showSnackBar(
          context: context,
          message: 'Connection timeout. Please check your internet');
      throw Exception('Connection timeout');
    } catch (e) {
      debugPrint("Signup error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Sign up failed. Please try again. $e');
      throw Exception('Sign up failed');
    }
  }

  Future<bool> signupOtp(
    BuildContext context,
    String identifier,
    String? countryCode,
  ) async {
    try {
      final String apiEndpoint = signupOtp_api;

      debugPrint('Sending OTP to $identifier with country code $countryCode');
      debugPrint('API Endpoint: $apiEndpoint');

      // Initialize an empty map to hold payload
      Map<String, dynamic> payload = {};

      if (_isValidEmail(identifier)) {
        // Email payload
        payload = {
          'email': identifier,
        };
        debugPrint('Sending email OTP request with payload: $payload');
      } else if (_isValidPhoneNumber(identifier)) {
        // Phone number payload - Make sure country code is included
        payload = {
          'phone_number': identifier,
          'country_code': countryCode ?? '+91',
        };
        debugPrint('Sending phone OTP request with payload: $payload');
      } else {
        showSnackBar(
            context: context, message: 'Invalid email or phone number');
        return false;
      }

      // API request with proper headers
      Response response = await post(
        Uri.parse(apiEndpoint),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

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
          debugPrint('JSON parse error: ${e.toString()}');
          showSnackBar(
              context: context, message: 'Invalid response from server');
          return false;
        }
      } else {
        String errorMsg = 'Failed to send OTP. Please try again.';

        if (response.statusCode == 400) {
          errorMsg = 'Invalid request data';
        } else if (response.statusCode == 401) {
          errorMsg = 'Authentication failed';
        } else if (response.statusCode >= 500) {
          errorMsg = 'Server error. Please try again later';
        }

        debugPrint('Error: $errorMsg');
        showSnackBar(context: context, message: errorMsg);
        return false;
      }
    } catch (e) {
      debugPrint("Signup OTP error: ${e.toString()}");
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
      // debugPrint debug information
      debugPrint('Verifying OTP for: $identifier');
      debugPrint('Country code: $countryCode');
      debugPrint('Plain OTP: $plainOtp');
      debugPrint('Hashed OTP: $hashedOtp');

      if (hashedOtp.isEmpty) {
        showSnackBar(
            context: context,
            message: 'No OTP was sent. Please request OTP first');
        return false;
      }

      if (!_isValidEmail(identifier) && !_isValidPhoneNumber(identifier)) {
        showSnackBar(
            context: context, message: 'Invalid email or phone number');
        return false;
      }

      // Use the verify function to check the OTP
      bool isMatch = await verify(hashedOtp, plainOtp);
      debugPrint('OTP match result: $isMatch');

      if (isMatch) {
        debugPrint('OTP verified successfully');
        showSnackBar(context: context, message: 'OTP verified successfully');
        return true;
      } else {
        showSnackBar(context: context, message: 'Invalid OTP');
        return false;
      }
    } catch (e) {
      debugPrint("Verify OTP error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Verification failed. Please try again.');
      return false;
    }
  }

  // forgot password method
  Future<void> resetPassword({
    required BuildContext context,
    required String identifier,
    required String password,
    required String role,
    required AuthStateNotifier notifier,
  }) async {
    try {
      final String apiEndpoint =
          role == 'Doctor' ? createNewPassword_api_doc : createNewPassword_api;

      debugPrint('Resetting password for $identifier with role $role');
      debugPrint('API Endpoint: $apiEndpoint');

      // Create the payload
      final Map<String, dynamic> payload = {
        'email': identifier,
        'new_password': password,
        'confirm_password': password,
      };

      // API request
      Response response = await post(
        Uri.parse(apiEndpoint),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      // Parse response
      if (response.statusCode == 200) {
        showSnackBar(
            context: context,
            message:
                'Password reset successfully. Please login with your new password.');
        context.goNamed(RouteConstants.login);
      } else if (response.statusCode == 400) {
        showSnackBar(context: context, message: 'Invalid input data');
      } else if (response.statusCode == 401) {
        showSnackBar(context: context, message: 'Invalid or expired token');
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
      } else {
        showSnackBar(
            context: context,
            message: 'Failed to reset password. Please try again.');
      }
    } catch (e) {
      debugPrint("Password reset error: ${e.toString()}");
      showSnackBar(
          context: context,
          message: 'Failed to reset password. Please try again.');
    }
  }

  Future<String?> requestPasswordReset(
    BuildContext context,
    String email,
    String role,
  ) async {
    try {
      // Select the appropriate API endpoint based on role
      final String apiEndpoint =
          role == 'Doctor' ? resetPassword_api_doc : resetPassword_api;

      debugPrint('Requesting password reset for $email with role $role');
      debugPrint('API Endpoint: $apiEndpoint');

      // Create the payload
      final Map<String, dynamic> payload = {
        'email': email,
      };

      // API request
      Response response = await post(
        Uri.parse(apiEndpoint),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      // Parse response
      if (response.statusCode == 200) {
        try {
          // Parse the response body to get the token
          Map<String, dynamic> responseData = jsonDecode(response.body);

          // Check if response contains a token
          if (responseData.containsKey('hashedOtp')) {
            showSnackBar(
                context: context,
                message: 'Password reset requested successfully');
            return responseData['hashedOtp'];
          } else {
            showSnackBar(
                context: context, message: 'Token not received from server');
            return null;
          }
        } catch (e) {
          showSnackBar(
              context: context, message: 'Invalid response from server');
          return null;
        }
      } else {
        String errorMsg = 'Failed to request password reset. Please try again.';

        if (response.statusCode == 404) {
          errorMsg = 'Email not found';
        } else if (response.statusCode >= 500) {
          errorMsg = 'Server error. Please try again later';
        }

        showSnackBar(context: context, message: errorMsg);
        return null;
      }
    } catch (e) {
      debugPrint("Password reset request error: ${e.toString()}");
      showSnackBar(
          context: context,
          message: 'Failed to request password reset. Please try again.');
      return null;
    }
  }

  // log out method
  Future<void> logOut(
    BuildContext context,
    AuthStateNotifier notifier,
  ) async {
    try {
      // Clear authentication state
      // notifier.signOut();

      showSnackBar(context: context, message: 'Logged out successfully');
    } catch (e) {
      showSnackBar(
          context: context, message: 'Log out failed. Please try again.');
    }
  }
}
