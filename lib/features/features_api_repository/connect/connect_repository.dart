import 'dart:convert';
import 'package:CuraDocs/features/features_api_repository/api_constant.dart';
import 'package:CuraDocs/features/features_api_repository/connect/connect_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectRepository {
  final http.Client _client;

  ConnectRepository({http.Client? client}) : _client = client ?? http.Client();

  // Send a connection request to another user
  Future<ConnectionResponseModel> sendConnectionRequest(
      ConnectionRequestModel request) async {
    try {
      final response = await _client.post(
        Uri.parse('$connect_api/connect/request'),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers needed for your API
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ConnectionResponseModel.fromJson(responseData);
      } else {
        // Handle specific error cases
        if (responseData.containsKey('message')) {
          throw Exception(responseData['message']);
        } else {
          throw Exception(
              'Failed to send connection request: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error sending connection request: $e');
      rethrow;
    }
  }

  // Accept a connection request
  Future<ConnectionResponseModel> acceptConnectionRequest(
      ConnectionRequestModel request) async {
    try {
      final response = await _client.post(
        Uri.parse('$connect_api/connect/accept'),
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers needed for your API
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ConnectionResponseModel.fromJson(responseData);
      } else {
        // Handle specific error cases
        if (responseData.containsKey('message')) {
          throw Exception(responseData['message']);
        } else {
          throw Exception(
              'Failed to accept connection request: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error accepting connection request: $e');
      rethrow;
    }
  }

  // Optional: Check if a connection exists (implementation depends on your backend)
  Future<bool> checkConnectionStatus(
      String currentUserId, String targetUserId) async {
    // This is a placeholder and would need implementation based on your API
    // You might need to add a new endpoint to check connection status

    try {
      // Simulated response for now - implement with actual API endpoint
      await Future.delayed(Duration(milliseconds: 300));
      return false; // Default to not connected
    } catch (e) {
      debugPrint('Error checking connection status: $e');
      return false; // Default to not connected in case of error
    }
  }
}
