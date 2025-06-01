import 'dart:convert';
import 'package:CureBit/app/features_api_repository/api_constant.dart';
import 'package:CureBit/app/features_api_repository/profile/public_profile/patient/get/patient_public_model.dart';
import 'package:http/http.dart' as http;

final String baseUrl = '$patientPublicProfile';

class PatientPublicProfileRepository {
  final String baseUrl;
  final http.Client httpClient;

  PatientPublicProfileRepository({
    required this.baseUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Get patient public profile data
  Future<PatientPublicProfileModel> getPatientPublicProfile(String cin) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/get/patient_public_profile_data/$cin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PatientPublicProfileModel.fromJson(jsonData);
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw ValidationException(errorData['detail']);
      } else {
        throw HttpException(
          'Failed to fetch patient profile: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ValidationException || e is HttpException) {
        rethrow;
      }
      throw NetworkException('Network error occurred: $e');
    }
  }

  /// Clear patient public profile data
  Future<String> clearPatientPublicProfile(String cin) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/clear/patient_public_profile_data/$cin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return response.body
            .replaceAll('"', ''); // Remove quotes from string response
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw ValidationException(errorData['detail']);
      } else {
        throw HttpException(
          'Failed to clear patient profile: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ValidationException || e is HttpException) {
        rethrow;
      }
      throw NetworkException('Network error occurred: $e');
    }
  }

  /// Clear cache for patient public profile data
  Future<String> clearCachePatientPublicProfile(String cin) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/clear_cache/get_patient_public_profile_data/$cin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return response.body
            .replaceAll('"', ''); // Remove quotes from string response
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw ValidationException(errorData['detail']);
      } else {
        throw HttpException(
          'Failed to clear cache: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ValidationException || e is HttpException) {
        rethrow;
      }
      throw NetworkException('Network error occurred: $e');
    }
  }

  void dispose() {
    httpClient.close();
  }
}

// Custom Exception Classes
class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, this.statusCode);

  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}

class ValidationException implements Exception {
  final List<dynamic> details;

  ValidationException(this.details);

  @override
  String toString() => 'ValidationException: $details';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
