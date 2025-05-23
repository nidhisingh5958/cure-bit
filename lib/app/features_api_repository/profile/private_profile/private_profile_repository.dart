// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:CuraDocs/app/features_api_repository/api_constant.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Models based on the Pydantic models from Python
class EmergencyContact {
  final String name;
  final String email;
  final String phoneNumber;
  final String countryCode;

  EmergencyContact({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'country_code': countryCode,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      countryCode: json['country_code'],
    );
  }
}

class PrivateProfileData {
  final String cin;
  final String dateOfBirth;
  final String gender;
  final String state;
  final String city;
  final String homeAddress;
  final String pincode;
  final EmergencyContact emergencyContactDetails;

  PrivateProfileData({
    required this.cin,
    required this.dateOfBirth,
    required this.gender,
    required this.state,
    required this.city,
    required this.homeAddress,
    required this.pincode,
    required this.emergencyContactDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'CIN': cin,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'state': state,
      'city': city,
      'home_address': homeAddress,
      'pincode': pincode,
      'emergency_contac_details': emergencyContactDetails.toJson(),
    };
  }

  factory PrivateProfileData.fromJson(Map<String, dynamic> json) {
    return PrivateProfileData(
      cin: json['CIN'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      state: json['state'],
      city: json['city'],
      homeAddress: json['home_address'],
      pincode: json['pincode'],
      emergencyContactDetails:
          EmergencyContact.fromJson(json['emergency_contac_details']),
    );
  }
}

class UpdatePhoneNumberEmail {
  final String? newPhoneNumber;
  final String? countryCode;
  final String? newEmail;

  UpdatePhoneNumberEmail({
    this.newPhoneNumber,
    this.countryCode,
    this.newEmail,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (newPhoneNumber != null) data['new_phone_number'] = newPhoneNumber;
    if (countryCode != null) data['country_code'] = countryCode;
    if (newEmail != null) data['new_email'] = newEmail;

    return data;
  }
}

class OtpEmail {
  final String cin;
  final String otp;
  final String newEmail;

  OtpEmail({
    required this.cin,
    required this.otp,
    required this.newEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'CIN': cin,
      'otp': otp,
      'new_email': newEmail,
    };
  }
}

class OtpPhone {
  final String cin;
  final String otp;
  final String newPhoneNumber;
  final String countryCode;

  OtpPhone({
    required this.cin,
    required this.otp,
    required this.newPhoneNumber,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'CIN': cin,
      'otp': otp,
      'new_phone_number': newPhoneNumber,
      'country_code': countryCode,
    };
  }
}

class PrivateProfileRepository {
  // Singleton instance
  static final PrivateProfileRepository _instance =
      PrivateProfileRepository._internal();

  // Private constructor
  PrivateProfileRepository._internal();

  // Factory constructor to return the singleton instance
  factory PrivateProfileRepository() {
    return _instance;
  }

