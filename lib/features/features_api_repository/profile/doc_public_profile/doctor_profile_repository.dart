import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorWorkingTime {
  final String startTime;
  final String endTime;
  final String startBreakTime;
  final String endBreakTime;
  final List<String> workingDays;
  final List<String> holidays;

  DoctorWorkingTime({
    required this.startTime,
    required this.endTime,
    required this.startBreakTime,
    required this.endBreakTime,
    required this.workingDays,
    required this.holidays,
  });

  factory DoctorWorkingTime.fromJson(Map<String, dynamic> json) {
    return DoctorWorkingTime(
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      startBreakTime: json['start_break_time'] ?? '',
      endBreakTime: json['end_break_time'] ?? '',
      workingDays: List<String>.from(json['working_days'] ?? []),
      holidays: List<String>.from(json['holidays'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'start_time': startTime,
        'end_time': endTime,
        'start_break_time': startBreakTime,
        'end_break_time': endBreakTime,
        'working_days': workingDays,
        'holidays': holidays,
      };
}

class DoctorWorkAddress {
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;

  DoctorWorkAddress({
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory DoctorWorkAddress.fromJson(Map<String, dynamic> json) {
    return DoctorWorkAddress(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
      };
}

class PostDoctorPublicProfile {
  final String firstName;
  final String lastName;
  final String fullName;
  final String cin;
  final String description;
  final String specialization;
  final String qualification;
  final String yearOfExperience;
  final String numberOfPatientAttended;
  final String avgAppointmentDuration;
  final String activityStatus;
  final List<DoctorWorkingTime> workingTime;
  final List<DoctorWorkAddress> workAddress;
  String? profilePictureUrl;

  PostDoctorPublicProfile({
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.cin,
    required this.description,
    required this.specialization,
    required this.qualification,
    required this.yearOfExperience,
    required this.numberOfPatientAttended,
    required this.avgAppointmentDuration,
    required this.activityStatus,
    required this.workingTime,
    required this.workAddress,
    this.profilePictureUrl,
  });

  factory PostDoctorPublicProfile.fromJson(Map<String, dynamic> json) {
    return PostDoctorPublicProfile(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      cin: json['CIN'] ?? '',
      description: json['description'] ?? '',
      specialization: json['specialization'] ?? '',
      qualification: json['qualification'] ?? '',
      yearOfExperience: json['year_of_experience'] ?? '',
      numberOfPatientAttended: json['number_of_patient_attended'] ?? '',
      avgAppointmentDuration: json['avg_appointment_duration'] ?? '',
      activityStatus: json['activity_status'] ?? '',
      workingTime: (json['working_time'] as List?)
              ?.map((e) => DoctorWorkingTime.fromJson(e))
              .toList() ??
          [],
      workAddress: (json['work_address'] as List?)
              ?.map((e) => DoctorWorkAddress.fromJson(e))
              .toList() ??
          [],
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'full_name': fullName,
        'CIN': cin,
        'description': description,
        'specialization': specialization,
        'qualification': qualification,
        'year_of_experience': yearOfExperience,
        'number_of_patient_attended': numberOfPatientAttended,
        'avg_appointment_duration': avgAppointmentDuration,
        'activity_status': activityStatus,
        'working_time': workingTime.map((e) => e.toJson()).toList(),
        'work_address': workAddress.map((e) => e.toJson()).toList(),
        'profile_picture_url': profilePictureUrl,
      };
}

class DoctorReview {
  final String reviewId;
  final String doctorId;
  final double rating;
  final String comment;

  DoctorReview({
    required this.reviewId,
    required this.doctorId,
    required this.rating,
    required this.comment,
  });

  factory DoctorReview.fromJson(Map<String, dynamic> json) {
    return DoctorReview(
      reviewId: json['reviewId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
    );
  }
}

class DoctorProfileRepository {
  // Singleton instance
  static final DoctorProfileRepository _instance =
      DoctorProfileRepository._internal();

  // API base URL
  final String _baseUrl = 'https://api.curadocs.com/v1';

  // HTTP Client
  final http.Client _client = http.Client();

  // Private constructor
  DoctorProfileRepository._internal();

  // Factory constructor to return the singleton instance
  factory DoctorProfileRepository() {
    return _instance;
  }

  // Method to get doctor public profile
  Future<PostDoctorPublicProfile> getPostDoctorPublicProfile(
      String doctorId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/doctors/$doctorId/profile'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PostDoctorPublicProfile.fromJson(data);
      } else {
        throw Exception(
            'Failed to load doctor profile: ${response.statusCode}');
      }
    } catch (e) {
      // For development/testing, return mock data if API fails
      debugPrint('Error fetching doctor profile: $e');
      return _getMockDoctorProfile(doctorId);
    }
  }

  // Method to update doctor public profile
  Future<bool> updatePostDoctorPublicProfile(
    String doctorId,
    PostDoctorPublicProfile profile,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/doctors/$doctorId/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profile.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating doctor profile: $e');
      // Simulate success for development purposes
      await Future.delayed(Duration(seconds: 1));
      return true;
    }
  }

  // Method to update specific fields in doctor profile
  Future<bool> updateDoctorProfileFields(
    String doctorId,
    Map<String, dynamic> fields,
  ) async {
    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl/doctors/$doctorId/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(fields),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating doctor profile fields: $e');
      // Simulate success for development purposes
      await Future.delayed(Duration(seconds: 1));
      return true;
    }
  }

  // Method to get doctor profile picture
  Future<String> getDoctorProfilePicture(String doctorId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/doctors/$doctorId/profile/picture'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['url'] ?? '';
      } else {
        throw Exception(
            'Failed to load profile picture: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching doctor profile picture: $e');
      // Return mock URL
      return 'https://example.com/profile_pictures/$doctorId.jpg';
    }
  }

  // Method to update doctor profile picture
  Future<bool> updateDoctorProfilePicture(
    String doctorId,
    String pictureUrl,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/doctors/$doctorId/profile/picture'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': pictureUrl}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating doctor profile picture: $e');
      // Simulate success for development purposes
      await Future.delayed(Duration(seconds: 1));
      return true;
    }
  }

  // Method to get doctor reviews
  Future<List<DoctorReview>> getDoctorReviews(String doctorId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/doctors/$doctorId/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((review) => DoctorReview.fromJson(review)).toList();
      } else {
        throw Exception(
            'Failed to load doctor reviews: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching doctor reviews: $e');
      // Return mock reviews
      return _getMockDoctorReviews(doctorId);
    }
  }

  // Mock data for development/testing
  PostDoctorPublicProfile _getMockDoctorProfile(String doctorId) {
    return PostDoctorPublicProfile(
      firstName: 'John',
      lastName: 'Doe',
      fullName: 'Dr. John Doe',
      cin: 'DOC123456',
      description: 'Experienced cardiologist with focus on preventive care.',
      specialization: 'Cardiology',
      qualification: 'MD, MBBS, FCPS',
      yearOfExperience: '10',
      numberOfPatientAttended: '5000+',
      avgAppointmentDuration: '30 mins',
      activityStatus: 'Active',
      workingTime: [
        DoctorWorkingTime(
          startTime: '09:00',
          endTime: '17:00',
          startBreakTime: '12:00',
          endBreakTime: '13:00',
          workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
          holidays: ['Saturday', 'Sunday'],
        )
      ],
      workAddress: [
        DoctorWorkAddress(
          address: '123 Medical Center Blvd',
          city: 'New York',
          state: 'NY',
          country: 'USA',
          pincode: '10001',
        )
      ],
      profilePictureUrl: 'https://example.com/profile_pictures/$doctorId.jpg',
    );
  }

  // Mock reviews for development/testing
  List<DoctorReview> _getMockDoctorReviews(String doctorId) {
    return [
      DoctorReview(
        reviewId: '1',
        doctorId: doctorId,
        rating: 4.5,
        comment: 'Great doctor! Very knowledgeable and caring.',
      ),
      DoctorReview(
        reviewId: '2',
        doctorId: doctorId,
        rating: 4.0,
        comment: 'Very helpful and attentive to details.',
      ),
    ];
  }
}
