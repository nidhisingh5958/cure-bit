import 'dart:convert';

import 'package:CuraDocs/common/general_api/general_api_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:CuraDocs/app/auth/token/token_repository.dart';

class GeneralApiRepository {
  // Singleton instance
  static final GeneralApiRepository _instance =
      GeneralApiRepository._internal();

  // Private constructor
  GeneralApiRepository._internal();

  // Factory constructor to return the singleton instance
  factory GeneralApiRepository() {
    return _instance;
  }

  // Get auth token for API calls
  Future<String?> _getAuthToken() async {
    final tokenRepository = TokenRepository();
    return await tokenRepository.getAccessToken();
  }

  // Method to report a problem
  Future<String> reportProblem(
    String fullName,
    String phoneNumber,
    String email,
    String subject,
    String preference,
    String message,
  ) async {
    final String apiEndpoint = reportProblem_api;

    // Get authentication token
    final String? authToken = await _getAuthToken();
    if (authToken == null) {
      throw Exception('Authentication token not available');
    }

    debugPrint('Submitting problem report:');
    debugPrint('Full Name: $fullName');
    debugPrint('Phone Number: $phoneNumber');
    debugPrint('Email: $email');
    debugPrint('Subject: $subject');
    debugPrint('Preference: $preference');
    debugPrint('Message: $message');

    Map<String, dynamic> data = {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'subject': subject,
      'preference': preference,
      'message': message,
    };

    Response response = await post(
      Uri.parse(apiEndpoint),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken', // Add authorization header
      },
    );

    if (response.statusCode == 200) {
      // Handle success
      debugPrint('Report problem request successful');
      return 'Report submitted successfully';
    } else {
      // Handle error
      debugPrint('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to submit problem report');
    }
  }

  // Method to contact us
  Future<String> contactUs(
    String fullName,
    String email,
    String phoneNumber,
    String countryCode,
    String country,
    String state,
    String message,
    Map<String, dynamic> entityType,
  ) async {
    final String apiEndpoint = contactUs_api;

    // Get authentication token
    final String? authToken = await _getAuthToken();
    if (authToken == null) {
      throw Exception('Authentication token not available');
    }

    debugPrint('Submitting contact us form:');
    debugPrint('Full Name: $fullName');
    debugPrint('Email: $email');
    debugPrint('Phone Number: $phoneNumber');
    debugPrint('Country Code: $countryCode');
    debugPrint('Country: $country');
    debugPrint('State: $state');
    debugPrint('Message: $message');
    debugPrint('Entity Type: $entityType');

    Map<String, dynamic> data = {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'country': country,
      'state': state,
      'message': message,
      'entity_type': entityType,
    };

    Response response = await post(
      Uri.parse(apiEndpoint),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken', // Add authorization header
      },
    );

    if (response.statusCode == 200) {
      // Handle success
      debugPrint('Contact us request successful');
      return 'Message sent successfully';
    } else {
      // Handle error with more details
      debugPrint('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to submit contact us form: ${response.body}');
    }
  }

  // Method to get terms and conditions
  Future<String> getTermsAndConditions() async {
    // Get authentication token
    final String? authToken = await _getAuthToken();
    // For GET requests, you might implement proper API call here
    // instead of just simulating it

    await Future.delayed(Duration(seconds: 1));
    return 'Terms and Conditions content';
  }

  // Method to get privacy policy
  Future<String> getPrivacyPolicy() async {
    // Get authentication token
    final String? authToken = await _getAuthToken();
    // For GET requests, you might implement proper API call here
    // instead of just simulating it

    await Future.delayed(Duration(seconds: 1));
    return 'Privacy Policy content';
  }

  // Method to get feedback
  Future<String> getFeedback() async {
    // Get authentication token
    final String? authToken = await _getAuthToken();
    // For GET requests, you might implement proper API call here
    // instead of just simulating it

    await Future.delayed(Duration(seconds: 1));
    return 'Feedback content';
  }
}
