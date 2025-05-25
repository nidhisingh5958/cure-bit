import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/app/features_api_repository/search/external_search/doctor_search_repository.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';

final class Doctor {
  final String cin;
  final String name;
  final String specialty;
  final String location;
  final String imageUrl;
  final double rating;
  final String about;
  final int experience;
  final int patients;
  final int reviews;
  final double fee;

  Doctor({
    required this.cin,
    required this.name,
    required this.specialty,
    required this.location,
    required this.imageUrl,
    required this.rating,
    this.about = '',
    this.experience = 0,
    this.patients = 0,
    this.reviews = 0,
    this.fee = 0.0,
  });

  factory Doctor.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Doctor(
        cin: '',
        name: 'Unknown Doctor',
        specialty: 'General',
        location: 'Location not specified',
        imageUrl: 'images/doctor.jpg',
        rating: 0.0,
      );
    }

    return Doctor(
      cin: _safeString(json['cin']) ??
          _safeString(json['id']) ??
          _safeString(json['doctorId']) ??
          '',
      name: _safeString(json['name']) ??
          _safeString(json['doctorName']) ??
          'Unknown Doctor',
      specialty: _safeString(json['specialty']) ??
          _safeString(json['specialization']) ??
          _safeString(json['category']) ??
          'General',
      location: _safeString(json['location']) ??
          _safeString(json['address']) ??
          'Location not specified',
      imageUrl: _safeString(json['image_url']) ??
          _safeString(json['imageUrl']) ??
          _safeString(json['image']) ??
          'images/doctor.jpg',
      rating: _safeDouble(json['rating']) ?? 0.0,
      about:
          _safeString(json['about']) ?? _safeString(json['description']) ?? '',
      experience: _safeInt(json['experience']) ?? 0,
      patients:
          _safeInt(json['patients']) ?? _safeInt(json['patient_count']) ?? 0,
      reviews: _safeInt(json['reviews']) ?? _safeInt(json['review_count']) ?? 0,
      fee: _safeDouble(json['fee']) ??
          _safeDouble(json['consultation_fee']) ??
          0.0,
    );
  }

  // Helper methods for safe parsing
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    return value.toString().trim();
  }

  static double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  @override
  String toString() {
    return 'Doctor(cin: $cin, name: $name, specialty: $specialty, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.cin == cin;
  }

  @override
  int get hashCode => cin.hashCode;
}

// State class to hold all doctor search related state
class DoctorSearchState {
  final List<Doctor> doctors;
  final List<Doctor> filteredDoctors;
  final bool isLoading;
  final String searchQuery;
  final String selectedSpecialty;
  final String selectedLocation;
  final int selectedRating;
  final String error;

  DoctorSearchState({
    this.doctors = const [],
    this.filteredDoctors = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedSpecialty = '',
    this.selectedLocation = '',
    this.selectedRating = 0,
    this.error = '',
  });

  DoctorSearchState copyWith({
    List<Doctor>? doctors,
    List<Doctor>? filteredDoctors,
    bool? isLoading,
    String? searchQuery,
    String? selectedSpecialty,
    String? selectedLocation,
    int? selectedRating,
    String? error,
  }) {
    return DoctorSearchState(
      doctors: doctors ?? this.doctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSpecialty: selectedSpecialty ?? this.selectedSpecialty,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedRating: selectedRating ?? this.selectedRating,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'DoctorSearchState(doctors: ${doctors.length}, filtered: ${filteredDoctors.length}, loading: $isLoading, error: $error)';
  }
}

// StateNotifier to handle doctor search operations
class DoctorSearchNotifier extends StateNotifier<DoctorSearchState> {
  DoctorSearchNotifier() : super(DoctorSearchState());

