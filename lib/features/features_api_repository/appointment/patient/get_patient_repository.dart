import 'dart:async';
import 'dart:convert';
import 'package:CuraDocs/features/features_api_repository/api_constant.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetPatientRepository {
  // Singleton instance
  static final GetPatientRepository _instance =
      GetPatientRepository._internal();

  // Private constructor
  GetPatientRepository._internal();

  // Factory constructor to return the singleton instance
  factory GetPatientRepository() {
    return _instance;
  }

  // Get all appointments for a patient
  Future<List<dynamic>> getPatientAppointments(
    BuildContext context,
    String patientEmail,
  ) async {
    final String apiEndpoint = '$appointment/patient/appointment/$patientEmail';

    debugPrint('Fetching appointments for patient: $patientEmail');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> appointmentsList = jsonDecode(response.body);
        debugPrint(
            'Successfully fetched ${appointmentsList.length} appointments');
        return appointmentsList;
      } else {
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(
            context: context,
            message:
                'Failed to fetch appointments: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching patient appointments: ${e.toString()}");
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return [];
    }
  }

  // Delete cached appointments for a patient to fetch fresh data
  Future<bool> refreshPatientAppointments(
    BuildContext context,
    String patientEmail,
  ) async {
    final String apiEndpoint =
        '$appointment/patient/$patientEmail/delete_cached_appointments';

    debugPrint('Refreshing appointments for patient: $patientEmail');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint(
            'Successfully refreshed appointments: ${responseData['message']}');
        showSnackBar(
            context: context, message: 'Appointments refreshed successfully');
        return true;
      } else {
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(
            context: context,
            message:
                'Failed to refresh appointments: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      debugPrint("Error refreshing patient appointments: ${e.toString()}");
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return false;
    }
  }

  // Get available slots for a doctor on a specific date
  Future<Map<String, dynamic>> getAvailableSlots(
    BuildContext context,
    String doctorCIN,
    String date,
  ) async {
    final String apiEndpoint =
        '$appointment/patient/get/available_slots/$doctorCIN/$date';

    debugPrint('Fetching available slots:');
    debugPrint('Doctor CIN: $doctorCIN');
    debugPrint('Date: $date');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> slotsData = jsonDecode(response.body);
        debugPrint(
            'Successfully fetched ${slotsData['available_slots']?.length ?? 0} available slots');
        return slotsData;
      } else {
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(
            context: context,
            message:
                'Failed to fetch available slots: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
        return {};
      }
    } catch (e) {
      debugPrint("Error fetching available slots: ${e.toString()}");
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return {};
    }
  }

  // Refresh available slots for a doctor on a specific date
  Future<bool> refreshAvailableSlots(
    BuildContext context,
    String doctorCIN,
    String date,
  ) async {
    final String apiEndpoint =
        '$appointment/refresh/available_slots/$doctorCIN/$date';

    debugPrint('Refreshing available slots:');
    debugPrint('Doctor CIN: $doctorCIN');
    debugPrint('Date: $date');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint(
            'Successfully refreshed available slots: ${responseData['message']}');
        showSnackBar(
            context: context,
            message: 'Available slots refreshed successfully');
        return true;
      } else {
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(
            context: context,
            message:
                'Failed to refresh available slots: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      debugPrint("Error refreshing available slots: ${e.toString()}");
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return false;
    }
  }

  // Get previous appointments for a patient
  Future<List<dynamic>> getPreviousAppointments(
    BuildContext context,
    String patientEmail,
  ) async {
    final String apiEndpoint =
        '$appointment/patient/previous_appointments/$patientEmail';

    debugPrint('Fetching previous appointments for patient: $patientEmail');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> appointmentsList = jsonDecode(response.body);
        debugPrint(
            'Successfully fetched ${appointmentsList.length} previous appointments');
        return appointmentsList;
      } else {
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(
            context: context,
            message:
                'Failed to fetch previous appointments: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching previous appointments: ${e.toString()}");
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return [];
    }
  }

  // Refresh previous appointments for a patient
  Future<bool> refreshPreviousAppointments(
    BuildContext context,
    String patientEmail,
  ) async {
    final String apiEndpoint =
        '$appointment/patient/refresh/previous_appointments/$patientEmail';

    debugPrint('Refreshing previous appointments for patient: $patientEmail');

    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> appointmentsList = jsonDecode(response.body);
        debugPrint(
            'Successfully refreshed ${appointmentsList.length} previous appointments');
        showSnackBar(
            context: context,
            message: 'Previous appointments refreshed successfully');
        return true;
      } else {
        debugPrint('Error: ${response.statusCode}, ${response.body}');
        showSnackBar(
            context: context,
            message:
                'Failed to refresh previous appointments: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      debugPrint("Error refreshing previous appointments: ${e.toString()}");
      showSnackBar(
          context: context,
          message:
              'Network error. Please check your connection and try again.');
      return false;
    }
  }
}
