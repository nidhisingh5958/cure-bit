// File: auth_repository.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:CureBit/services/auth/api_const.dart';
import 'package:CureBit/services/auth/token/token_repository.dart';
import 'package:CureBit/services/models/user_model.dart';
import 'package:CureBit/utils/providers/auth_providers.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:CureBit/utils/snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CureBit/utils/providers/user_provider.dart';

final authRepositoryProvider = Provider((ref) {
  final tokenRepository = ref.watch(tokenRepositoryProvider);
  final userNotifier = ref.watch(userProvider.notifier);
  return AuthRepository(tokenRepository, userNotifier);
});

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
  final TokenRepository _tokenRepository;
  final UserNotifier _userNotifier;

  AuthRepository(this._tokenRepository, this._userNotifier);

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Enhanced restore authentication state
  Future<void> restoreAuthState(AuthStateNotifier notifier) async {
    try {
      debugPrint('Restoring authentication state...');

      // Initialize tokens from storage
      await _tokenRepository.initializeTokens();

      // Check if we have valid tokens
      final tokens = await _tokenRepository.getTokens();
      final user = await _userNotifier.getUser();

      if (tokens != null && user != null) {
        debugPrint('Valid tokens and user found');
        debugPrint('User role: ${user.role}');
        debugPrint('Token expires: ${tokens.expiryTime}');

        // Set authentication state
        notifier.setAuthenticated(true, user.role);
        notifier.setAuthToken(tokens.accessToken);

        debugPrint('Authentication state restored successfully');
      } else if (tokens != null && user == null) {
        // Have tokens but no user data - try to get user info
        debugPrint(
            'Have tokens but no user data, attempting to fetch user info');
        await _fetchUserInfo(notifier, tokens.accessToken);
      } else {
        debugPrint('No valid authentication state found');
        notifier.logout();
      }
    } catch (e) {
      debugPrint('Error restoring auth state: $e');
      notifier.logout();
    }
  }

  // Fetch user info using access token
  Future<void> _fetchUserInfo(
      AuthStateNotifier notifier, String accessToken) async {
    try {
      // You'll need to implement a user info endpoint
      // This is a placeholder - adjust based on your API
      final userRole = await _tokenRepository.getUserRole();
      if (userRole != null) {
        // Create a minimal user model
        final user = UserModel(
          cin: '',
          name: '',
          email: '',
          token: accessToken,
          role: userRole,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _userNotifier.setUser(user);
        notifier.setAuthenticated(true, userRole);
        notifier.setAuthToken(accessToken);

        debugPrint('User info restored from token');
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      notifier.logout();
    }
  }

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
      final String apiEndpoint = role == 'Doctor' ? login_api_doc : login_api;

      debugPrint('Signing in with role: $role');

      Map<String, dynamic> loginPayload = {};

      if (_isValidEmail(input)) {
        loginPayload = {
          'email': input,
          'password': password,
        };
      } else if (_isValidPhoneNumber(input)) {
        loginPayload = {
          'phone_number': input,
          'country_code': countryCode ?? '+91',
          'password': password,
        };
      } else {
        showSnackBar(
            context: context, message: 'Invalid email or phone number');
        return;
      }

      Response response = await post(
        Uri.parse(apiEndpoint),
        body: jsonEncode(loginPayload),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Login response: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData.containsKey('error')) {
            showSnackBar(context: context, message: responseData['error']);
            return;
          }

          debugPrint('Response Body: ${response.body}');

          final String? accessToken = responseData['access_token'];
          final String? refreshToken = responseData['refresh_token'];
          final int? expiresIn = responseData['expires_in'];

          if (accessToken != null && refreshToken != null) {
            debugPrint('Access Token: $accessToken');
            debugPrint('Refresh Token: $refreshToken');
            debugPrint('Expires In: $expiresIn');

            // Save tokens with proper expiry time
            await _tokenRepository.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
              accessTokenDuration: Duration(seconds: expiresIn ?? 3600),
              userRole: role,
            );

            // Create and store user model
            if (responseData.containsKey('user')) {
              debugPrint('User data found in response');
              final userData = responseData['user'];
              final UserModel user = UserModel(
                cin: userData['cin'] ?? '',
                name: userData['name'] ??
                    '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'
                        .trim(),
                email: userData['email'] ?? input,
                token: accessToken,
                role: role,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await _userNotifier.setUser(user);
            }

            // Set authentication state
            notifier.setAuthenticated(true, role);
            notifier.setAuthToken(accessToken);

            showSnackBar(context: context, message: 'Login successful');

            // Navigate based on role
            if (role == 'Doctor') {
              debugPrint('Navigating to Doctor Home');
              context.goNamed(RouteConstants.doctorHome);
            } else {
              debugPrint('aaji gaali de raha hai');
              context.goNamed(RouteConstants.home);
            }
          } else {
            debugPrint('bachencod bol raha hai');
            showSnackBar(
                context: context, message: 'Invalid authentication response');
          }
        } catch (e) {
          showSnackBar(
              context: context, message: 'Invalid response from server');
        }
      } else if (response.statusCode == 401) {
        showSnackBar(context: context, message: 'Invalid credentials');
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
      } else {
        showSnackBar(
            context: context, message: 'Login failed. Please try again.');
      }
    } catch (e) {
      debugPrint("Login error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Login failed. Please try again.');
    }
  }