  // Method to initialize with some default doctors
  Future<void> initialize() async {
    if (!mounted) return;

    try {
      state = state.copyWith(isLoading: true, error: '');

      // Load some initial doctors or mock data
      final mockDoctors = _getMockDoctors();

      if (mounted) {
        state = state.copyWith(
          doctors: mockDoctors,
          filteredDoctors: mockDoctors,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Error in initialize: $e');
      if (mounted) {
        state = state.copyWith(
          error: 'Failed to load initial doctors: $e',
          isLoading: false,
          doctors: _getMockDoctors(),
        );
        _applyFilters();
      }
    }
  }

  // Method to search doctors
  Future<void> searchDoctors(String query, {BuildContext? context}) async {
    if (!mounted) return;

    try {
      state = state.copyWith(isLoading: true, searchQuery: query, error: '');

      List<Map<String, dynamic>>? results;

      try {
        results = await DoctorSearchService.searchDoctors(query);
      } catch (apiError) {
        debugPrint('API Error: $apiError');
        // Continue with empty results, will use mock data
        results = null;
      }

      List<Doctor> doctorList;

      if (results == null || results.isEmpty) {
        // If no results from API, use mock data for demonstration
        doctorList = _getMockDoctors();
      } else {
        doctorList = results
            .where((doctor) => doctor != null)
            .map<Doctor?>((doctor) {
              try {
                return Doctor.fromJson(doctor);
              } catch (e) {
                debugPrint('Error parsing doctor: $e');
                return null;
              }
            })
            .where((doctor) => doctor != null)
            .cast<Doctor>()
            .toList();

        // If parsing failed, fallback to mock data
        if (doctorList.isEmpty) {
          doctorList = _getMockDoctors();
        }
      }

      if (mounted) {
        state = state.copyWith(doctors: doctorList, isLoading: false);
        // Apply any active filters
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error in searchDoctors: $e');

      if (context != null && context.mounted) {
        try {
          showSnackBar(context: context, message: 'Error: $e');
        } catch (snackError) {
          debugPrint('Error showing snackbar: $snackError');
        }
      }

      // Fall back to mock data in case of error
      final mockDoctors = _getMockDoctors();
      if (mounted) {
        state = state.copyWith(
          error: 'Error searching doctors: $e',
          doctors: mockDoctors,
          isLoading: false,
        );
        _applyFilters();
      }
    }
  }

  // Method to apply filters
  void _applyFilters() {
    if (!mounted) return;

    try {
      if (state.doctors.isEmpty) {
        state = state.copyWith(filteredDoctors: []);
        return;
      }

      final filteredList = state.doctors.where((doctor) {
        // Additional null check for safety
        if (doctor == null) return false;

        // Filter by specialty if selected
        if (state.selectedSpecialty.isNotEmpty) {
          final doctorSpecialty = doctor.specialty;
          if (!doctorSpecialty
              .toLowerCase()
              .contains(state.selectedSpecialty.toLowerCase())) {
            return false;
          }
        }

        // Filter by location if selected
        if (state.selectedLocation.isNotEmpty) {
          final doctorLocation = doctor.location;
          if (!doctorLocation
              .toLowerCase()
              .contains(state.selectedLocation.toLowerCase())) {
            return false;
          }
        }

        // Filter by rating if selected
        if (state.selectedRating > 0) {
          final doctorRating = doctor.rating;
          if (doctorRating < state.selectedRating) {
            return false;
          }
        }

        return true;
      }).toList();

      if (mounted) {
        state = state.copyWith(filteredDoctors: filteredList);
      }
    } catch (e) {
      debugPrint('Error applying filters: $e');
      if (mounted) {
        state = state.copyWith(filteredDoctors: state.doctors);
      }
    }
  }

  // Method to set specialty filter
  void setSpecialtyFilter(String specialty) {
    if (!mounted) return;
    try {
      state = state.copyWith(selectedSpecialty: specialty);
      _applyFilters();
    } catch (e) {
      debugPrint('Error setting specialty filter: $e');
    }
  }

  // Method to set location filter
  void setLocationFilter(String location) {
    if (!mounted) return;
    try {
      state = state.copyWith(selectedLocation: location);
      _applyFilters();
    } catch (e) {
      debugPrint('Error setting location filter: $e');
    }
  }

  // Method to set rating filter
  void setRatingFilter(int rating) {
    if (!mounted) return;
    try {
      state = state.copyWith(selectedRating: rating);
      _applyFilters();
    } catch (e) {
      debugPrint('Error setting rating filter: $e');
    }
  }

  // Method to clear all filters
  void clearFilters() {
    if (!mounted) return;
    try {
      state = state.copyWith(
        selectedSpecialty: '',
        selectedLocation: '',
        selectedRating: 0,
        filteredDoctors: state.doctors,
      );
    } catch (e) {
      debugPrint('Error clearing filters: $e');
    }
  }

  // Method to clear only location filter
  void clearLocationFilter() {
    if (!mounted) return;
    try {
      state = state.copyWith(selectedLocation: '');
      _applyFilters();
    } catch (e) {
      debugPrint('Error clearing location filter: $e');
    }
  }

  // Method to clear only rating filter
  void clearRatingFilter() {
    if (!mounted) return;
    try {
      state = state.copyWith(selectedRating: 0);
      _applyFilters();
    } catch (e) {
      debugPrint('Error clearing rating filter: $e');
    }
  }

  // Method to clear only specialty filter
  void clearSpecialtyFilter() {
    if (!mounted) return;
    try {
      state = state.copyWith(selectedSpecialty: '');
      _applyFilters();
    } catch (e) {
      debugPrint('Error clearing specialty filter: $e');
    }
  }

  // Mock data for offline testing or when API fails
  List<Doctor> _getMockDoctors() {
    return [
      Doctor(
        cin: '1AS47',
        name: 'Dr. John Doe',
        specialty: 'Dentist',
        location: 'Delhi, India',
        imageUrl: 'images/doctor.jpg',
        rating: 4.9,
        about: 'Experienced dentist with over 10 years of practice.',
        experience: 10,
        patients: 2500,
        reviews: 387,
        fee: 1500,
      ),
      Doctor(
        cin: '2AFG#%',
        name: 'Dr. Jane Smith',
        specialty: 'Cardiologist',
        location: 'Mumbai,, India',
        imageUrl: 'images/doctor.jpg',
        rating: 4.7,
        about: 'Specialized in child healthcare.',
        experience: 12,
        patients: 2100,
        reviews: 340,
        fee: 1800,
      ),
    ];
  }
}

// Provider
final doctorSearchProvider =
    StateNotifierProvider<DoctorSearchNotifier, DoctorSearchState>(
  (ref) => DoctorSearchNotifier(),
);
