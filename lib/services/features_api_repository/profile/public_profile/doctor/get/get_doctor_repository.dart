import 'dart:convert';
import 'package:CureBit/services/features_api_repository/api_constant.dart';
import 'package:http/http.dart' as http;

final String baseUrl = '$doctorPublicProfile';

/// Exception thrown when doctor data retrieval fails
class GetDoctorProfileRepositoryException implements Exception {
  final String message;
  final int? statusCode;

  GetDoctorProfileRepositoryException(this.message, {this.statusCode});

  @override
  String toString() =>
      'GetDoctorProfileRepositoryException: $message (status: $statusCode)';
}

/// Repository for fetching doctor profile data
class GetDoctorProfileRepository {
  final http.Client _httpClient;

  GetDoctorProfileRepository({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Fetches public profile data for a doctor with the given CIN
  Future<String> getDoctorPublicProfileData(String cin) async {
    final url = Uri.parse('$baseUrl/get/doctor_public_profile_data/$cin');

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        throw GetDoctorProfileRepositoryException(
          'Validation error: ${error['detail']?[0]?['msg'] ?? 'Unknown validation error'}',
          statusCode: response.statusCode,
        );
      } else {
        throw GetDoctorProfileRepositoryException(
          'Failed to get doctor profile data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is GetDoctorProfileRepositoryException) rethrow;
      throw GetDoctorProfileRepositoryException(
          'Network error: ${e.toString()}');
    }
  }

  /// Clears doctor public profile data for a given CIN
  Future<String> clearDoctorPublicProfileData(String cin) async {
    final url = Uri.parse('$baseUrl/clear/doctor_public_profile_data/$cin');

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        throw GetDoctorProfileRepositoryException(
          'Validation error: ${error['detail']?[0]?['msg'] ?? 'Unknown validation error'}',
          statusCode: response.statusCode,
        );
      } else {
        throw GetDoctorProfileRepositoryException(
          'Failed to clear doctor profile data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is GetDoctorProfileRepositoryException) rethrow;
      throw GetDoctorProfileRepositoryException(
          'Network error: ${e.toString()}');
    }
  }

  /// Clears cache for doctor public profile data for a given CIN
  Future<String> clearCacheDoctorPublicProfileData(String cin) async {
    final url =
        Uri.parse('$baseUrl/clear_cache/get_doctor_public_profile_data/$cin');

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        throw GetDoctorProfileRepositoryException(
          'Validation error: ${error['detail']?[0]?['msg'] ?? 'Unknown validation error'}',
          statusCode: response.statusCode,
        );
      } else {
        throw GetDoctorProfileRepositoryException(
          'Failed to clear cache for doctor profile data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is GetDoctorProfileRepositoryException) rethrow;
      throw GetDoctorProfileRepositoryException(
          'Network error: ${e.toString()}');
    }
  }

  /// Closes the http client
  void dispose() {
    _httpClient.close();
  }
}
