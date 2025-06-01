import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:CureBit/utils/routes/route_constants.dart';

/// Utility class for handling patient profile navigation
/// This provides a consistent way to navigate to patient profiles across the app
class PatientNavigationUtils {
  /// Navigate to patient profile using patient CIN
  /// This is the primary method that should be used for navigation
  static void navigateToPatientProfile(
    BuildContext context, {
    required String patientCin,
    String? patientName,
    bool showErrorSnackbar = true,
  }) {
    // Validate CIN
    if (patientCin.isEmpty) {
      if (showErrorSnackbar) {
        _showErrorSnackbar(
            context,
            patientName != null
                ? 'Patient information not available for $patientName'
                : 'Patient information not available');
      }
      return;
    }

    try {
      // Navigate to patient profile screen using CIN as path parameter
      context.goNamed(
        RouteConstants.doctorPatientProfile,
        pathParameters: {'patientCin': patientCin},
      );
    } catch (e) {
      if (showErrorSnackbar) {
        _showErrorSnackbar(
            context, 'Unable to open patient profile. Please try again.');
      }
      debugPrint('Error navigating to patient profile: $e');
    }
  }

  /// Navigate to patient profile from Patient object (used in schedule screen)
  static void navigateFromPatientObject(
    BuildContext context,
    dynamic patient, {
    bool showErrorSnackbar = true,
  }) {
    String patientCin = '';
    String patientName = '';

    // Extract CIN and name from different possible object structures
    if (patient is Map<String, dynamic>) {
      patientCin = patient['patientCin'] ??
          patient['patient_cin'] ??
          patient['cin'] ??
          patient['id'] ??
          '';
      patientName = patient['name'] ??
          patient['patient_name'] ??
          patient['patientName'] ??
          '';
    } else {
      // Handle custom objects with reflection-like access
      try {
        // Try to access patientCin property
        patientCin = _getProperty(patient, 'patientCin') ??
            _getProperty(patient, 'cin') ??
            _getProperty(patient, 'id') ??
            '';
        patientName = _getProperty(patient, 'name') ?? '';
      } catch (e) {
        debugPrint('Error extracting patient info: $e');
      }
    }

    navigateToPatientProfile(
      context,
      patientCin: patientCin,
      patientName: patientName,
      showErrorSnackbar: showErrorSnackbar,
    );
  }

  /// Navigate to patient profile from PatientData object (used in patients list)
  static void navigateFromPatientData(
    BuildContext context,
    dynamic patientData, {
    bool showErrorSnackbar = true,
  }) {
    String patientCin = '';
    String patientName = '';

    if (patientData is Map<String, dynamic>) {
      patientCin = patientData['id'] ?? patientData['cin'] ?? '';
      patientName = patientData['name'] ?? '';
    } else {
      // Handle PatientData object
      try {
        patientCin = _getProperty(patientData, 'id') ??
            _getProperty(patientData, 'cin') ??
            '';
        patientName = _getProperty(patientData, 'name') ?? '';
      } catch (e) {
        debugPrint('Error extracting patient data: $e');
      }
    }

    navigateToPatientProfile(
      context,
      patientCin: patientCin,
      patientName: patientName,
      showErrorSnackbar: showErrorSnackbar,
    );
  }

  /// Navigate with additional context - useful for search results or complex objects
  static void navigateWithContext(
    BuildContext context, {
    required String patientCin,
    String? patientName,
    Map<String, dynamic>? additionalData,
    bool showErrorSnackbar = true,
  }) {
    if (patientCin.isEmpty) {
      if (showErrorSnackbar) {
        _showErrorSnackbar(
            context,
            patientName != null
                ? 'Unable to access profile for $patientName'
                : 'Patient profile not accessible');
      }
      return;
    }

    try {
      // You can pass additional data as query parameters if needed
      final queryParams = <String, String>{};

      if (additionalData != null) {
        additionalData.forEach((key, value) {
          if (value != null) {
            queryParams[key] = value.toString();
          }
        });
      }

      context.goNamed(
        RouteConstants.doctorPatientProfile,
        pathParameters: {'patientCin': patientCin},
        queryParameters: queryParams.isNotEmpty
            ? Map<String, dynamic>.from(queryParams)
            : {},
      );
    } catch (e) {
      if (showErrorSnackbar) {
        _showErrorSnackbar(
            context, 'Unable to open patient profile. Please try again.');
      }
      debugPrint('Error navigating to patient profile with context: $e');
    }
  }

  /// Check if patient CIN is valid for navigation
  static bool canNavigateToPatient(dynamic patient) {
    if (patient == null) return false;

    String patientCin = '';

    if (patient is Map<String, dynamic>) {
      patientCin = patient['patientCin'] ??
          patient['patient_cin'] ??
          patient['cin'] ??
          patient['id'] ??
          '';
    } else {
      try {
        patientCin = _getProperty(patient, 'patientCin') ??
            _getProperty(patient, 'cin') ??
            _getProperty(patient, 'id') ??
            '';
      } catch (e) {
        return false;
      }
    }

    return patientCin.isNotEmpty;
  }

  /// Helper method to show consistent error messages
  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Helper method to get property from object using reflection-like access
  static String? _getProperty(dynamic object, String propertyName) {
    try {
      // This is a simplified version - you might need to adjust based on your object structure
      final mirror = object.toString();

      // For debugging - you can remove this in production
      debugPrint('Trying to access $propertyName from ${object.runtimeType}');

      // Since Dart doesn't have easy reflection, we'll try direct property access
      // You might need to modify this based on your actual object structures

      switch (propertyName) {
        case 'patientCin':
          return object?.patientCin?.toString();
        case 'cin':
          return object?.cin?.toString();
        case 'id':
          return object?.id?.toString();
        case 'name':
          return object?.name?.toString();
        default:
          return null;
      }
    } catch (e) {
      debugPrint('Error accessing property $propertyName: $e');
      return null;
    }
  }
}

/// Extension methods for easier navigation from common objects
extension PatientNavigation on BuildContext {
  /// Navigate to patient profile - direct CIN method
  void goToPatientProfile(String patientCin, {String? patientName}) {
    PatientNavigationUtils.navigateToPatientProfile(
      this,
      patientCin: patientCin,
      patientName: patientName,
    );
  }

  /// Navigate from patient object
  void goToPatientFromObject(dynamic patient) {
    PatientNavigationUtils.navigateFromPatientObject(this, patient);
  }

  /// Navigate from patient data
  void goToPatientFromData(dynamic patientData) {
    PatientNavigationUtils.navigateFromPatientData(this, patientData);
  }
}
