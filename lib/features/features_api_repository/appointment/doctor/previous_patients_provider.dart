import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:CuraDocs/utils/user/user_singleton.dart';
import 'package:CuraDocs/utils/providers/user_provider.dart';

// Patient model
class PatientData {
  final String id;
  final String name;
  final String image;
  final String symptoms;
  final String age;
  final String gender;
  final String lastVisit;
  final bool isFavorite;

  PatientData({
    required this.id,
    required this.name,
    required this.image,
    required this.symptoms,
    required this.age,
    required this.gender,
    required this.lastVisit,
    this.isFavorite = false,
  });

  // Factory constructor for creating from API response
  factory PatientData.fromJson(Map<String, dynamic> json) {
    return PatientData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      image: json['image'] ?? 'images/doctor.jpg',
      symptoms: json['symptoms'] ?? 'No symptoms',
      age: json['age']?.toString() ?? 'Unknown',
      gender: json['gender'] ?? 'Unknown',
      lastVisit: json['lastVisit'] ?? 'Never',
      isFavorite: json['isFavorite'] == true,
    );
  }
}

// State class for previous patients
class PreviousPatientsState {
  final List<PatientData> patients;
  final bool isLoading;
  final String errorMessage;
  final bool hasMoreData;
  final int currentPage;
  final bool isRefreshing;

  PreviousPatientsState({
    this.patients = const [],
    this.isLoading = false,
    this.errorMessage = '',
    this.hasMoreData = true,
    this.currentPage = 1,
    this.isRefreshing = false,
  });

