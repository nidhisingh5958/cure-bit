import 'dart:async';
import 'package:CureBit/services/auth/token/token_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInterceptor implements InterceptorContract {
  final TokenRepository tokenRepository;

  AuthInterceptor(this.tokenRepository);

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      final token = await tokenRepository.getAccessToken();

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add content-type header if not present
      if (!request.headers.containsKey('Content-Type')) {
        request.headers['Content-Type'] = 'application/json';
      }

      return request;
    } catch (e) {
      debugPrint('Error in interceptRequest: $e');
      return request;
    }
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    // You can process the response here if needed
    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest() {
    // TODO: implement shouldInterceptRequest
    throw UnimplementedError();
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    // TODO: implement shouldInterceptResponse
    throw UnimplementedError();
  }
}

// Create a retry policy for handling token refresh
class ExpiredTokenRetryPolicy extends RetryPolicy {
  final TokenRepository tokenRepository;

  ExpiredTokenRetryPolicy(this.tokenRepository);

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (response.statusCode == 401) {
      // Try to refresh the token
      final success = await tokenRepository.refreshAccessToken();
      // Retry the request if token refresh was successful
      return success;
    }
    return false;
  }

  @override
  int get maxRetryAttempts => 2;
}

// Create an HTTP client provider with interceptors
final httpClientProvider = Provider((ref) {
  final tokenRepository = ref.watch(tokenRepositoryProvider);

  final client = InterceptedClient.build(
    interceptors: [
      AuthInterceptor(tokenRepository),
    ],
    retryPolicy: ExpiredTokenRetryPolicy(tokenRepository),
  );

  return client;
});
