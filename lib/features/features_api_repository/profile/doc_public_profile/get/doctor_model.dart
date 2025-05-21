import 'dart:convert';

/// A model class representing a doctor's public profile data
class DoctorProfileModel {
  final String cin;
  final String name;
  final String? specialty;
  final String? address;
  final String? phone;
  final String? email;
  final String? bio;
  // Add any other fields that might be in the doctor profile data

  DoctorProfileModel({
    required this.cin,
    required this.name,
    this.specialty,
    this.address,
    this.phone,
    this.email,
    this.bio,
  });

  /// Factory constructor to create a DoctorProfileModel from a JSON response string
  factory DoctorProfileModel.fromResponseString(String responseString) {
    final Map<String, dynamic> json = jsonDecode(responseString);
    return DoctorProfileModel.fromJson(json);
  }

  /// Factory constructor to create a DoctorProfileModel from a JSON map
  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      cin: json['cin'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
    );
  }

  /// Convert the DoctorProfileModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'cin': cin,
      'name': name,
      if (specialty != null) 'specialty': specialty,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (bio != null) 'bio': bio,
    };
  }

  @override
  String toString() {
    return 'DoctorProfileModel(cin: $cin, name: $name, specialty: $specialty)';
  }
}
