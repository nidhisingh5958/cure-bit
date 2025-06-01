import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:CureBit/utils/routes/route_constants.dart';

/// Utility class for doctor-related navigation
class DoctorNavigationUtil {
  /// Navigate to doctor profile by CIN (Doctor ID)
  static void navigateToDoctorProfile(BuildContext context, String doctorCin) {
    if (doctorCin.isEmpty) {
      _showErrorSnackBar(context, 'Doctor information not available');
      return;
    }

    context.goNamed(
      RouteConstants
          .doctorProfile, // Make sure this route exists in your routes
      pathParameters: {'doctorCin': doctorCin},
    );
  }

  /// Navigate to doctor profile with query parameters (alternative approach)
  static void navigateToDoctorProfileWithQuery(
    BuildContext context,
    String doctorCin, {
    String? doctorName,
    String? specialty,
  }) {
    if (doctorCin.isEmpty) {
      _showErrorSnackBar(context, 'Doctor information not available');
      return;
    }

    final queryParams = <String, String>{'doctorCin': doctorCin};
    if (doctorName != null) queryParams['doctorName'] = doctorName;
    if (specialty != null) queryParams['specialty'] = specialty;

    context.goNamed(
      RouteConstants.doctorProfile,
      queryParameters: queryParams,
    );
  }

  /// Navigate to doctor profile from any doctor model/object
  static void navigateToDoctorProfileFromModel(
    BuildContext context,
    dynamic doctorModel,
  ) {
    String? doctorCin;
    String? doctorName;
    String? specialty;

    // Handle different doctor model types
    if (doctorModel is Map<String, dynamic>) {
      doctorCin =
          doctorModel['cin'] ?? doctorModel['id'] ?? doctorModel['doctorId'];
      doctorName = doctorModel['name'] ?? doctorModel['doctorName'];
      specialty = doctorModel['specialty'] ?? doctorModel['specialization'];
    } else {
      // Use reflection-like approach for custom objects
      try {
        // Try to get CIN from common property names
        if (doctorModel.toString().contains('cin:')) {
          final match =
              RegExp(r'cin:\s*([^,\)]+)').firstMatch(doctorModel.toString());
          doctorCin = match?.group(1)?.trim();
        }

        // For your DoctorProfileModel or similar models
        if (doctorModel.runtimeType.toString().contains('Doctor')) {
          // Try to access common properties
          try {
            doctorCin = (doctorModel as dynamic).cin;
          } catch (e) {
            try {
              doctorCin = (doctorModel as dynamic).id;
            } catch (e) {
              try {
                doctorCin = (doctorModel as dynamic).doctorId;
              } catch (e) {
                // Handle other cases
              }
            }
          }

          try {
            doctorName = (doctorModel as dynamic).name;
          } catch (e) {
            try {
              doctorName = (doctorModel as dynamic).doctorName;
            } catch (e) {
              // Handle other cases
            }
          }

          try {
            specialty = (doctorModel as dynamic).specialty;
          } catch (e) {
            try {
              specialty = (doctorModel as dynamic).specialization;
            } catch (e) {
              // Handle other cases
            }
          }
        }
      } catch (e) {
        debugPrint('Error extracting doctor info: $e');
      }
    }

    if (doctorCin == null || doctorCin.isEmpty) {
      _showErrorSnackBar(context, 'Doctor CIN not found');
      return;
    }

    navigateToDoctorProfileWithQuery(
      context,
      doctorCin,
      doctorName: doctorName,
      specialty: specialty,
    );
  }

  /// Navigate with custom route if needed
  static void navigateWithCustomRoute(
    BuildContext context,
    String doctorCin, {
    String? routeName,
    Map<String, String>? additionalParams,
  }) {
    if (doctorCin.isEmpty) {
      _showErrorSnackBar(context, 'Doctor information not available');
      return;
    }

    final params = <String, String>{'doctorCin': doctorCin};
    if (additionalParams != null) {
      params.addAll(additionalParams);
    }

    context.goNamed(
      routeName ?? RouteConstants.doctorProfile,
      queryParameters: params,
    );
  }

  /// Show error message
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Extension on BuildContext for easier access
extension DoctorNavigationExtension on BuildContext {
  /// Navigate to doctor profile
  void goToDoctorProfile(String doctorCin) {
    DoctorNavigationUtil.navigateToDoctorProfile(this, doctorCin);
  }

  /// Navigate to doctor profile from any doctor object
  void goToDoctorProfileFromModel(dynamic doctorModel) {
    DoctorNavigationUtil.navigateToDoctorProfileFromModel(this, doctorModel);
  }

  /// Navigate to doctor profile with additional info
  void goToDoctorProfileWithInfo(
    String doctorCin, {
    String? doctorName,
    String? specialty,
  }) {
    DoctorNavigationUtil.navigateToDoctorProfileWithQuery(
      this,
      doctorCin,
      doctorName: doctorName,
      specialty: specialty,
    );
  }
}
