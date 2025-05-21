import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Base URL for the API
const String baseUrl = 'https://1x2bvr1k-8010.inc1.devtunnels.ms';

// Exception class for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? details;

  ApiException({
    required this.message,
    required this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}

// Model for validation error responses
class ValidationErrorResponse {
  final List<ValidationErrorDetail> details;

  ValidationErrorResponse({required this.details});

  factory ValidationErrorResponse.fromJson(Map<String, dynamic> json) {
    final detailsList = (json['detail'] as List)
        .map((detail) => ValidationErrorDetail.fromJson(detail))
        .toList();
    return ValidationErrorResponse(details: detailsList);
  }
}

class ValidationErrorDetail {
  final List<dynamic> loc;
  final String msg;
  final String type;

  ValidationErrorDetail({
    required this.loc,
    required this.msg,
    required this.type,
  });

  factory ValidationErrorDetail.fromJson(Map<String, dynamic> json) {
    return ValidationErrorDetail(
      loc: json['loc'] as List<dynamic>,
      msg: json['msg'] as String,
      type: json['type'] as String,
    );
  }
}

// Model for cache refresh responses
class CacheRefreshResponse {
  final String message;
  final int statusCode;

  CacheRefreshResponse({
    required this.message,
    required this.statusCode,
  });

  factory CacheRefreshResponse.fromJson(Map<String, dynamic> json) {
    return CacheRefreshResponse(
      message: json['message'] as String,
      statusCode: json['status_code'] as int,
    );
  }
}

// Abstract repository interface
abstract class PrivateProfileRepository {
  // Patient profile methods
  Future<dynamic> getPatientProfileData(String cin);
  Future<CacheRefreshResponse> refreshPatientProfileCache(String cin);

  // Doctor profile methods
  Future<dynamic> getDoctorProfileData(String cin);
  Future<dynamic> refreshDoctorProfileCache(String cin);
}

// Concrete implementation of the repository
class PrivateProfileRepositoryImpl implements PrivateProfileRepository {
  final http.Client _httpClient;

  PrivateProfileRepositoryImpl({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  Future<dynamic> getPatientProfileData(String cin) async {
    final uri = Uri.parse('$baseUrl/patient/get_profile_profile_data')
        .replace(queryParameters: {'CIN': cin});

    final response = await _httpClient.get(
      uri,
      headers: {'accept': 'application/json'},
    );

    return _handleResponse(response);
  }

  @override
  Future<CacheRefreshResponse> refreshPatientProfileCache(String cin) async {
    final uri = Uri.parse('$baseUrl/refresh_cache/private_patient_profile_data')
        .replace(queryParameters: {'CIN': cin});

    final response = await _httpClient.get(
      uri,
      headers: {'accept': 'application/json'},
    );

    final data = _handleResponse(response);
    return CacheRefreshResponse.fromJson(data);
  }

  @override
  Future<dynamic> getDoctorProfileData(String cin) async {
    final uri = Uri.parse('$baseUrl/doctor/get_profile_profile_data')
        .replace(queryParameters: {'CIN': cin});

    final response = await _httpClient.get(
      uri,
      headers: {'accept': 'application/json'},
    );

    return _handleResponse(response);
  }

  @override
  Future<dynamic> refreshDoctorProfileCache(String cin) async {
    final uri = Uri.parse('$baseUrl/refresh_cache/private_doctor_profile_data')
        .replace(queryParameters: {'CIN': cin});

    final response = await _httpClient.get(
      uri,
      headers: {'accept': 'application/json'},
    );

    return _handleResponse(response);
  }

  // Helper method to handle API responses
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = utf8.decode(response.bodyBytes);

    if (statusCode == 200) {
      // For string responses
      if (responseBody.startsWith('"') && responseBody.endsWith('"')) {
        return responseBody.substring(1, responseBody.length - 1);
      }
      // For JSON responses
      try {
        return jsonDecode(responseBody);
      } catch (e) {
        return responseBody;
      }
    } else if (statusCode == 422) {
      final error = ValidationErrorResponse.fromJson(jsonDecode(responseBody));
      throw ApiException(
        message: 'Validation error',
        statusCode: statusCode,
        details: {'validation_errors': error.details},
      );
    } else {
      throw ApiException(
        message: 'Request failed with status: $statusCode',
        statusCode: statusCode,
      );
    }
  }
}

// Riverpod provider for the repository
final privateProfileRepositoryProvider =
    Provider<PrivateProfileRepository>((ref) {
  return PrivateProfileRepositoryImpl();
});

// Provider for patient profile data
final patientProfileDataProvider =
    FutureProvider.family<dynamic, String>((ref, cin) async {
  final repository = ref.watch(privateProfileRepositoryProvider);
  return repository.getPatientProfileData(cin);
});

// Provider for doctor profile data
final doctorProfileDataProvider =
    FutureProvider.family<dynamic, String>((ref, cin) async {
  final repository = ref.watch(privateProfileRepositoryProvider);
  return repository.getDoctorProfileData(cin);
});

// Provider for refreshing patient profile cache
final refreshPatientProfileCacheProvider =
    FutureProvider.family<CacheRefreshResponse, String>((ref, cin) async {
  final repository = ref.watch(privateProfileRepositoryProvider);
  final result = await repository.refreshPatientProfileCache(cin);

  // Invalidate the patient profile data provider to force a refresh
  ref.invalidate(patientProfileDataProvider(cin));

  return result;
});

// Provider for refreshing doctor profile cache
final refreshDoctorProfileCacheProvider =
    FutureProvider.family<dynamic, String>((ref, cin) async {
  final repository = ref.watch(privateProfileRepositoryProvider);
  final result = await repository.refreshDoctorProfileCache(cin);

  // Invalidate the doctor profile data provider to force a refresh
  ref.invalidate(doctorProfileDataProvider(cin));

  return result;
});
