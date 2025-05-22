import 'package:CuraDocs/app/features_api_repository/connect/connect_model.dart';
import 'package:CuraDocs/utils/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/app/features_api_repository/connect/connect_repository.dart';

// Create a provider for the ConnectRepository
final connectRepositoryProvider = Provider<ConnectRepository>((ref) {
  return ConnectRepository();
});

// Connection state
class ConnectionState {
  final bool isConnected;
  final bool isLoading;
  final String? error;

  ConnectionState({
    this.isConnected = false,
    this.isLoading = false,
    this.error,
  });

  ConnectionState copyWith({
    bool? isConnected,
    bool? isLoading,
    String? error,
  }) {
    return ConnectionState(
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Create a notifier for managing the connection state
class ConnectionNotifier extends StateNotifier<ConnectionState> {
  final ConnectRepository _repository;
  final Ref _ref;

  ConnectionNotifier(this._repository, this._ref) : super(ConnectionState());

  // Check connection status for a specific doctor
  Future<void> checkConnectionStatus(String doctorId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get current user ID from your user provider
      final currentUser = _ref.read(userProvider);
      if (currentUser == null || currentUser.cin == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not logged in',
          isConnected: false,
        );
        return;
      }

      final isConnected =
          await _repository.checkConnectionStatus(currentUser.cin!, doctorId);

      state = state.copyWith(
        isLoading: false,
        isConnected: isConnected,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isConnected: false,
      );
    }
  }

  // Send a connection request
  Future<void> sendConnectionRequest(String doctorId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get current user ID from your user provider
      final currentUser = _ref.read(userProvider);
      if (currentUser == null || currentUser.cin == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not logged in',
        );
        return;
      }

      // Create the connection request
      final request = ConnectionRequestModel(
        requestSentTo: doctorId,
        requestSentFrom: currentUser.cin!,
        timestamp: DateTime.now().toUtc().toIso8601String(),
        connectionType: 'doctor_patient', // Default type for this app
      );

      // Send the request
      final response = await _repository.sendConnectionRequest(request);

      // Update the state based on the response
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          isConnected: true,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to connect: ${response.message}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Disconnect (implementation would depend on your backend API)
  void disconnect() {
    // This would typically call an API to remove the connection
    // For now, we'll just update the local state
    state = state.copyWith(isConnected: false);
  }

  // Toggle connection state
  Future<void> toggleConnection(String doctorId) async {
    if (state.isConnected) {
      disconnect();
    } else {
      await sendConnectionRequest(doctorId);
    }
  }
}

// Provide the connection notifier
final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  final repository = ref.watch(connectRepositoryProvider);
  return ConnectionNotifier(repository, ref);
});
