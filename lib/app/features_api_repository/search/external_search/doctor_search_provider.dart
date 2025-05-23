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

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      cin: json['cin']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ??
          json['specialization']?.toString() ??
          json['category']?.toString() ??
          '',
      location: json['location']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          'images/doctor.jpg',
      rating: (json['rating'] != null)
          ? double.tryParse(json['rating'].toString()) ?? 0.0
          : 0.0,
      about: json['about']?.toString() ?? '',
      experience: json['experience'] != null
          ? int.tryParse(json['experience'].toString()) ?? 0
          : 0,
      patients: json['patients'] != null
          ? int.tryParse(json['patients'].toString()) ?? 0
          : 0,
      reviews: json['reviews'] != null
          ? int.tryParse(json['reviews'].toString()) ?? 0
          : 0,
      fee: json['fee'] != null
          ? double.tryParse(json['fee'].toString()) ?? 0.0
          : 0.0,
    );
  }
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
}

// StateNotifier to handle doctor search operations
class DoctorSearchNotifier extends StateNotifier<DoctorSearchState> {
  DoctorSearchNotifier() : super(DoctorSearchState());

  // Method to initialize with some default doctors
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      // Load some initial doctors
      await searchDoctors('');
    } catch (e) {
      state = state.copyWith(error: 'Failed to load initial doctors: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Method to search doctors
  Future<void> searchDoctors(String query, {BuildContext? context}) async {
    state = state.copyWith(isLoading: true, searchQuery: query);

    try {
      final results = await DoctorSearchService.searchDoctors(query);
      List<Doctor> doctorList;

      if (results.isEmpty) {
        // If no results from API, use mock data for demonstration
        doctorList = _getMockDoctors();
      } else {
        doctorList =
            results.map<Doctor>((doctor) => Doctor.fromJson(doctor)).toList();
      }

      state = state.copyWith(doctors: doctorList);
      // Apply any active filters
      _applyFilters();
    } catch (e) {
      if (context != null) {
        showSnackBar(context: context, message: 'Error: $e');
      }

      // Fall back to mock data in case of error
      final mockDoctors = _getMockDoctors();
      state = state.copyWith(
        error: 'Error searching doctors: $e',
        doctors: mockDoctors,
      );
      _applyFilters();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Method to apply filters
  void _applyFilters() {
    final filteredList = state.doctors.where((doctor) {
      // Filter by specialty if selected
      if (state.selectedSpecialty.isNotEmpty &&
          !doctor.specialty
              .toLowerCase()
              .contains(state.selectedSpecialty.toLowerCase())) {
        return false;
      }

      // Filter by location if selected
      if (state.selectedLocation.isNotEmpty &&
          !doctor.location
              .toLowerCase()
              .contains(state.selectedLocation.toLowerCase())) {
        return false;
      }

      // Filter by rating if selected
      if (state.selectedRating > 0 && doctor.rating < state.selectedRating) {
        return false;
      }

      return true;
    }).toList();

    state = state.copyWith(filteredDoctors: filteredList);
  }

  // Method to set specialty filter
  void setSpecialtyFilter(String specialty) {
    state = state.copyWith(selectedSpecialty: specialty);
    _applyFilters();
  }

  // Method to set location filter
  void setLocationFilter(String location) {
    state = state.copyWith(selectedLocation: location);
    _applyFilters();
  }

  // Method to set rating filter
  void setRatingFilter(int rating) {
    state = state.copyWith(selectedRating: rating);
    _applyFilters();
  }

  // Method to clear all filters
  void clearFilters() {
    state = state.copyWith(
      selectedSpecialty: '',
      selectedLocation: '',
      selectedRating: 0,
      filteredDoctors: state.doctors,
    );
  }

  // Method to clear only location filter
  void clearLocationFilter() {
    state = state.copyWith(selectedLocation: '');
    _applyFilters();
  }

  // Method to clear only rating filter
  void clearRatingFilter() {
    state = state.copyWith(selectedRating: 0);
    _applyFilters();
  }

  // Method to clear only specialty filter
  void clearSpecialtyFilter() {
    state = state.copyWith(selectedSpecialty: '');
    _applyFilters();
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
        location: 'Mumbai, India',
        imageUrl: 'images/doctor.jpg',
        rating: 5.0,
        about: 'Specialized in heart diseases and treatments.',
        experience: 15,
        patients: 3200,
        reviews: 425,
        fee: 2500,
      ),
    ];
  }
}

// Provider for DoctorSearchState
final doctorSearchProvider =
    StateNotifierProvider<DoctorSearchNotifier, DoctorSearchState>((ref) {
  return DoctorSearchNotifier();
});

// Individual providers for easier consumption of specific pieces of state
final doctorsProvider = Provider<List<Doctor>>((ref) {
  return ref.watch(doctorSearchProvider).doctors;
});

final filteredDoctorsProvider = Provider<List<Doctor>>((ref) {
  return ref.watch(doctorSearchProvider).filteredDoctors;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(doctorSearchProvider).isLoading;
});
