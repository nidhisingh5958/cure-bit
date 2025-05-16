import 'dart:async';
import 'dart:convert';
import 'package:CuraDocs/features/patient/api_repository/api_constant.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
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

  // Book Appointment method
  Future<bool> bookAppointment(
    BuildContext context,
    String docName,
    String docCIN,
    String patientName,
    String patientEmail,
    String appointmentDate,
    String appointmentTime,
  ) async {
    final String apiEndpoint = patientBookAppointment;

    debugPrint('Booking appointment:');
    debugPrint('Doctor Name: $docName');
    debugPrint('Doctor CIN: $docCIN');
    debugPrint('Patient Name: $patientName');
    debugPrint('Patient Email: $patientEmail');
    debugPrint('Appointment Date: $appointmentDate');
    debugPrint('Appointment Time: $appointmentTime');

    Map<String, dynamic> data = {
      'doctor_name': docName,
      'doctor_cin': docCIN,
      'patient_name': patientName,
      'patient_email': patientEmail,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
    };

    try {
      Response response = await post(
        Uri.parse(apiEndpoint),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Handle success
        debugPrint('Appointment booked successfully');
        return true; // Return success status
      } else if (response.statusCode == 400) {
        // Handle error
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(
            context: context,
            message:
                'Failed to book appointment: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
        return false;
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
        return false;
      } else {
        showSnackBar(
            context: context, message: 'Booking failed. Please try again.');
        return false;
      }
    } catch (e) {
      debugPrint("Appointment booking error: ${e.toString()}");
      showSnackBar(
          context: context, message: 'Booking failed. Please try again.');
      return false;
    }
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
    debugPrint('Settings updated: $settings');
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
    String firstName,
    String lastName,
    String email,
    String topic,
    String assist,
    String message,
  ) async {
    final String apiEndpoint = contactUs;

    debugPrint('Submitting form:');
    debugPrint('Name: $firstName $lastName');
    debugPrint('Email: $email');
    debugPrint('Topic: $topic');
    debugPrint('Assistance type: $assist');
    debugPrint('Message: $message');

    Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
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
      debugPrint('Contact us request successful');
    } else {
      // Handle error
      debugPrint('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to submit contact us form');
    }
    return 'Contact us content';
  }
}
