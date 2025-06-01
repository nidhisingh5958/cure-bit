import 'dart:convert';
import 'package:CureBit/services/features_api_repository/api_constant.dart';
import 'package:http/http.dart' as http;

class DoctorSearchService {
  // Method to search doctors with the given query
  static Future<List<Map<String, dynamic>>> searchDoctors(String query,
      {String? doctorCIN}) async {
    try {
      // Build the query parameters
      final queryParams = {
        'q': query,
      };

      // Add doctor_CIN if provided
      if (doctorCIN != null && doctorCIN.isNotEmpty) {
        queryParams['doctor_CIN'] = doctorCIN;
      }

      // Make GET request to the search endpoint with query parameters
      final uri = Uri.parse('$searchDoctor_api/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers if needed, like authorization tokens
        },
      );

      if (response.statusCode == 200) {
        // Parse the response
        final data = json.decode(response.body);

        // Check if the response is a list or needs to be extracted from a property
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic> &&
            data.containsKey('doctors')) {
          return List<Map<String, dynamic>>.from(data['doctors']);
        } else if (data is Map<String, dynamic> &&
            data.containsKey('results')) {
          return List<Map<String, dynamic>>.from(data['results']);
        } else if (data is Map<String, dynamic>) {
          // For other formats, try to convert directly
          // Return as a single item list if it's a valid doctor object
          return [data];
        } else {
          // If all else fails, return empty list
          return [];
        }
      } else if (response.statusCode == 422) {
        // Handle validation errors
        print('Validation error: ${response.body}');
        return [];
      } else {
        // Handle other errors
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during API call: $e');
      return [];
    }
  }

  // Method to clear search cache
  static Future<bool> clearCache({String? query}) async {
    try {
      final Uri uri = query != null
          ? Uri.parse('$searchDoctor_api/clear_cache?q=$query')
          : Uri.parse('$searchDoctor_api/clear_cache');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Exception clearing cache: $e');
      return false;
    }
  }
}
