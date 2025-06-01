import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CureBit/app/features_api_repository/appointment/patient/get/get_patient_repository.dart';

class BusyDatesState {
  final bool isLoading;
  final List<DateTime> busyDates;
  final String? errorMessage;

  const BusyDatesState({
    this.isLoading = false,
    this.busyDates = const [],
    this.errorMessage,
  });

  BusyDatesState copyWith({
    bool? isLoading,
    List<DateTime>? busyDates,
    String? errorMessage,
  }) {
    return BusyDatesState(
      isLoading: isLoading ?? this.isLoading,
      busyDates: busyDates ?? this.busyDates,
      errorMessage: errorMessage,
    );
  }
}

class BusyDatesNotifier extends StateNotifier<BusyDatesState> {
  final GetPatientRepository _repository;

  BusyDatesNotifier(this._repository) : super(const BusyDatesState());

  // Fetch busy dates for a doctor
  Future<void> fetchBusyDates(
    BuildContext context,
    String doctorCIN,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final busyDatesStrings = await _repository.getBusyDates(
        context,
        doctorCIN,
      );

      if (busyDatesStrings.isNotEmpty) {
        // Parse string dates to DateTime objects
        final List<DateTime> parsedBusyDates = [];

        for (String dateStr in busyDatesStrings) {
          try {
            final DateTime parsedDate = DateTime.parse(dateStr);
            parsedBusyDates.add(parsedDate);
          } catch (e) {
            debugPrint("Error parsing date '$dateStr': ${e.toString()}");
            // Skip invalid date strings
          }
        }

        state = state.copyWith(
          isLoading: false,
          busyDates: parsedBusyDates,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          busyDates: [],
        );
      }
    } catch (e) {
      debugPrint("Error in fetchBusyDates: ${e.toString()}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch busy dates',
      );
    }
  }

  // Refresh busy dates
  Future<void> refreshBusyDates(
    BuildContext context,
    String doctorCIN,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.refreshBusyDates(
        context,
        doctorCIN,
      );

      if (success) {
        // After successful refresh, fetch the updated data
        await fetchBusyDates(context, doctorCIN);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to refresh busy dates',
        );
      }
    } catch (e) {
      debugPrint("Error in refreshBusyDates: ${e.toString()}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error refreshing busy dates',
      );
    }
  }

  // Check if a specific date is busy
  bool isBusyDate(DateTime date) {
    return state.busyDates.any((busyDate) =>
        busyDate.year == date.year &&
        busyDate.month == date.month &&
        busyDate.day == date.day);
  }

  // Get busy dates for a specific month
  List<DateTime> getBusyDatesForMonth(int year, int month) {
    return state.busyDates
        .where((date) => date.year == year && date.month == month)
        .toList();
  }

  // Get busy dates within a date range
  List<DateTime> getBusyDatesInRange(DateTime startDate, DateTime endDate) {
    return state.busyDates
        .where((date) =>
            date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  // Clear busy dates (useful when switching doctors)
  void clearBusyDates() {
    state = const BusyDatesState();
  }
}

// Create the provider
final busyDatesProvider =
    StateNotifierProvider<BusyDatesNotifier, BusyDatesState>((ref) {
  return BusyDatesNotifier(GetPatientRepository());
});

// Family provider for different doctors
final busyDatesProviderFamily =
    StateNotifierProvider.family<BusyDatesNotifier, BusyDatesState, String>(
        (ref, doctorCIN) {
  return BusyDatesNotifier(GetPatientRepository());
});
