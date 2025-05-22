import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/app/features_api_repository/appointment/doctor/get_doctor_repository.dart';
import 'package:CuraDocs/app/user/user_singleton.dart';
import 'package:CuraDocs/utils/providers/user_provider.dart';
import 'package:http/http.dart' as http;

// Models for appointments
class Patient {
  final String name;
  final String imagePath;
  final String consultationType;
  final String time;
  final bool isNext;
  final String id;
  final String appointmentDate;

  Patient({
    required this.name,
    required this.imagePath,
    required this.consultationType,
    required this.time,
    this.isNext = false,
    required this.id,
    required this.appointmentDate,
  });

  // Factory constructor to create Patient from API response
  factory Patient.fromAppointment(Map<String, dynamic> appointmentData) {
    // Extract appointment type and set appropriate icon
    final String consultationType = appointmentData['type'] == 'video'
        ? 'Video Consultation'
        : 'In-Clinic Consultation';

    // Format time properly
    String time = appointmentData['time'] ?? '00:00';

    // Handle date formatting
    String appointmentDate = appointmentData['date'] ?? '2023-01-01';

    return Patient(
      id: appointmentData['id']?.toString() ?? '',
      name: appointmentData['patient_name'] ?? 'Unknown Patient',
      imagePath: appointmentData['patient_image'] ?? '',
      consultationType: consultationType,
      time: time,
      appointmentDate: appointmentDate,
      isNext: false, // Will be set by the schedule logic
    );
  }
}

// State class for appointments
class AppointmentState {
  final List<Patient> currentAppointments;
  final List<Patient> previousAppointments;
  final bool isLoadingCurrent;
  final bool isLoadingPrevious;
  final String? errorMessage;
  final DateTime selectedDate;
  final bool isRefreshing;

  AppointmentState({
    this.currentAppointments = const [],
    this.previousAppointments = const [],
    this.isLoadingCurrent = false,
    this.isLoadingPrevious = false,
    this.errorMessage,
    DateTime? selectedDate,
    this.isRefreshing = false,
  }) : selectedDate = selectedDate ?? DateTime.now();

  // Create a copy with updated fields
  AppointmentState copyWith({
    List<Patient>? currentAppointments,
    List<Patient>? previousAppointments,
    bool? isLoadingCurrent,
    bool? isLoadingPrevious,
    String? errorMessage,
    DateTime? selectedDate,
    bool clearError = false,
    bool? isRefreshing,
  }) {
    return AppointmentState(
      currentAppointments: currentAppointments ?? this.currentAppointments,
      previousAppointments: previousAppointments ?? this.previousAppointments,
      isLoadingCurrent: isLoadingCurrent ?? this.isLoadingCurrent,
      isLoadingPrevious: isLoadingPrevious ?? this.isLoadingPrevious,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedDate: selectedDate ?? this.selectedDate,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

// Provider for the doctor's CIN (identifier)
final doctorCINProvider = Provider<String>((ref) {
  // First try to get from provider
  final userFromProvider = ref.watch(userProvider);
  if (userFromProvider != null && userFromProvider.cin.isNotEmpty) {
    return userFromProvider.cin;
  }

  // Fall back to singleton if provider is not available
  return UserSingleton().user.cin;
});

// Notifier class to manage appointment state
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final DoctorGetAppointmentRepository _repository;
  final Ref _ref;

  AppointmentNotifier(this._ref, this._repository) : super(AppointmentState()) {
    // Initial load can be triggered here if needed
  }

  // Get the doctor's CIN
  String get _doctorCIN => _ref.read(doctorCINProvider);

  // Handle API errors and return appropriate error messages
  String handleApiError(http.Response response) {
    return _repository.handleApiError(response);
  }

  // Load current appointments
  Future<void> loadCurrentAppointments() async {
    // Set loading state
    state = state.copyWith(isLoadingCurrent: true, clearError: true);

    try {
      final appointments = await _repository.getDoctorAppointments(_doctorCIN);

      if (appointments.isNotEmpty) {
        // Convert appointments to Patient objects
        final List<Patient> patientList = appointments
            .map((appointment) => Patient.fromAppointment(appointment))
            .toList();

        // Sort appointments by time
        patientList.sort((a, b) {
          // First compare dates
          final dateComparison = a.appointmentDate.compareTo(b.appointmentDate);
          if (dateComparison != 0) return dateComparison;

          // If same date, compare times
          return a.time.compareTo(b.time);
        });

        // Mark the next upcoming appointment
        if (patientList.isNotEmpty) {
          final now = DateTime.now();

          // Find the first appointment that is after the current time
          for (int i = 0; i < patientList.length; i++) {
            final patient = patientList[i];

            // Parse appointment date and time
            final appointmentDateTime = _parseAppointmentDateTime(
                patient.appointmentDate, patient.time);

            if (appointmentDateTime.isAfter(now)) {
              // Create a new instance with isNext set to true
              patientList[i] = Patient(
                id: patient.id,
                name: patient.name,
                imagePath: patient.imagePath,
                consultationType: patient.consultationType,
                time: patient.time,
                appointmentDate: patient.appointmentDate,
                isNext: true,
              );
              break;
            }
          }
        }

        // Update state with new appointments
        state = state.copyWith(
          currentAppointments: patientList,
          isLoadingCurrent: false,
        );
      } else {
        // Empty appointments list
        state = state.copyWith(
          currentAppointments: [],
          isLoadingCurrent: false,
        );
      }
    } catch (e) {
      // Handle error
      state = state.copyWith(
        isLoadingCurrent: false,
        errorMessage: 'Error loading appointments: ${e.toString()}',
      );
    }
  }

  // Load previous appointments
  Future<void> loadPreviousAppointments(BuildContext context,
      {bool refresh = false}) async {
    // Set loading state
    state = state.copyWith(isLoadingPrevious: true, clearError: true);

    try {
      // If refresh is requested, call the refresh method first
      if (refresh) {
        await _repository.refreshPreviousAppointments(
          context,
          _doctorCIN,
        );
      }

      final previousAppointments =
          await _repository.getDoctorPreviousAppointments(_doctorCIN);

      if (previousAppointments.isNotEmpty) {
        // Convert appointments to Patient objects
        final List<Patient> patientList = previousAppointments
            .map((appointment) => Patient.fromAppointment(appointment))
            .toList();

        // Sort by date and time (most recent first for previous appointments)
        patientList.sort((a, b) {
          final dateComparisonDesc =
              b.appointmentDate.compareTo(a.appointmentDate);
          if (dateComparisonDesc != 0) return dateComparisonDesc;
          return b.time.compareTo(a.time);
        });

        // Update state with new previous appointments
        state = state.copyWith(
          previousAppointments: patientList,
          isLoadingPrevious: false,
        );
      } else {
        // Empty previous appointments list
        state = state.copyWith(
          previousAppointments: [],
          isLoadingPrevious: false,
        );
      }
    } catch (e) {
      // Handle error
      state = state.copyWith(
        isLoadingPrevious: false,
        errorMessage: 'Error loading previous appointments: ${e.toString()}',
      );
    }
  }

  // Refresh appointments
  Future<void> refreshAppointments(BuildContext context) async {
    // Show loading and refreshing indicators
    state = state.copyWith(
        isLoadingCurrent: true, isRefreshing: true, clearError: true);

    try {
      // Delete cached appointments
      final refreshSuccess =
          await _repository.deleteCachedAppointments(context, _doctorCIN);

      if (!refreshSuccess) {
        state = state.copyWith(
          isLoadingCurrent: false,
          isRefreshing: false,
          errorMessage: 'Failed to refresh appointments. Please try again.',
        );
        return;
      }

      // Reload current appointments
      await loadCurrentAppointments();

      // Update refreshing state when done
      state = state.copyWith(isRefreshing: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingCurrent: false,
        isRefreshing: false,
        errorMessage: 'Error refreshing appointments: ${e.toString()}',
      );
    }
  }

  // Refresh previous appointments
  Future<void> refreshPreviousAppointments(BuildContext context) async {
    state = state.copyWith(
        isLoadingPrevious: true, isRefreshing: true, clearError: true);

    try {
      final refreshed =
          await _repository.refreshPreviousAppointments(context, _doctorCIN);

      if (!refreshed) {
        state = state.copyWith(
          isLoadingPrevious: false,
          isRefreshing: false,
          errorMessage:
              'Failed to refresh previous appointments. Please try again.',
        );
        return;
      }

      await loadPreviousAppointments(context, refresh: true);

      // Update refreshing state when done
      state = state.copyWith(isRefreshing: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingPrevious: false,
        isRefreshing: false,
        errorMessage: 'Error refreshing previous appointments: ${e.toString()}',
      );
    }
  }

  // Update selected date for viewing appointments
  void updateSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    // You might want to reload appointments for this date
    loadCurrentAppointments();
  }

  // Helper method to parse appointment date time string to DateTime object
  DateTime _parseAppointmentDateTime(String date, String time) {
    try {
      final parts = date.split('-');
      final timeParts = time.split(':');

      // Ensure we have valid parts
      if (parts.length == 3 && timeParts.length >= 2) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      }
    } catch (e) {
      debugPrint('Error parsing date time: $e');
    }

    // Return current time if parsing fails
    return DateTime.now();
  }
}

