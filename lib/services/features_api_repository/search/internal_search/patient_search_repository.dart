import 'dart:convert';
import 'package:CureBit/services/features_api_repository/api_constant.dart';
import 'package:http/http.dart' as http;

class PatientSearchRepository {
  final String baseUrl = searchPatient_api;

  /// Search for patients based on query and doctor's CIN
  ///
  /// [query] - The search query string
  /// [doctorCIN] - The doctor's unique identification number
  Future<List<dynamic>> searchPatients(String query, String doctorCIN) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/internal_search?q=$query&doctor_CIN=$doctorCIN'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'] ?? [];
      } else {
        throw Exception('Failed to search patients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching patients: $e');
    }
  }

  /// Refresh the search index to fetch new results
  ///
  /// [query] - The search query string
  /// [doctorCIN] - The doctor's unique identification number
  Future<bool> refreshSearchIndex(String query, String doctorCIN) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/refresh_index?q=$query&doctor_CIN=$doctorCIN'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to refresh index: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error refreshing index: $e');
    }
  }
}
