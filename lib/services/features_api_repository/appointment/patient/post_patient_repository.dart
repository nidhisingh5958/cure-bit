// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:CureBit/services/features_api_repository/api_constant.dart';
import 'package:CureBit/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class PatientAppointmentRepository {
  // Singleton instance
  static final PatientAppointmentRepository _instance =
      PatientAppointmentRepository._internal();

  // Private constructor
  PatientAppointmentRepository._internal();

  // Factory constructor to return the singleton instance
  factory PatientAppointmentRepository() {
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

  // Reschedule Appointment method
  Future<bool> rescheduleAppointment(
    BuildContext context,
    String appointmentId,
    String appointmentDate,
    String appointmentTime,
    String reason,
    String role,
  ) async {
    final String apiEndpoint = rescheduleAppointment_patient;

    debugPrint('Rescheduling appointment:');
    debugPrint('Appointment ID: $appointmentId');
    debugPrint('New Date: $appointmentDate');
    debugPrint('New Time: $appointmentTime');
    debugPrint('Reason: $reason');

    Map<String, dynamic> data = {
      'appointment_id': appointmentId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'reason': reason,
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
        debugPrint('Appointment rescheduled successfully');
        showSnackBar(
            context: context, message: 'Appointment rescheduled successfully');
        return true; // Return success status
      } else if (response.statusCode == 404) {
        // Handle not found error
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(context: context, message: 'Appointment not found');
        return false;
      } else if (response.statusCode == 400) {
        // Handle validation errors
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        final responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['message'] ?? 'Failed to reschedule appointment';

        // Check for specific error message about appointment slots
        if (errorMessage.contains('too close')) {
          errorMessage =
              'Appointment slot is too close to an existing appointment. Please choose a different time';
        }

        showSnackBar(context: context, message: errorMessage);
        return false;
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
        return false;
      } else {
        showSnackBar(
            context: context,
            message:
                'Rescheduling failed. Please try again., ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint("Appointment rescheduling error: ${e.toString()}");
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return false;
    }
  }

  // Cancel Appointment method
  Future<bool> cancelAppointment(
    BuildContext context,
    String appointmentId,
    String role,
  ) async {
    debugPrint('Cancelling appointment:');
    debugPrint('Appointment ID: $appointmentId');

    Map<String, dynamic> data = {
      'appointment_id': 'appointmentId/$appointmentId',
    };

    try {
      Response response = await post(
        Uri.parse(patientCancelAppointment),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        // Handle success
        debugPrint('Appointment cancelled successfully');
        showSnackBar(
            context: context, message: 'Appointment cancelled successfully');
        return true; // Return success status
      } else if (response.statusCode == 404) {
        // Handle not found error
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(context: context, message: 'Appointment not found');
        return false;
      } else if (response.statusCode == 400) {
        // Handle validation errors
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        final responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['message'] ?? 'Failed to cancel appointment';
        showSnackBar(context: context, message: errorMessage);
        return false;
      } else if (response.statusCode >= 500) {
        showSnackBar(
            context: context, message: 'Server error. Please try again later');
        return false;
      } else {
        showSnackBar(
            context: context,
            message:
                'Cancellation failed. Please try again., ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint("Appointment cancellation error: ${e.toString()}");
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return false;
    }
  }
}
