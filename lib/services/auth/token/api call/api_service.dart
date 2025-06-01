// api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:CureBit/services/auth/token/api%20call/api_interceptor.dart';
import 'package:CureBit/services/auth/token/token_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:CureBit/utils/providers/auth_providers.dart';

// Class to hold API configuration
class ApiConfig {
  // Base URL - should be different per environment
  static const String baseUrl = String.fromEnvironment('BASE_URL',
      defaultValue:
          'http://CureBit-auth-dev-444651946.us-east-1.elb.amazonaws.com');

  // Default timeout duration
  static const Duration defaultTimeout = Duration(seconds: 30);

  // Maximum number of retries for a request
  static const int maxRetries = 1;
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status code: $statusCode)';
}

// Provide the ApiService to the app
final apiServiceProvider = Provider((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final tokenRepository = ref.watch(tokenRepositoryProvider);
  final authNotifier = ref.watch(authStateProvider.notifier);
  return ApiService(httpClient, tokenRepository, authNotifier);
});

// Main API service class
class ApiService {
  final http.Client _httpClient;
  final TokenRepository _tokenRepository;
  final AuthStateNotifier _authNotifier;

  ApiService(this._httpClient, this._tokenRepository, this._authNotifier);

  // Build the full URL with base and endpoint
  Uri _buildUrl(String endpoint) {
    final String baseUrl = ApiConfig.baseUrl;
    final String fullUrl =
        endpoint.startsWith('/') ? '$baseUrl$endpoint' : '$baseUrl/$endpoint';
    return Uri.parse(fullUrl);
  }

  // Prepare headers with token and content type
  Future<Map<String, String>> _prepareHeaders(
      {Map<String, String>? additionalHeaders,
      bool requiresAuth = true}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _tokenRepository.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  // Handle response based on status code
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final statusCode = response.statusCode;

    try {
      // Try to parse JSON response, fall back to empty map if not valid JSON
      final Map<String, dynamic> body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : {};

      // Success responses
      if (statusCode >= 200 && statusCode < 300) {
        return body;
      }

      // Handle specific error codes
      switch (statusCode) {
        case 401:
          // Unauthorized - this should be handled by interceptors but as a fallback
          throw ApiException('Unauthorized access',
              statusCode: statusCode, data: body);
        case 403:
          // Forbidden
          throw ApiException('Access forbidden',
              statusCode: statusCode, data: body);
        case 404:
          // Not found
          throw ApiException('Resource not found',
              statusCode: statusCode, data: body);
        case 422:
          // Validation errors
          throw ApiException(body['message'] ?? 'Validation failed',
              statusCode: statusCode, data: body);
        case 500:
        case 502:
        case 503:
          // Server errors
          throw ApiException('Server error occurred',
              statusCode: statusCode, data: body);
        default:
          // Generic error
          throw ApiException(
              body['message'] ?? 'Request failed with status: $statusCode',
              statusCode: statusCode,
              data: body);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      // For parsing errors or other issues
      throw ApiException('Failed to process response: ${e.toString()}',
          statusCode: statusCode);
    }
  }

  // Execute a request with retry logic
  Future<Map<String, dynamic>> _executeRequest(
      Future<http.Response> Function() requestFn,
      {int retryCount = 0}) async {
    try {
      final response = await requestFn().timeout(ApiConfig.defaultTimeout);
      return await _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on ApiException catch (e) {
      // If unauthorized and we haven't exceeded retry limit, attempt token refresh
      if (e.statusCode == 401 && retryCount < ApiConfig.maxRetries) {
        final refreshed = await _tokenRepository.refreshAccessToken();
        if (refreshed) {
          // Retry with incremented retry count
          return _executeRequest(requestFn, retryCount: retryCount + 1);
        } else {
          // Token refresh failed, logout user
          _authNotifier.logout();
          rethrow;
        }
      }
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final requestHeaders = await _prepareHeaders(
        additionalHeaders: headers, requiresAuth: requiresAuth);

    Uri url = _buildUrl(endpoint);
    if (queryParameters != null) {
      url = url.replace(queryParameters: {
        ...url.queryParameters,
        ...queryParameters.map((key, value) => MapEntry(key, value.toString())),
      });
    }

    return _executeRequest(() => _httpClient.get(url, headers: requestHeaders));
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool requiresAuth = true,
  }) async {
    final requestHeaders = await _prepareHeaders(
        additionalHeaders: headers, requiresAuth: requiresAuth);

    final encodedBody = body is String ? body : jsonEncode(body ?? {});

    return _executeRequest(() => _httpClient.post(
          _buildUrl(endpoint),
          headers: requestHeaders,
          body: encodedBody,
        ));
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool requiresAuth = true,
  }) async {
    final requestHeaders = await _prepareHeaders(
        additionalHeaders: headers, requiresAuth: requiresAuth);

    final encodedBody = body is String ? body : jsonEncode(body ?? {});

    return _executeRequest(() => _httpClient.put(
          _buildUrl(endpoint),
          headers: requestHeaders,
          body: encodedBody,
        ));
  }

  // PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool requiresAuth = true,
  }) async {
    final requestHeaders = await _prepareHeaders(
        additionalHeaders: headers, requiresAuth: requiresAuth);

    final encodedBody = body is String ? body : jsonEncode(body ?? {});

    return _executeRequest(() => _httpClient.patch(
          _buildUrl(endpoint),
          headers: requestHeaders,
          body: encodedBody,
        ));
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool requiresAuth = true,
  }) async {
    final requestHeaders = await _prepareHeaders(
        additionalHeaders: headers, requiresAuth: requiresAuth);

    final encodedBody =
        body != null ? (body is String ? body : jsonEncode(body)) : null;

    return _executeRequest(() => _httpClient.delete(
          _buildUrl(endpoint),
          headers: requestHeaders,
          body: encodedBody,
        ));
  }

  // Upload file(s) with multipart request
  Future<Map<String, dynamic>> uploadFiles(
    String endpoint, {
    required Map<String, List<http.MultipartFile>> files,
    Map<String, String>? fields,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final requestHeaders = await _prepareHeaders(
        additionalHeaders: headers, requiresAuth: requiresAuth);

    // Remove content-type as it will be set by multipart request
    requestHeaders.remove('Content-Type');

    return _executeRequest(() async {
      final request = http.MultipartRequest(
        'POST',
        _buildUrl(endpoint),
      );

      // Add headers
      request.headers.addAll(requestHeaders);

      // Add text fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      files.forEach((fieldName, fileList) {
        for (final file in fileList) {
          request.files.add(file);
        }
      });

      // Send the request
      final streamedResponse = await request.send();

      // Convert to regular response
      return http.Response.fromStream(streamedResponse);
    });
  }

  // Download file
  Future<List<int>> downloadFile(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final requestHeaders = await _prepareHeaders(
        additionalHeaders: headers, requiresAuth: requiresAuth);

    Uri url = _buildUrl(endpoint);
    if (queryParameters != null) {
      url = url.replace(queryParameters: {
        ...url.queryParameters,
        ...queryParameters.map((key, value) => MapEntry(key, value.toString())),
      });
    }

    try {
      final response = await _httpClient
          .get(url, headers: requestHeaders)
          .timeout(ApiConfig.defaultTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        // Try to parse error message from response
        throw ApiException(
            'Failed to download file: Status code ${response.statusCode}',
            statusCode: response.statusCode);
      }
    } on TimeoutException {
      throw ApiException('File download timed out');
    } on http.ClientException catch (e) {
      throw ApiException('Network error during file download: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
          'Unexpected error during file download: ${e.toString()}');
    }
  }
}
