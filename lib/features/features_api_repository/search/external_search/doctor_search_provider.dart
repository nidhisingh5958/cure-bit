import 'dart:async';
import 'package:CuraDocs/features/features_api_repository/search/external_search/doctor_search_repository.dart';
import 'package:flutter/material.dart';

class Doctor {
  final String id;
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
    required this.id,
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? json['category'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? 'images/doctor.jpg',
      rating: (json['rating'] != null)
          ? double.tryParse(json['rating'].toString()) ?? 0.0
          : 0.0,
      about: json['about'] ?? '',
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

class DoctorSearchProvider extends ChangeNotifier {
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedSpecialty = '';
  String _selectedLocation = '';
  int _selectedRating = 0;
  String _error = '';

  // Getters
  List<Doctor> get doctors => _doctors;
  List<Doctor> get filteredDoctors => _filteredDoctors;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedSpecialty => _selectedSpecialty;
  String get selectedLocation => _selectedLocation;
  int get selectedRating => _selectedRating;
  String get error => _error;

  // Method to initialize with some default doctors
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load some initial doctors
      await searchDoctors('');
    } catch (e) {
      _error = 'Failed to load initial doctors: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to search doctors
  Future<void> searchDoctors(String query) async {
    _isLoading = true;
    _searchQuery = query;
    notifyListeners();

    try {
      final results = await DoctorSearchService.searchDoctors(query);

      if (results.isEmpty) {
        // If no results from API, use mock data for demonstration
        _doctors = _getMockDoctors();
      } else {
        _doctors = results.map((doctor) => Doctor.fromJson(doctor)).toList();
      }

      // Apply any active filters
      _applyFilters();
    } catch (e) {
      _error = 'Error searching doctors: $e';
      // Fall back to mock data in case of error
      _doctors = _getMockDoctors();
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to apply filters
  void _applyFilters() {
    _filteredDoctors = _doctors.where((doctor) {
      // Filter by specialty if selected
      if (_selectedSpecialty.isNotEmpty &&
          !doctor.specialty
              .toLowerCase()
              .contains(_selectedSpecialty.toLowerCase())) {
        return false;
      }

      // Filter by location if selected
      if (_selectedLocation.isNotEmpty &&
          !doctor.location
              .toLowerCase()
              .contains(_selectedLocation.toLowerCase())) {
        return false;
      }

      // Filter by rating if selected
      if (_selectedRating > 0 && doctor.rating < _selectedRating) {
        return false;
      }

      return true;
    }).toList();
  }

  // Method to set specialty filter
  void setSpecialtyFilter(String specialty) {
    _selectedSpecialty = specialty;
    _applyFilters();
    notifyListeners();
  }

  // Method to set location filter
  void setLocationFilter(String location) {
    _selectedLocation = location;
    _applyFilters();
    notifyListeners();
  }

  // Method to set rating filter
  void setRatingFilter(int rating) {
    _selectedRating = rating;
    _applyFilters();
    notifyListeners();
  }

  // Method to clear all filters
  void clearFilters() {
    _selectedSpecialty = '';
    _selectedLocation = '';
    _selectedRating = 0;
    _filteredDoctors = List.from(_doctors);
    notifyListeners();
  }

  // Method to clear only location filter
  void clearLocationFilter() {
    _selectedLocation = '';
    _applyFilters();
    notifyListeners();
  }

  // Method to clear only rating filter
  void clearRatingFilter() {
    _selectedRating = 0;
    _applyFilters();
    notifyListeners();
  }

  // Method to clear only specialty filter
  void clearSpecialtyFilter() {
    _selectedSpecialty = '';
    _applyFilters();
    notifyListeners();
  }

  // Mock data for offline testing or when API fails
  List<Doctor> _getMockDoctors() {
    return [
      Doctor(
        id: '1',
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
        id: '2',
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
      Doctor(
        id: '3',
        name: 'Dr. Ravi Sharma',
        specialty: 'Ophthalmologist',
        location: 'Bangalore, India',
        imageUrl: 'images/doctor.jpg',
        rating: 4.8,
        about: 'Expert in eye care and surgery.',
        experience: 8,
        patients: 1800,
        reviews: 290,
        fee: 1800,
      ),
      Doctor(
        id: '4',
        name: 'Dr. Priya Patel',
        specialty: 'Neurologist',
        location: 'Hyderabad, India',
        imageUrl: 'images/doctor.jpg',
        rating: 4.7,
        about: 'Specialized in neurological disorders and treatments.',
        experience: 12,
        patients: 2100,
        reviews: 310,
        fee: 2200,
      ),
      Doctor(
        id: '5',
        name: 'Dr. Rajesh Kumar',
        specialty: 'ENT',
        location: 'Chennai, India',
        imageUrl: 'images/doctor.jpg',
        rating: 4.6,
        about: 'Expert in ear, nose, and throat conditions.',
        experience: 9,
        patients: 1950,
        reviews: 278,
        fee: 1700,
      ),
    ];
  }
}
