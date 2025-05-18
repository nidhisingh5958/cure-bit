// TokenLifeguard: Optionally runs a periodic check to refresh tokens in the background.

import 'dart:async';
import 'package:CuraDocs/features/auth/repository/token/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenLifeguard {
  final TokenRepository _tokenRepository;
  Timer? _refreshTimer;

  TokenLifeguard(this._tokenRepository);

  // Start periodic token refresh
  void startPeriodicRefresh({BuildContext? context}) {
    // Check token every 15 minutes (adjust as needed)
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      debugPrint('TokenLifeguard: Running periodic token check');

      // Check if token needs refresh and refresh it
      await _tokenRepository.getAccessToken();
    });
  }

  // Stop periodic token refresh
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Force immediate token refresh
  Future<bool> forceRefresh({BuildContext? context}) async {
    return await _tokenRepository.refreshAccessToken(context: context);
  }
}

final tokenLifeguardProvider = Provider((ref) {
  final tokenRepository = ref.watch(tokenRepositoryProvider);
  return TokenLifeguard(tokenRepository);
});
