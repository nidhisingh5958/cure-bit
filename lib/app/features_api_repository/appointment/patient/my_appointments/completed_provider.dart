import 'package:CureBit/app/features_api_repository/appointment/patient/get/get_patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class for completed appointments
class CompletedAppointmentsState {
  final List<dynamic> appointments;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;

  CompletedAppointmentsState({
    this.appointments = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
  });

  CompletedAppointmentsState copyWith({
    List<dynamic>? appointments,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return CompletedAppointmentsState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Provider notifier for completed appointments
class CompletedAppointmentsNotifier
    extends StateNotifier<CompletedAppointmentsState> {
  final GetPatientRepository _repository;

  CompletedAppointmentsNotifier(this._repository)
      : super(CompletedAppointmentsState());

  // Fetch completed (previous) appointments
  Future<void> fetchCompletedAppointments(
      BuildContext context, String patientEmail) async {
    state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');

    try {
      final appointments =
          await _repository.getPreviousAppointments(context, patientEmail);
      state = state.copyWith(
        appointments: appointments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // Refresh completed appointments
  Future<void> refreshCompletedAppointments(
      BuildContext context, String patientEmail) async {
    state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');

    try {
      final success =
          await _repository.refreshPreviousAppointments(context, patientEmail);
      if (success) {
        // If refresh was successful, fetch the updated data
        await fetchCompletedAppointments(context, patientEmail);
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Failed to refresh appointments',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }
}

// Repository provider
final patientRepositoryProvider = Provider<GetPatientRepository>((ref) {
  return GetPatientRepository();
});

// State notifier provider for completed appointments
final completedAppointmentsProvider = StateNotifierProvider<
    CompletedAppointmentsNotifier, CompletedAppointmentsState>((ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return CompletedAppointmentsNotifier(repository);
});