// Provider for the repository
final appointmentRepositoryProvider =
    Provider<DoctorGetAppointmentRepository>((ref) {
  return DoctorGetAppointmentRepository();
});

// Provider for appointment state
final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return AppointmentNotifier(ref, repository);
});

// Derived providers for convenience

// Current appointments provider
final currentAppointmentsProvider = Provider<List<Patient>>((ref) {
  final appointmentState = ref.watch(appointmentProvider);
  return appointmentState.currentAppointments;
});

// Previous appointments provider
final previousAppointmentsProvider = Provider<List<Patient>>((ref) {
  final appointmentState = ref.watch(appointmentProvider);
  return appointmentState.previousAppointments;
});

// Next appointment provider
final nextAppointmentProvider = Provider<Patient?>((ref) {
  final currentAppointments = ref.watch(currentAppointmentsProvider);
  try {
    return currentAppointments.firstWhere(
      (patient) => patient.isNext,
    );
  } catch (e) {
    return Patient(
      id: '',
      name: '',
      imagePath: '',
      consultationType: '',
      time: '',
      appointmentDate: '',
    );
  }
});

// Selected date provider
final selectedDateProvider = Provider<DateTime>((ref) {
  final appointmentState = ref.watch(appointmentProvider);
  return appointmentState.selectedDate;
});

// Loading state providers
final isLoadingCurrentAppointmentsProvider = Provider<bool>((ref) {
  final appointmentState = ref.watch(appointmentProvider);
  return appointmentState.isLoadingCurrent;
});

final isLoadingPreviousAppointmentsProvider = Provider<bool>((ref) {
  final appointmentState = ref.watch(appointmentProvider);
  return appointmentState.isLoadingPrevious;
});

// Add an additional provider for the refreshing state
final isRefreshingAppointmentsProvider = Provider<bool>((ref) {
  final appointmentState = ref.watch(appointmentProvider);
  return appointmentState.isRefreshing;
});

// Error message provider
final appointmentErrorProvider = Provider<String?>((ref) {
  final appointmentState = ref.watch(appointmentProvider);
  return appointmentState.errorMessage;
});
