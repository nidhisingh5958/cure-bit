import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CureBit/services/features_api_repository/appointment/patient/get/get_patient_repository.dart';

// Define the state class for available slots
class AvailableSlotsState {
  final bool isLoading;
  final List<Map<String, dynamic>> availableSlots;
  final List<DateTime> nonWorkingDays;
  final String? errorMessage;

  const AvailableSlotsState({
    this.isLoading = false,
    this.availableSlots = const [],
    this.nonWorkingDays = const [],
    this.errorMessage,
  });

  // Create a copy of this state with some properties changed
  AvailableSlotsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? availableSlots,
    List<DateTime>? nonWorkingDays,
    String? errorMessage,
  }) {
    return AvailableSlotsState(
      isLoading: isLoading ?? this.isLoading,
      availableSlots: availableSlots ?? this.availableSlots,
      nonWorkingDays: nonWorkingDays ?? this.nonWorkingDays,
      errorMessage: errorMessage,
    );
  }
}

// Define the provider notifier
class AvailableSlotsNotifier extends StateNotifier<AvailableSlotsState> {
  final GetPatientRepository _repository;

  AvailableSlotsNotifier(this._repository) : super(const AvailableSlotsState());

  // Fetch available slots for a doctor on a specific date
  Future<void> fetchAvailableSlots(
    BuildContext context,
    String doctorCIN,
    DateTime date,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final formattedDate = _formatDate(date);
      final slotsData = await _repository.getAvailableSlots(
        context,
        doctorCIN,
        formattedDate,
      );

      if (slotsData.isNotEmpty) {
        // Extract available slots and format them properly
        final List<dynamic> rawSlots = slotsData['available_slots'] ?? [];
        final List<Map<String, dynamic>> formattedSlots = rawSlots.map((slot) {
          // Extract address from slot if available, or use default
          final String address = slot['address'] ?? 'Default clinic address';
          return {
            'time': slot['time'],
            'address': address,
          };
        }).toList();

        // Extract non-working days if available
        final List<dynamic> rawNonWorkingDays =
            slotsData['non_working_days'] ?? [];
        final List<DateTime> parsedNonWorkingDays = rawNonWorkingDays
            .map((dateStr) => DateTime.parse(dateStr.toString()))
            .toList();

        state = state.copyWith(
          isLoading: false,
          availableSlots: formattedSlots,
          nonWorkingDays: parsedNonWorkingDays,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          availableSlots: [],
          errorMessage: 'No available slots found',
        );
      }
    } catch (e) {
      debugPrint("Error in fetchAvailableSlots: ${e.toString()}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch available slots',
      );
    }
  }

  // Refresh available slots
  Future<void> refreshAvailableSlots(
    BuildContext context,
    String doctorCIN,
    DateTime date,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final formattedDate = _formatDate(date);
      final success = await _repository.refreshAvailableSlots(
        context,
        doctorCIN,
        formattedDate,
      );

      if (success) {
        // After successful refresh, fetch the updated data
        await fetchAvailableSlots(context, doctorCIN, date);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to refresh available slots',
        );
      }
    } catch (e) {
      debugPrint("Error in refreshAvailableSlots: ${e.toString()}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error refreshing available slots',
      );
    }
  }

  // Helper method to format date for API
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Check if a date is a non-working day
  bool isNonWorkingDay(DateTime date) {
    return state.nonWorkingDays.any((nonWorkingDate) =>
        nonWorkingDate.year == date.year &&
        nonWorkingDate.month == date.month &&
        nonWorkingDate.day == date.day);
  }
}

// Create the provider
final availableSlotsProvider =
    StateNotifierProvider<AvailableSlotsNotifier, AvailableSlotsState>((ref) {
  return AvailableSlotsNotifier(GetPatientRepository());
});