  Future<bool> updatePrivateProfile(
    PrivateProfileData profile,
    BuildContext context,
    String role,
  ) async {
    try {
      final String api_endpoint =
          role == 'Doctor' ? update_private_doc : update_private_patient;

      http.Response response = await http.post(
        Uri.parse(api_endpoint),
        body: jsonEncode(profile.toJson()),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        showSnackBar(
            context: context, message: 'Private profile updated successfully');
        return true;
      } else {
        throw Exception(
            'Failed to update private profile: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(
          context: context, message: 'Error updating private profile: $e');
      throw Exception('Error updating private profile: $e');
    }
  }

  // Future<bool> updateEmergencyContact(
  //   String cin,
  //   EmergencyContact contact,
  //   BuildContext context,
  // ) async {
  //   try {
  //     http.Response response = await http.post(
  //       Uri.parse('$updateEmergencyContactDetails/$cin'),
  //       body: jsonEncode(contact.toJson()),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 302) {
  //       showSnackBar(
  //           context: context,
  //           message: 'Emergency contact updated successfully');
  //       return true;
  //     } else {
  //       throw Exception(
  //           'Failed to update emergency contact: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     showSnackBar(
  //         context: context, message: 'Error updating emergency contact: $e');
  //     throw Exception('Error updating emergency contact: $e');
  //   }
  // }

  Future<bool> requestEmailUpdate(
    String cin,
    String newEmail,
    BuildContext context,
    String role,
  ) async {
    try {
      final data = {
        'CIN': cin,
        'new_email': newEmail,
      };

      http.Response response = await http.post(
        Uri.parse('$privateProfile/$role/update_phone_number_email'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSnackBar(
            context: context, message: 'OTP sent to new email. Please verify.');
        return true;
      } else {
        throw Exception(
            'Failed to request email update: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(
          context: context, message: 'Error requesting email update: $e');
      throw Exception('Error requesting email update: $e');
    }
  }

  Future<bool> verifyEmailOtp(
    OtpEmail otpData,
    BuildContext context,
    String role,
  ) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$privateProfile/$role/verify_email_otp'),
        body: jsonEncode(otpData.toJson()),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        showSnackBar(context: context, message: 'Email updated successfully');
        return true;
      } else {
        throw Exception('Failed to verify email OTP: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context: context, message: 'Error verifying email OTP: $e');
      throw Exception('Error verifying email OTP: $e');
    }
  }

  Future<bool> requestPhoneUpdate(
    String cin,
    String newPhoneNumber,
    String countryCode,
    BuildContext context,
    String role,
  ) async {
    try {
      final data = {
        'CIN': cin,
        'new_phone_number': newPhoneNumber,
        'country_code': countryCode,
      };

      http.Response response = await http.post(
        Uri.parse('$privateProfile/$role/update_phone_number_email'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSnackBar(
            context: context,
            message: 'OTP sent to new phone number. Please verify.');
        return true;
      } else {
        throw Exception(
            'Failed to request phone update: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(
          context: context, message: 'Error requesting phone update: $e');
      throw Exception('Error requesting phone update: $e');
    }
  }

  Future<bool> verifyPhoneOtp(
    OtpPhone otpData,
    BuildContext context,
    String role,
  ) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$privateProfile/$role/verify_otp_phone'),
        body: jsonEncode(otpData.toJson()),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        showSnackBar(
            context: context, message: 'Phone number updated successfully');
        return true;
      } else {
        throw Exception('Failed to verify phone OTP: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context: context, message: 'Error verifying phone OTP: $e');
      throw Exception('Error verifying phone OTP: $e');
    }
  }

  Future<PrivateProfileData> getPrivateProfile(String cin, String role) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$privateProfile/$role/get_profile_profile_data/$cin'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PrivateProfileData.fromJson(data);
      } else {
        throw Exception(
            'Failed to get private profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting private profile: $e');
    }
  }

  Future<bool> refreshCache(
    String cin,
    BuildContext context,
    String role,
  ) async {
    try {
      String apiEndpoint;
      if (role.toLowerCase() == 'doctor') {
        apiEndpoint = '/refresh_cache/private_doctor_profile_data';
      } else if (role.toLowerCase() == 'patient') {
        apiEndpoint = '/refresh_cache/private_patient_profile_data';
      } else {
        throw Exception('Invalid role: $role. Expected "Doctor" or "Patient"');
      }

      final uri = Uri.parse('$privateProfile$apiEndpoint').replace(
        queryParameters: {'CIN': cin},
      );

      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        showSnackBar(context: context, message: 'Cache refreshed successfully');
        return true;
      } else {
        final errorMessage = response.statusCode == 422
            ? 'Validation error: Please check the CIN format'
            : 'Failed to refresh cache: ${response.statusCode}';

        showSnackBar(context: context, message: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'Error refreshing cache: $e';
      showSnackBar(context: context, message: errorMessage);
      throw Exception(errorMessage);
    }
  }

  Future<bool> refreshCacheSilent(String cin, String role) async {
    try {
      String apiEndpoint;
      if (role.toLowerCase() == 'doctor') {
        apiEndpoint = '/refresh_cache/private_doctor_profile_data';
      } else if (role.toLowerCase() == 'patient') {
        apiEndpoint = '/refresh_cache/private_patient_profile_data';
      } else {
        throw Exception('Invalid role: $role. Expected "Doctor" or "Patient"');
      }

      final uri = Uri.parse('$privateProfile$apiEndpoint').replace(
        queryParameters: {'CIN': cin},
      );

      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
