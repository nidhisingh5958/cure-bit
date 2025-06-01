// TokenLifeguard: Runs periodic checks to refresh tokens in the background

import 'dart:async';
import 'package:CureBit/services/auth/token/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LifeguardState {
  stopped,
  running,
  paused,
}

class TokenLifeguard {
  final TokenRepository _tokenRepository;
  Timer? _refreshTimer;
  LifeguardState _state = LifeguardState.stopped;
  Duration _refreshInterval = const Duration(minutes: 15);
  DateTime? _lastRefreshCheck;

  TokenLifeguard(this._tokenRepository);

  // Get current lifeguard state
  LifeguardState get state => _state;

  // Get last refresh check time
  DateTime? get lastRefreshCheck => _lastRefreshCheck;

  // Start periodic token refresh
  void startPeriodicRefresh({
    BuildContext? context,
    Duration? customInterval,
  }) {
    debugPrint('TokenLifeguard: Starting periodic token refresh');

    // Use custom interval if provided
    if (customInterval != null) {
      _refreshInterval = customInterval;
    }

    // Cancel any existing timer
    _refreshTimer?.cancel();

    // Start the periodic timer
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) async {
      await _performPeriodicCheck(context);
    });

    _state = LifeguardState.running;
    debugPrint(
        'TokenLifeguard: Started with ${_refreshInterval.inMinutes} minute intervals');
  }

  // Stop periodic token refresh completely
  void stopPeriodicRefresh() {
    debugPrint('TokenLifeguard: Stopping periodic token refresh');

    _refreshTimer?.cancel();
    _refreshTimer = null;
    _state = LifeguardState.stopped;
    _lastRefreshCheck = null;

    debugPrint('TokenLifeguard: Stopped completely');
  }

  // Pause periodic token refresh (keeps timer but skips execution)
  void pausePeriodicRefresh() {
    if (_state == LifeguardState.running) {
      debugPrint('TokenLifeguard: Pausing periodic token refresh');
      _state = LifeguardState.paused;
      debugPrint(
          'TokenLifeguard: Paused (timer continues but checks are skipped)');
    } else {
      debugPrint('TokenLifeguard: Cannot pause - not currently running');
    }
  }

  // Resume periodic token refresh
  void resumePeriodicRefresh({BuildContext? context}) {
    if (_state == LifeguardState.paused) {
      debugPrint('TokenLifeguard: Resuming periodic token refresh');
      _state = LifeguardState.running;

      // Perform immediate check on resume
      _performPeriodicCheck(context);

      debugPrint('TokenLifeguard: Resumed and performed immediate check');
    } else if (_state == LifeguardState.stopped) {
      debugPrint(
          'TokenLifeguard: Starting fresh periodic refresh (was stopped)');
      startPeriodicRefresh(context: context);
    } else {
      debugPrint('TokenLifeguard: Already running, no action needed');
    }
  }

  // Force immediate token refresh
  Future<bool> forceRefresh({BuildContext? context}) async {
    debugPrint('TokenLifeguard: Force refreshing token');

    try {
      final result =
          await _tokenRepository.refreshAccessToken(context: context);
      _lastRefreshCheck = DateTime.now();

      debugPrint('TokenLifeguard: Force refresh result: $result');
      return result;
    } catch (e) {
      debugPrint('TokenLifeguard: Force refresh failed: $e');
      return false;
    }
  }

  // Internal method to perform periodic checks
  Future<void> _performPeriodicCheck(BuildContext? context) async {
    // Skip if paused
    if (_state == LifeguardState.paused) {
      debugPrint('TokenLifeguard: Skipping check - currently paused');
      return;
    }

    debugPrint('TokenLifeguard: Running periodic token check');
    _lastRefreshCheck = DateTime.now();

    try {
      // Check if we have tokens and if they need refresh
      final tokens = await _tokenRepository.getTokens();

      if (tokens == null) {
        debugPrint('TokenLifeguard: No tokens found, stopping lifeguard');
        stopPeriodicRefresh();
        return;
      }

      if (tokens.isNearExpiry) {
        debugPrint('TokenLifeguard: Token is near expiry, refreshing...');
        final refreshed =
            await _tokenRepository.refreshAccessToken(context: context);

        if (refreshed) {
          debugPrint('TokenLifeguard: Token refreshed successfully');
        } else {
          debugPrint('TokenLifeguard: Token refresh failed');
        }
      } else {
        debugPrint('TokenLifeguard: Token is still valid, no refresh needed');
      }
    } catch (e) {
      debugPrint('TokenLifeguard: Error during periodic check: $e');
    }
  }

  // Check if lifeguard is active (running or paused but not stopped)
  bool get isActive => _state != LifeguardState.stopped;

  // Check if lifeguard is currently running checks
  bool get isRunning => _state == LifeguardState.running;

  // Check if lifeguard is paused
  bool get isPaused => _state == LifeguardState.paused;

  // Get time until next scheduled check (if running)
  Duration? get timeUntilNextCheck {
    if (_refreshTimer == null || !isRunning) return null;

    if (_lastRefreshCheck == null) {
      return _refreshInterval;
    }

    final elapsed = DateTime.now().difference(_lastRefreshCheck!);
    final remaining = _refreshInterval - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Update refresh interval (will take effect on next start)
  void setRefreshInterval(Duration interval) {
    _refreshInterval = interval;
    debugPrint(
        'TokenLifeguard: Refresh interval updated to ${interval.inMinutes} minutes');

    // If currently running, restart with new interval
    if (_state == LifeguardState.running) {
      debugPrint('TokenLifeguard: Restarting with new interval');
      final context =
          null; // We don't have context here, but that's okay for restart
      startPeriodicRefresh(context: context);
    }
  }

  // Get current refresh interval
  Duration get refreshInterval => _refreshInterval;

  // Clean up resources
  void dispose() {
    debugPrint('TokenLifeguard: Disposing resources');
    stopPeriodicRefresh();
  }
}

// Enhanced provider with better lifecycle management
final tokenLifeguardProvider = Provider((ref) {
  final tokenRepository = ref.watch(tokenRepositoryProvider);
  final lifeguard = TokenLifeguard(tokenRepository);

  // Clean up when provider is disposed
  ref.onDispose(() {
    lifeguard.dispose();
  });

  return lifeguard;
});

// Provider to watch lifeguard state
final tokenLifeguardStateProvider = Provider<LifeguardState>((ref) {
  final lifeguard = ref.watch(tokenLifeguardProvider);
  // This won't automatically update, but can be manually refreshed
  return lifeguard.state;
});

// Provider to check if lifeguard is active
final isTokenLifeguardActiveProvider = Provider<bool>((ref) {
  final lifeguard = ref.watch(tokenLifeguardProvider);
  return lifeguard.isActive;
});
