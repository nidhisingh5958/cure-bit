import 'dart:convert';

import 'package:CuraDocs/common/general_api/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

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
    final String apiEndpoint = '$contactUs';

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
      },
    );

    if (response.statusCode == 200) {
      // Handle success
      debugPrint('Contact us request successful');
      return 'Message sent successfully';
    } else {
      // Handle error
      debugPrint('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to submit contact us form');
    }
  }

  // Method to get terms and conditions
  Future<String> getTermsAndConditions() async {
    // Simulate a network call or database query
    await Future.delayed(Duration(seconds: 1));
    return 'Terms and Conditions content';
  }

  // Method to get privacy policy
  Future<String> getPrivacyPolicy() async {
    // Simulate a network call or database query
    await Future.delayed(Duration(seconds: 1));
    return 'Privacy Policy content';
  }

  // Method to get feedback
  Future<String> getFeedback() async {
    // Simulate a network call or database query
    await Future.delayed(Duration(seconds: 1));
    return 'Feedback content';
  }
}
