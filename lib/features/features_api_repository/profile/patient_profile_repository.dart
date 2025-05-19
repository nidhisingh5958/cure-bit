import 'dart:convert';

import 'package:CuraDocs/features/features_api_repository/api_constant.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileRepository {
  // Singleton instance
  static final ProfileRepository _instance = ProfileRepository._internal();

  // Private constructor
  ProfileRepository._internal();

  // Factory constructor to return the singleton instance
  factory ProfileRepository() {
    return _instance;
  }

  // public profile
  Future<bool> updatePublicProfile(
    String firstName,
    String lastName,
    String fullName,
    String cin,
    String state,
    String description,
    BuildContext context,
  ) async {
    Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'cin': cin,
      'state': state,
      'description': description,
    };
    try {
      http.Response response = await http.post(
        Uri.parse('$updatePatientPublicProfile/$cin'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        showSnackBar(context: context, message: 'Profile updated successfully');
        return true;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context: context, message: 'Error updating profile: $e');
      throw Exception('Error updating profile: $e');
    }
  }

  // Future<PrivateProfileData> getPrivateProfile(String cin) async {
  //   try {
  //     http.Response response = await http.get(
  //       Uri.parse('$getPatientPrivateProfile/$cin'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = jsonDecode(response.body);
  //       return PrivateProfileData.fromJson(data);
  //     } else {
  //       throw Exception(
  //           'Failed to get private profile: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error getting private profile: $e');
  //   }
  // }
}
