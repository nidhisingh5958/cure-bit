import 'dart:async';
import 'dart:convert';
import 'package:CuraDocs/features/patient/api_repository/api_constant.dart';
import 'package:http/http.dart';
// import 'package:CuraDocs/models/settings_model.dart';

class AppointmentRepository {
  // Singleton instance
  static final AppointmentRepository _instance =
      AppointmentRepository._internal();

  // Private constructor
  AppointmentRepository._internal();

  // Factory constructor to return the singleton instance
  factory AppointmentRepository() {
    return _instance;
  }

  // Method to get appointments
  Future<List<String>> getAppointments() async {
    // Simulate a network call or database query
    await Future.delayed(Duration(seconds: 1));
    return ['Appointment 1', 'Appointment 2', 'Appointment 3'];
  }

  // Method to book an appointment
  Future<void> bookAppointment(String appointment) async {
    // Simulate a network call or database booking
    await Future.delayed(Duration(seconds: 1));
    print('Appointment booked: $appointment');
  }
}

class SettingsRepository {
  // Singleton instance
  static final SettingsRepository _instance = SettingsRepository._internal();

  // Private constructor
  SettingsRepository._internal();

  // Factory constructor to return the singleton instance
  factory SettingsRepository() {
    return _instance;
  }

  // Method to get settings
  Future<Map<String, dynamic>> getSettings() async {
    // Simulate a network call or database query
    await Future.delayed(Duration(seconds: 1));
    return {'theme': 'dark', 'language': 'en'};
  }

  // Method to update settings
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    // Simulate a network call or database update
    await Future.delayed(Duration(seconds: 1));
    print('Settings updated: $settings');
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

  // Method to get contact us
  Future<String> getContactUs(
    String first_name,
    String last_name,
    String email,
    String topic,
    String assist,
    String message,
  ) async {
    final String apiEndpoint = contact_us;

    print('Submitting form:');
    print('Name: $first_name $last_name');
    print('Email: $email');
    print('Topic: $topic');
    print('Assistance type: $assist');
    print('Message: $message');

    Map<String, dynamic> data = {
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'topic': topic,
      'assist': assist,
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
      print('Contact us request successful');
    } else {
      // Handle error
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to submit contact us form');
    }
    return 'Contact us content';
  }
}
