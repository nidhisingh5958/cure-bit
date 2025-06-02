// Reschedule Appointment method
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:CureBit/services/features_api_repository/api_constant.dart';
import 'package:CureBit/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class DoctorPostAppointmentRepository {
  // Singleton instance
  static final DoctorPostAppointmentRepository _instance =
      DoctorPostAppointmentRepository._internal();

  // Private constructor
  DoctorPostAppointmentRepository._internal();

  // Factory constructor to return the singleton instance
  factory DoctorPostAppointmentRepository() {
    return _instance;
  }

  // Method to get appointments
  Future<List<String>> docGetAppointments() async {
    // Simulate a network call or database query
    await Future.delayed(Duration(seconds: 1));
    return ['Appointment 1', 'Appointment 2', 'Appointment 3'];
  }

  Future<bool> docRescheduleAppointment(
    BuildContext context,
    String appointmentId,
    String appointmentDate,
    String appointmentTime,
    String reason,
    String role,
  ) async {
    final String apiEndpoint = rescheduleAppointment_doc;

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

  // Method to update appointment status (mark as done)
  Future<bool> updateAppointmentStatus(
    BuildContext context,
    String appointmentId,
    bool status,
  ) async {
    final String apiEndpoint = appointmentDone;

    debugPrint('Updating appointment status:');
    debugPrint('Appointment ID: $appointmentId');

    Map<String, dynamic> data = {
      'appointment_id': appointmentId,
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
        debugPrint('Appointment status updated successfully');
        showSnackBar(
            context: context,
            message: status
                ? 'Appointment marked as completed'
                : 'Appointment status updated');
        return true;
      } else if (response.statusCode == 404) {
        // Handle not found error
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(context: context, message: 'Appointment not found');
        return false;
      } else if (response.statusCode >= 500) {
        String errorMessage = 'Server error. Please try again later';
        if (response.body.contains('Nonetype object are not iterable')) {
          errorMessage = 'Server error. Please contact Back-end team.';
        } else if (response.body.contains('Endpoint Timeout error')) {
          errorMessage = 'Connection timeout. Please contact DevOps team.';
        }
        showSnackBar(context: context, message: errorMessage);
        return false;
      } else {
        showSnackBar(
            context: context,
            message: 'Status update failed. Please try again.');
        return false;
      }
    } catch (e) {
      debugPrint("Appointment status update error: ${e.toString()}");
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return false;
    }
  }
}