  // Create a copy with updated fields
  PreviousPatientsState copyWith({
    List<PatientData>? patients,
    bool? isLoading,
    String? errorMessage,
    bool? hasMoreData,
    int? currentPage,
    bool? isRefreshing,
    bool clearError = false,
  }) {
    return PreviousPatientsState(
      patients: patients ?? this.patients,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
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

// Repository for fetching previous patients data
class DoctorPreviousPatientsRepository {
  final String baseUrl = 'https://api.curadocs.com/api/v1';

  // Fetch previous patients with pagination
  Future<Map<String, dynamic>> getPreviousPatients(
    String doctorCIN, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Mock implementation for development
      // In production, this would be an actual API call
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      // This is a mock response - replace with actual API integration
      final mockPatients = List.generate(
        page == 1 ? 10 : (page == 2 ? 10 : 5), // Total 25 mock patients
        (index) {
          final actualIndex = (page - 1) * limit + index;
          return {
            'id': 'PATIENT${100 + actualIndex}',
            'name': 'Patient ${actualIndex + 1}',
            'image': 'images/doctor.jpg',
            'symptoms': actualIndex % 3 == 0
                ? 'Fever'
                : (actualIndex % 3 == 1 ? 'Headache' : 'Cold'),
            'age': '${20 + (actualIndex % 60)}',
            'gender': actualIndex % 2 == 0 ? 'Male' : 'Female',
            'lastVisit': actualIndex % 4 == 0
                ? 'Today'
                : (actualIndex % 4 == 1
                    ? 'Yesterday'
                    : (actualIndex % 4 == 2 ? '2 days ago' : '1 week ago')),
            'isFavorite': actualIndex % 5 == 0,
          };
        },
      );

      return {
        'success': true,
        'data': mockPatients,
        'hasMore': page < 3, // Mock only has 3 pages
      };

      // Actual API implementation would look like:
      /*
      final response = await http.get(
        Uri.parse('$baseUrl/doctors/$doctorCIN/patients?page=$page&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        return {
          'success': false,
          'message': 'Failed to load patients: ${response.statusCode}',
        };
      }
      */
    } catch (e) {
      return {
        'success': false,
        'message': 'Error loading patients: ${e.toString()}',
      };
    }
  }

  // Refresh cached patient data
  Future<bool> refreshPatientCache(String doctorCIN) async {
    try {
      // Mock implementation
      await Future.delayed(Duration(seconds: 1));
      return true;

      // Actual implementation would be:
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/doctors/$doctorCIN/patients/refresh'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
      */
    } catch (e) {
      debugPrint('Error refreshing patient cache: $e');
      return false;
    }
  }
}

// Notifier class to manage previous patients state
class PreviousPatientsNotifier extends StateNotifier<PreviousPatientsState> {
  final DoctorPreviousPatientsRepository _repository;
  final String doctorCIN;

  PreviousPatientsNotifier(this._repository, this.doctorCIN)
      : super(PreviousPatientsState());

  // Load initial patients (first page)
  Future<void> loadPatients() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getPreviousPatients(
        doctorCIN,
        page: 1,
        limit: 10,
      );

      if (result['success'] == true) {
        final List<PatientData> patients = (result['data'] as List)
            .map((item) => PatientData.fromJson(item as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          patients: patients,
          isLoading: false,
          hasMoreData: result['hasMore'] ?? false,
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] ?? 'Failed to load patients',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading patients: ${e.toString()}',
      );
    }
  }

  // Load more patients (next page)
  Future<void> loadMorePatients() async {
    if (state.isLoading || !state.hasMoreData) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getPreviousPatients(
        doctorCIN,
        page: nextPage,
        limit: 10,
      );

      if (result['success'] == true) {
        final List<PatientData> newPatients = (result['data'] as List)
            .map((item) => PatientData.fromJson(item as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          patients: [...state.patients, ...newPatients],
          isLoading: false,
          hasMoreData: result['hasMore'] ?? false,
          currentPage: nextPage,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] ?? 'Failed to load more patients',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading more patients: ${e.toString()}',
      );
    }
  }

  // Refresh patients data
  Future<void> refreshPatients() async {
    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final refreshSuccess = await _repository.refreshPatientCache(doctorCIN);

      if (refreshSuccess) {
        // Reset pagination and load first page
        state = state.copyWith(
          currentPage: 1,
          hasMoreData: true,
        );

        final result = await _repository.getPreviousPatients(
          doctorCIN,
          page: 1,
          limit: 10,
        );

        if (result['success'] == true) {
          final List<PatientData> patients = (result['data'] as List)
              .map((item) => PatientData.fromJson(item as Map<String, dynamic>))
              .toList();

          state = state.copyWith(
            patients: patients,
            isRefreshing: false,
            hasMoreData: result['hasMore'] ?? false,
          );
        } else {
          state = state.copyWith(
            isRefreshing: false,
            errorMessage: result['message'] ?? 'Failed to refresh patients',
          );
        }
      } else {
        state = state.copyWith(
          isRefreshing: false,
          errorMessage: 'Failed to refresh patient cache',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Error refreshing patients: ${e.toString()}',
      );
    }
  }

  // Toggle favorite status for a patient
  void toggleFavorite(String patientId) {
    final updatedPatients = state.patients.map((patient) {
      if (patient.id == patientId) {
        return PatientData(
          id: patient.id,
          name: patient.name,
          image: patient.image,
          symptoms: patient.symptoms,
          age: patient.age,
          gender: patient.gender,
          lastVisit: patient.lastVisit,
          isFavorite: !patient.isFavorite,
        );
      }
      return patient;
    }).toList();

    state = state.copyWith(patients: updatedPatients);

    // In a real app, you would make an API call to update the favorite status on the server
  }
}

// Provider for the repository
final previousPatientsRepositoryProvider =
    Provider<DoctorPreviousPatientsRepository>((ref) {
  return DoctorPreviousPatientsRepository();
});

// Provider for previous patients state
final previousPatientsProvider = StateNotifierProvider.family<
    PreviousPatientsNotifier, PreviousPatientsState, String>(
  (ref, doctorCIN) {
    final repository = ref.watch(previousPatientsRepositoryProvider);
    return PreviousPatientsNotifier(repository, doctorCIN);
  },
);

// Convenience providers

// Loading state provider
final isLoadingPreviousPatientsProvider =
    Provider.family<bool, String>((ref, doctorCIN) {
  return ref.watch(previousPatientsProvider(doctorCIN)).isLoading;
});

// Error message provider
final previousPatientsErrorProvider =
    Provider.family<String, String>((ref, doctorCIN) {
  return ref.watch(previousPatientsProvider(doctorCIN)).errorMessage;
});

// Has more data provider
final hasMorePatientsProvider = Provider.family<bool, String>((ref, doctorCIN) {
  return ref.watch(previousPatientsProvider(doctorCIN)).hasMoreData;
});

// Is refreshing provider
final isRefreshingPatientsProvider =
    Provider.family<bool, String>((ref, doctorCIN) {
  return ref.watch(previousPatientsProvider(doctorCIN)).isRefreshing;
});
