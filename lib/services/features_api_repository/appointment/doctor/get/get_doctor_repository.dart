// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:CureBit/services/features_api_repository/api_constant.dart';
import 'package:CureBit/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DoctorGetAppointmentRepository {
  // Singleton instance
  static final DoctorGetAppointmentRepository _instance =
      DoctorGetAppointmentRepository._internal();

  // Private constructor
  DoctorGetAppointmentRepository._internal();

  // Factory constructor to return the singleton instance
  factory DoctorGetAppointmentRepository() {
    return _instance;
  }

  // Method to get current appointments for a doctor
  Future<List<Map<String, dynamic>>> getDoctorAppointments(String cin) async {
    final String apiEndpoint = '$appointment/doctor/appointment/$cin';

    debugPrint('Fetching appointments for doctor with CIN: $cin');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        debugPrint('Successfully fetched ${responseData.length} appointments');

        return responseData
            .map((appointment) => appointment as Map<String, dynamic>)
            .toList();
      } else {
        debugPrint(
            'Error fetching appointments: ${response.statusCode}, ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception while fetching appointments: ${e.toString()}');
      return [];
    }
  }

  // Method to delete cached appointments for a doctor
  Future<bool> deleteCachedAppointments(
    BuildContext context,
    String cin,
  ) async {
    final String apiEndpoint =
        '$appointment/doctor/$cin/delete_cached_appointments';

    debugPrint('Deleting cached appointments for doctor with CIN: $cin');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['message'] ?? 'Appointments cache cleared';

        debugPrint('Successfully deleted cached appointments: $message');
        showSnackBar(context: context, message: message);
        return true;
      } else {
        debugPrint(
            'Error deleting cached appointments: ${response.statusCode}, ${response.body}');
        showSnackBar(
            context: context,
            message: 'Failed to refresh appointments. Please try again.');
        return false;
      }
    } catch (e) {
      debugPrint(
          'Exception while deleting cached appointments: ${e.toString()}');
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return false;
    }
  }

  // Method to get previous (completed) appointments for a doctor
  Future<List<Map<String, dynamic>>> getDoctorPreviousAppointments(
      String cin) async {
    final String apiEndpoint = '$appointment/doctor/previous_appointment/$cin';

    debugPrint('Fetching previous appointments for doctor with CIN: $cin');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        debugPrint(
            'Successfully fetched ${responseData.length} previous appointments');

        return responseData
            .map((appointment) => appointment as Map<String, dynamic>)
            .toList();
      } else {
        debugPrint(
            'Error fetching previous appointments: ${response.statusCode}, ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint(
          'Exception while fetching previous appointments: ${e.toString()}');
      return [];
    }
  }

  // Method to refresh previous appointments cache
  Future<bool> refreshPreviousAppointments(
    BuildContext context,
    String cin,
  ) async {
    final String apiEndpoint =
        '$appointment/doctor/refresh_previous_appointment/$cin';

    debugPrint('Refreshing previous appointments for doctor with CIN: $cin');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message =
            responseData['message'] ?? 'Previous appointments refreshed';

        debugPrint('Successfully refreshed previous appointments: $message');
        showSnackBar(context: context, message: message);
        return true;
      } else {
        debugPrint(
            'Error refreshing previous appointments: ${response.statusCode}, ${response.body}');
        showSnackBar(
            context: context,
            message:
                'Failed to refresh previous appointments. Please try again.');
        return false;
      }
    } catch (e) {
      debugPrint(
          'Exception while refreshing previous appointments: ${e.toString()}');
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return false;
    }
  }

  // Utility method to handle API errors with proper error messages
  String handleApiError(http.Response response) {
    try {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return errorData['message'] ?? 'An unexpected error occurred';
    } catch (e) {
      if (response.statusCode == 404) {
        return 'Resource not found';
      } else if (response.statusCode == 401) {
        return 'Unauthorized access';
      } else if (response.statusCode >= 500) {
        return 'Server error. Please try again later';
      } else {
        return 'Error: ${response.statusCode}';
      }
    }
  }

  // Method to convert appointment date and time to proper format
  Map<String, String> formatAppointmentDateTime(String date, String time) {
    // Ensure date is in YYYY-MM-DD format
    final List<String> dateParts = date.split('-');
    if (dateParts.length == 3) {
      // If the format is already correct or needs minor adjustments
      String year =
          dateParts[0].length == 4 ? dateParts[0] : '20${dateParts[0]}';
      String month = dateParts[1].padLeft(2, '0');
      String day = dateParts[2].padLeft(2, '0');
      date = '$year-$month-$day';
    }

    // Ensure time is in HH:MM format
    if (!time.contains(':')) {
      // If time format is incorrect, try to fix it
      if (time.length == 4) {
        time = '${time.substring(0, 2)}:${time.substring(2)}';
      }
    }

    return {
      'date': date,
      'time': time,
    };
  }
}
