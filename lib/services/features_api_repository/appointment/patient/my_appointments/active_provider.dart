import 'package:CureBit/services/features_api_repository/appointment/patient/get/get_patient_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class AppointmentState {
  final List<dynamic> appointments;
  final bool isLoading;
  final String? errorMessage;

  AppointmentState({
    required this.appointments,
    required this.isLoading,
    this.errorMessage,
  });

  // Copy with method to create a new instance with updated values
  AppointmentState copyWith({
    List<dynamic>? appointments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Initial state with empty appointments and loading false
  factory AppointmentState.initial() {
    return AppointmentState(
      appointments: [],
      isLoading: false,
    );
  }
}

// Appointment notifier class to handle business logic
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final GetPatientRepository _repository;

  AppointmentNotifier(this._repository) : super(AppointmentState.initial());

  // Fetch active appointments for a patient
  Future<void> fetchPatientAppointments(
      BuildContext context, String patientEmail) async {
    // Set loading state to true
    state = state.copyWith(isLoading: true);

    try {
      // Fetch appointments from repository
      final appointments =
          await _repository.getPatientAppointments(context, patientEmail);

      // Filter to include only upcoming/active appointments
      // Note: You may need to adjust this logic based on how your API distinguishes active appointments
      final activeAppointments = appointments.where((appointment) {
        // Check if the appointment date is in the future or today
        // This logic may need to be adjusted based on your appointment data structure
        final appointmentDate = DateTime.parse(
            appointment['appointmentDate'] ?? DateTime.now().toIso8601String());
        final now = DateTime.now();

        return appointmentDate.isAfter(now) ||
            (appointmentDate.day == now.day &&
                appointmentDate.month == now.month &&
                appointmentDate.year == now.year);
      }).toList();

      // Update state with fetched appointments
      state = state.copyWith(
        appointments: activeAppointments,
        isLoading: false,
      );
    } catch (e) {
      // Handle error
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch appointments: ${e.toString()}',
      );
    }
  }

  // Refresh patient appointments
  Future<void> refreshPatientAppointments(
      BuildContext context, String patientEmail) async {
    // Set loading state to true
    state = state.copyWith(isLoading: true);

    try {
      // Call refresh method from repository
      final success =
          await _repository.refreshPatientAppointments(context, patientEmail);

      if (success) {
        // If refresh was successful, fetch new appointments
        await fetchPatientAppointments(context, patientEmail);
      } else {
        // If refresh failed, update error message
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to refresh appointments',
        );
      }
    } catch (e) {
      // Handle error
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error refreshing appointments: ${e.toString()}',
      );
    }
  }
}

// Create providers
final patientRepositoryProvider = Provider<GetPatientRepository>((ref) {
  return GetPatientRepository();
});

final appointmentStateProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return AppointmentNotifier(repository);
});

// Create a provider for the current patient email
final currentPatientEmailProvider = StateProvider<String?>((ref) => null);