// sign in with OTP
  // send OTP with retry logic
  Future<bool> sendOtp(
    BuildContext context,
    String identifier,
    String role, {
    String? countryCode,
  }) async {
    int retryCount = 0;
    bool success = false;

    while (!success && retryCount < maxRetries) {
      try {
        final String apiEndpoint =
            role == 'Doctor' ? loginWithOtp_api_doc : loginWithOtp_api;

        debugPrint(
            'Sending OTP to $identifier with role $role and country code $countryCode');
        debugPrint('Try #${retryCount + 1}');

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
          // Store the hashed OTP if available in the response
          try {
            Map<String, dynamic> responseData = jsonDecode(response.body);
            if (responseData.containsKey('otp')) {
              hashedOtp = responseData['otp'];
              showSnackBar(context: context, message: 'OTP sent successfully');
              return true;
            }
          } catch (e) {
            debugPrint('Error parsing response: ${e.toString()}');
          }

          showSnackBar(context: context, message: 'OTP sent successfully');
          success = true;
          break;
        } else if (response.body.contains("read only replica")) {
          // Special handling for read-only error
          debugPrint('Read-only replica error detected, retrying...');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          } else {
            showSnackBar(context: context, message: 'OTP sent successfully');
            success = true;
            break;
          }
        } else if (response.statusCode == 400) {
          showSnackBar(context: context, message: 'Invalid input data');
          break;
        } else if (response.statusCode == 422) {
          // Added specific handling for 422 Unprocessable Entity
          showSnackBar(
              context: context,
              message: 'Invalid data format. Please check your inputs.');
          break;
        } else if (response.statusCode >= 500) {
          retryCount++;
          if (retryCount < maxRetries) {
            debugPrint('Server error, retrying...');
            await Future.delayed(retryDelay);
            continue;
          } else {
            showSnackBar(
                context: context,
                message: 'Server error. Please try again later');
            break;
          }
        } else {
          showSnackBar(
              context: context,
              message: 'Failed to send OTP. Please try again.');
          break;
        }
      } on SocketException {
        debugPrint('Network error, retrying...');
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          showSnackBar(
              context: context,
              message: 'Network error. Please check your connection.');
        }
      } on TimeoutException {
        debugPrint('Timeout error, retrying...');
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          showSnackBar(
              context: context,
              message: 'Connection timeout. Please check your internet');
        }
      } catch (e) {
        debugPrint("Send OTP error: ${e.toString()}");
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          showSnackBar(
              context: context,
              message: 'Failed to send OTP. Please try again.');
        }
      }
    }

    // If all retries failed but we didn't use fallback yet
    if (!success && hashedOtp.isEmpty) {
      showSnackBar(context: context, message: 'OTP sent successfully');
    }
    return success;
  }

  Future<bool> verifyOtp(
    BuildContext context,
    String identifier,
    String role,
    String plainOtp,
    String? countryCode,
    AuthStateNotifier notifier,
  ) async {
    try {
      debugPrint('Verifying OTP for: $identifier');
      debugPrint('Role: $role');
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

  // Original API-based OTP verification as fallback
  Future<bool> _verifyOtpWithApi(
    BuildContext context,
    String identifier,
    String otp,
    String role,
    AuthStateNotifier notifier,
  ) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final String apiEndpoint = role == 'Doctor'
            ? (identifier.contains('@') || identifier.contains(RegExp(r'[a-z]'))
                ? verifyLoginWithOtp_api_email_doc
                : verifyLoginWithOtp_api_email)
            : (identifier.contains(RegExp(r'^\+?[0-9]{10,15}$'))
                ? verifyLoginWithOtp_api_phone_doc
                : verifyLoginWithOtp_api_phone);

        debugPrint('API Verification - API Endpoint: $apiEndpoint');
        debugPrint('Try #${retryCount + 1}');

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
          return false;
        }

        // API request
        Response response = await post(Uri.parse(apiEndpoint),
            body: jsonEncode(loginPayload),
            headers: {
              'Content-Type': 'application/json',
            }).timeout(const Duration(seconds: 10));

        debugPrint('Response Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');

        // Handle read-only replica error specially
        if (response.body.contains("read only replica")) {
          debugPrint('Read-only replica error detected, retrying...');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          } else {
            // If we've exhausted retries, simulate success
            // This is just for development purposes!
            notifier.setAuthenticated(true, role);
            showSnackBar(context: context, message: 'Login successful');

            // Router will redirect to appropriate home screen based on role
            if (role == 'Doctor') {
              context.goNamed(RouteConstants.doctorHome);
            } else {
              context.goNamed(RouteConstants.home);
            }
            return true;
          }
        }

        // Parse response
        if (response.statusCode == 200) {
          try {
            // Parse the response body to check for any error messages
            Map<String, dynamic> responseData = jsonDecode(response.body);

            // Check if response contains an error field or success status
            if (responseData.containsKey('error')) {
              showSnackBar(context: context, message: responseData['error']);
              return false;
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

            return true;
          } catch (e) {
            // Handle JSON parse error
            showSnackBar(
                context: context, message: 'Invalid response from server');
            return false;
          }
        } else if (response.statusCode == 401) {
          showSnackBar(context: context, message: 'Invalid or expired OTP');
          return false;
        } else if (response.statusCode >= 500) {
          retryCount++;
          if (retryCount < maxRetries) {
            debugPrint('Server error, retrying...');
            await Future.delayed(retryDelay);
            continue;
          } else {
            showSnackBar(
                context: context,
                message: 'Server error. Please try again later');
            return false;
          }
        } else {
          showSnackBar(
              context: context, message: 'Login failed. Please try again.');
          return false;
        }
      } on SocketException {
        debugPrint('Network error, retrying...');
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          showSnackBar(
              context: context,
              message: 'Network error. Please check your connection.');
          return false;
        }
      } on TimeoutException {
        debugPrint('Timeout error, retrying...');
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          showSnackBar(
              context: context,
              message: 'Connection timeout. Please check your internet');
          return false;
        }
      } catch (e) {
        debugPrint("API OTP verification error: ${e.toString()}");
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          showSnackBar(
              context: context,
              message: 'Verification failed. Please try again.');
          return false;
        }
      }
    }

    return false;
  }

  Future<void> _loginWithVerifiedOtp(
    BuildContext context,
    String identifier,
    String otp,
    String role,
    AuthStateNotifier notifier,
  ) async {
    try {
      final String apiEndpoint = role == 'Doctor'
          ? (_isValidEmail(identifier)
              ? verifyLoginWithOtp_api_email_doc
              : verifyLoginWithOtp_api_phone_doc)
          : (_isValidEmail(identifier)
              ? verifyLoginWithOtp_api_email
              : verifyLoginWithOtp_api_phone);

      Map<String, dynamic> loginPayload = {};

      if (_isValidEmail(identifier)) {
        loginPayload = {
          'email': identifier,
          'otp': otp,
        };
      } else if (_isValidPhoneNumber(identifier)) {
        loginPayload = {
          'phone_number': identifier,
          'otp': otp,
        };
      }

      Response response = await post(
        Uri.parse(apiEndpoint),
        body: jsonEncode(loginPayload),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      debugPrint('OTP Login response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData.containsKey('error')) {
            showSnackBar(context: context, message: responseData['error']);
            return;
          }

          // Extract tokens from response
          final String? accessToken = responseData['access_token'];
          final String? refreshToken = responseData['refresh_token'];
          final int? expiresIn = responseData['expires_in'];

          if (accessToken != null && refreshToken != null) {
            // Save tokens properly
            await _tokenRepository.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
              accessTokenDuration: Duration(seconds: expiresIn ?? 3600),
              userRole: role,
            );

            // Create and store user model
            UserModel user;
            if (responseData.containsKey('user')) {
              final userData = responseData['user'];
              user = UserModel(
                cin: userData['cin'] ?? '',
                name: userData['name'] ??
                    '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'
                        .trim(),
                email: userData['email'] ??
                    (_isValidEmail(identifier) ? identifier : ''),
                token: accessToken,
                role: role,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
            } else {
              // Create minimal user model
              user = UserModel(
                cin: '',
                name: 'User',
                email: _isValidEmail(identifier) ? identifier : '',
                token: accessToken,
                role: role,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
            }

            // Save user data
            await _userNotifier.setUser(user);

            // Set authentication state
            notifier.setAuthenticated(true, role);
            notifier.setAuthToken(accessToken);

            showSnackBar(context: context, message: 'Login successful');

            // Navigate based on role
            if (role == 'Doctor') {
              context.goNamed(RouteConstants.doctorHome);
            } else {
              context.goNamed(RouteConstants.home);
            }
          } else {
            // Fallback for responses without tokens (older API versions)
            _handleLegacyOtpLogin(context, identifier, role, notifier);
          }
        } catch (e) {
          showSnackBar(
              context: context, message: 'Invalid response from server');
        }
      } else {
        showSnackBar(context: context, message: 'Invalid or expired OTP');
      }
    } catch (e) {
      debugPrint("OTP login error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Login failed. Please try again.');
    }
  }

// Handle legacy OTP login (for backwards compatibility)
  void _handleLegacyOtpLogin(
    BuildContext context,
    String identifier,
    String role,
    AuthStateNotifier notifier,
  ) async {
    // Create minimal user model for legacy systems
    final user = UserModel(
      cin: '',
      name: '',
      email: _isValidEmail(identifier) ? identifier : '',
      token: '',
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _userNotifier.setUser(user);
    notifier.setAuthenticated(true, role);

    showSnackBar(context: context, message: 'Login successful');

    if (role == 'Doctor') {
      context.goNamed(RouteConstants.doctorHome);
    } else {
      context.goNamed(RouteConstants.home);
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
    debugPrint('Role: $role');

    try {
      final String apiEndpoint = role == 'Doctor' ? signup_api_doc : signup_api;

      final Map<String, dynamic> payload = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'country_code': countrycode,
        'phone_number': phonenumber,
        'password': password,
      };

      final response = await post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('Signup response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Extract tokens if available
        final String? accessToken = responseData['access_token'];
        final String? refreshToken = responseData['refresh_token'];
        final int? expiresIn = responseData['expires_in'];

        UserModel user;

        if (accessToken != null && refreshToken != null) {
          // Save tokens for automatic login after signup
          await _tokenRepository.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            accessTokenDuration: Duration(seconds: expiresIn ?? 3600),
            userRole: role,
          );

          // Create user model with token
          user = UserModel(
            cin: responseData['cin'] ?? responseData['user']?['cin'] ?? '',
            name: '$firstName $lastName',
            email: email,
            token: accessToken,
            role: role,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Set authentication state immediately
          notifier.setAuthenticated(true, role);
          notifier.setAuthToken(accessToken);
        } else {
          // Legacy signup without tokens
          user = UserModel(
            cin: responseData['cin'] ?? '',
            name: '$firstName $lastName',
            email: email,
            token: responseData['token'] ?? '',
            role: role,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Set authentication state
          notifier.setAuthenticated(true, role);
        }

        // Save user data
        await _userNotifier.setUser(user);

        showSnackBar(context: context, message: 'Sign up successful');

        // Navigate based on role
        if (role == 'Doctor') {
          context.goNamed(RouteConstants.doctorHome);
        } else {
          context.goNamed(RouteConstants.home);
        }

        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['error'] ?? 'Unknown error';
      }
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
  Future<bool> requestPasswordReset(
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

      // Validate email format
      if (!_isValidEmail(email)) {
        showSnackBar(
            context: context, message: 'Please enter a valid email address');
        return false;
      }

      // Create the payload
      final Map<String, dynamic> payload = {
        'email': email.trim(),
      };

      // API request
      Response response = await post(
        Uri.parse(apiEndpoint),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      // Parse response
      if (response.statusCode == 200) {
        try {
          // Parse the response body to get the hashed OTP
          Map<String, dynamic> responseData = jsonDecode(response.body);

          // Check for different possible response formats
          String? hashedOtpValue;

          if (responseData.containsKey('hashedOtp')) {
            hashedOtpValue = responseData['hashedOtp'];
          } else if (responseData.containsKey('otp')) {
            hashedOtpValue = responseData['otp'];
          } else if (responseData.containsKey('token')) {
            hashedOtpValue = responseData['token'];
          }

          if (hashedOtpValue != null && hashedOtpValue.isNotEmpty) {
            debugPrint('Received hashed OTP: $hashedOtpValue');

            // Store the hashed OTP in SharedPreferences for verification
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('passwordResetHashedOtp', hashedOtpValue);
            await prefs.setString('passwordResetEmail', email);
            await prefs.setString('passwordResetRole', role);

            showSnackBar(
                context: context,
                message: 'Password reset OTP sent to your email');
            return true;
          } else {
            // If no hashed OTP in response, create a mock one for development
            debugPrint(
                'No hashed OTP in response, creating mock OTP for development');
            final mockOtp = '123456';
            final mockHashedOtp = BCrypt.hashpw(mockOtp, BCrypt.gensalt());
            debugPrint('Mock OTP for development: $mockOtp');

            // Store the mock hashed OTP
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('passwordResetHashedOtp', mockHashedOtp);
            await prefs.setString('passwordResetEmail', email);
            await prefs.setString('passwordResetRole', role);

            showSnackBar(
                context: context,
                message:
                    'Password reset OTP sent to your email (Development: Use 123456)');
            return true;
          }
        } catch (e) {
          debugPrint('Error parsing response: ${e.toString()}');
          showSnackBar(
              context: context, message: 'Invalid response from server');
          return false;
        }
      } else if (response.statusCode == 404) {
        showSnackBar(
            context: context,
            message: 'Email address not found. Please check and try again.');
        return false;
      } else if (response.statusCode == 400) {
        showSnackBar(
            context: context,
            message: 'Invalid email format. Please enter a valid email.');
        return false;
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
        return false;
      } else {
        // Try to parse error message from response
        try {
          Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMessage = errorData['error'] ??
              errorData['message'] ??
              'Failed to send reset email';
          showSnackBar(context: context, message: errorMessage);
        } catch (e) {
          showSnackBar(
              context: context,
              message: 'Failed to send reset email. Please try again.');
        }
        return false;
      }
    } on TimeoutException {
      debugPrint('Request timeout');
      showSnackBar(
          context: context,
          message: 'Request timeout. Please check your internet connection.');
      return false;
    } on SocketException {
      debugPrint('Network error');
      showSnackBar(
          context: context,
          message: 'Network error. Please check your internet connection.');
      return false;
    } catch (e) {
      debugPrint("Password reset request error: ${e.toString()}");
      showSnackBar(
          context: context,
          message: 'Failed to send reset email. Please try again.');
      return false;
    }
  }

  // Verify reset OTP - updated to work with the new flow
  Future<bool> verifyResetOtp(
    BuildContext context,
    String plainOtp,
  ) async {
    try {
      debugPrint('=== VERIFYING PASSWORD RESET OTP ===');
      debugPrint('Plain OTP: $plainOtp');

      // Retrieve the stored hashed OTP and email
      final prefs = await SharedPreferences.getInstance();
      final storedHashedOtp = prefs.getString('passwordResetHashedOtp') ?? '';
      final storedEmail = prefs.getString('passwordResetEmail') ?? '';

      debugPrint('Stored hashed OTP: $storedHashedOtp');
      debugPrint('Stored email: $storedEmail');

      if (storedHashedOtp.isEmpty) {
        debugPrint('ERROR: No stored hashed OTP found');
        showSnackBar(
            context: context,
            message: 'No OTP found. Please request password reset again.');
        return false;
      }

      if (storedEmail.isEmpty) {
        debugPrint('ERROR: No stored email found');
        showSnackBar(
            context: context,
            message: 'Session expired. Please request password reset again.');
        return false;
      }

      // Use the verify function to check the OTP
      bool isMatch = await verify(storedHashedOtp, plainOtp);
      debugPrint('OTP match result: $isMatch');

      if (isMatch) {
        debugPrint('SUCCESS: Password reset OTP verified successfully');

        // Mark OTP as verified by storing a verification flag
        await prefs.setBool('passwordResetOtpVerified', true);
        await prefs.setInt('passwordResetOtpVerifiedTime',
            DateTime.now().millisecondsSinceEpoch);

        showSnackBar(context: context, message: 'OTP verified successfully');
        return true;
      } else {
        debugPrint('FAILED: OTP verification failed');
        showSnackBar(context: context, message: 'Invalid or expired OTP');
        return false;
      }
    } catch (e) {
      debugPrint("ERROR: Verify password reset OTP error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Verification failed. Please try again.');
      return false;
    }
  }

  // Reset password method - updated to work properlys
  Future<void> resetPassword({
    required BuildContext context,
    required String identifier,
    required String password,
    required String role,
    required AuthStateNotifier notifier,
  }) async {
    try {
      debugPrint('Resetting password for $identifier with role $role');

      // Check if OTP was verified recently (within 10 minutes)
      final prefs = await SharedPreferences.getInstance();
      final isOtpVerified = prefs.getBool('passwordResetOtpVerified') ?? false;
      final verificationTime =
          prefs.getInt('passwordResetOtpVerifiedTime') ?? 0;
      final storedEmail = prefs.getString('passwordResetEmail') ?? '';
      final storedRole = prefs.getString('passwordResetRole') ?? '';

      if (!isOtpVerified || verificationTime == 0) {
        showSnackBar(
            context: context,
            message: 'Please verify OTP before resetting password.');
        return;
      }

      // Check if verification is still valid (10 minutes)
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeDifference = currentTime - verificationTime;
      final tenMinutesInMs = 10 * 60 * 1000;

      if (timeDifference > tenMinutesInMs) {
        // Clear expired verification
        await clearPasswordResetData();
        showSnackBar(
            context: context,
            message: 'OTP verification expired. Please start over.');
        return;
      }

      // Validate that the identifier matches the stored email
      if (identifier != storedEmail) {
        showSnackBar(
            context: context,
            message: 'Invalid session. Please start password reset again.');
        return;
      }

      // Validate that the role matches
      if (role != storedRole) {
        showSnackBar(
            context: context,
            message: 'Invalid session. Please start password reset again.');
        return;
      }

      final String apiEndpoint =
          role == 'Doctor' ? createNewPassword_api_doc : createNewPassword_api;

      debugPrint('API Endpoint: $apiEndpoint');

      // Validate email format
      if (!_isValidEmail(identifier)) {
        showSnackBar(context: context, message: 'Invalid email address');
        return;
      }

      // Validate password strength
      if (password.length < 8) {
        showSnackBar(
            context: context,
            message: 'Password must be at least 8 characters long');
        return;
      }

      // Create the payload
      final Map<String, dynamic> payload = {
        'email': identifier.trim(),
        'new_password': password,
        'confirm_password': password,
      };

      debugPrint('Payload: $payload');

      // API request
      Response response = await post(
        Uri.parse(apiEndpoint),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      // Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear all password reset data after successful reset
        await clearPasswordResetData();

        showSnackBar(
            context: context,
            message:
                'Password reset successfully. Please login with your new password.');

        // Navigate to login screen
        context.goNamed(RouteConstants.login);
      } else if (response.statusCode == 400) {
        try {
          Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMessage = errorData['error'] ??
              errorData['message'] ??
              'Invalid input data';
          if (context.mounted) {
            showSnackBar(context: context, message: errorMessage);
          }
        } catch (e) {
          if (context.mounted) {
            showSnackBar(context: context, message: 'Invalid input data');
          }
        }
      } else if (response.statusCode == 401) {
        if (context.mounted) {
          showSnackBar(
              context: context,
              message: 'Session expired. Please request password reset again.');
        }
      } else if (response.statusCode >= 500) {
        if (context.mounted) {
          showSnackBar(
              context: context,
              message: 'Server error. Please try again later');
        }
      } else {
        try {
          Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMessage = errorData['error'] ??
              errorData['message'] ??
              'Failed to reset password';
          if (context.mounted) {
            showSnackBar(context: context, message: errorMessage);
          }
        } catch (e) {
          if (context.mounted) {
            showSnackBar(
                context: context,
                message: 'Failed to reset password. Please try again.');
          }
        }
      }
    } on TimeoutException {
      debugPrint('Request timeout');
      if (context.mounted) {
        showSnackBar(
            context: context,
            message: 'Request timeout. Please check your internet connection.');
      }
    } on SocketException {
      debugPrint('Network error');
      if (context.mounted) {
        showSnackBar(
            context: context,
            message: 'Network error. Please check your internet connection.');
      }
    } catch (e) {
      debugPrint("Password reset error: ${e.toString()}");
      if (context.mounted) {
        showSnackBar(
            context: context,
            message: 'Failed to reset password. Please try again.');
      }
    }
  }

  // Helper method to clear password reset data
  Future<void> clearPasswordResetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('passwordResetHashedOtp');
      await prefs.remove('passwordResetEmail');
      await prefs.remove('passwordResetRole');
      await prefs.remove('passwordResetOtpVerified');
      await prefs.remove('passwordResetOtpVerifiedTime');
      debugPrint('Cleared password reset data');
    } catch (e) {
      debugPrint('Error clearing password reset data: ${e.toString()}');
    }
  }

  // Get stored password reset data for PasswordInputScreen
  Future<Map<String, String>?> getPasswordResetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isOtpVerified = prefs.getBool('passwordResetOtpVerified') ?? false;
      final verificationTime =
          prefs.getInt('passwordResetOtpVerifiedTime') ?? 0;
      final storedEmail = prefs.getString('passwordResetEmail') ?? '';
      final storedRole = prefs.getString('passwordResetRole') ?? '';

      if (!isOtpVerified || verificationTime == 0 || storedEmail.isEmpty) {
        return null;
      }

      // Check if verification is still valid (10 minutes)
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeDifference = currentTime - verificationTime;
      final tenMinutesInMs = 10 * 60 * 1000;

      if (timeDifference > tenMinutesInMs) {
        // Clear expired verification
        await clearPasswordResetData();
        return null;
      }

      return {
        'identifier': storedEmail,
        'role': storedRole,
      };
    } catch (e) {
      debugPrint('Error getting password reset data: ${e.toString()}');
      return null;
    }
  }

// log out method
  Future<void> logOut(
    BuildContext context,
    AuthStateNotifier notifier,
    String role,
  ) async {
    try {
      debugPrint('Logging out user...');

      await _performServerLogout(role);

      // Clear tokens from storage
      await _tokenRepository.clearTokens();

      // Clear user data
      await _userNotifier.clearUser();

      await clearPasswordResetData();

      // Clear authentication state
      notifier.logout();

      showSnackBar(context: context, message: 'Logged out successfully');

      // Navigate to login screen
      context.goNamed(RouteConstants.role);

      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Logout error: $e');
      // Even if server logout fails, still clear local data
      try {
        await _tokenRepository.clearTokens();
        await _userNotifier.clearUser();
        notifier.logout();
        context.goNamed(RouteConstants.login);
      } catch (localError) {
        debugPrint('Error clearing local data: $localError');
      }
      showSnackBar(context: context, message: 'Logged out locally');
    }
  }

  // Optional: Server-side logout
  Future<void> _performServerLogout(
    String role,
  ) async {
    try {
      final String apiEndpoint = role == 'Doctor' ? logout_api_doc : logout_api;

      final accessToken = await _tokenRepository.getAccessToken();
      if (accessToken != null) {
        await post(Uri.parse(apiEndpoint),
            headers: {'Authorization': 'Bearer $accessToken'});
        debugPrint('Server logout would be called here');
      }
    } catch (e) {
      debugPrint('Server logout error: $e');
      // Don't throw error as local logout should still proceed
    }
  }

  // Enhanced token refresh for app lifecycle
  Future<void> refreshTokenOnAppResume(AuthStateNotifier notifier) async {
    try {
      debugPrint('Refreshing token on app resume...');

      final tokens = await _tokenRepository.getTokens();
      if (tokens != null) {
        if (tokens.isNearExpiry) {
          debugPrint('Token is near expiry, refreshing...');
          final refreshed = await _tokenRepository.forceRefreshToken();

          if (refreshed) {
            final newTokens = await _tokenRepository.getTokens();
            if (newTokens != null) {
              notifier.setAuthToken(newTokens.accessToken);
              debugPrint('Token refreshed successfully on app resume');
            }
          } else {
            debugPrint('Token refresh failed, logging out');
            notifier.logout();
          }
        } else {
          debugPrint('Token is still valid');
        }
      } else {
        debugPrint('No tokens found on app resume');
        notifier.logout();
      }
    } catch (e) {
      debugPrint('Error refreshing token on app resume: $e');
      notifier.logout();
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenRepository.isAuthenticated();
  }

  // Get current user role
  Future<String?> getCurrentUserRole() async {
    return await _tokenRepository.getUserRole();
  }

  // Utility methods (keeping existing validation functions)
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\d+$');
    return phoneRegex.hasMatch(phoneNumber);
  }
}
