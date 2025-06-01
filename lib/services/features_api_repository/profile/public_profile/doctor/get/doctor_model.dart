import 'dart:convert';

/// A model class representing a doctor's public profile data
class DoctorProfileModel {
  final String? cin;
  final String? name;
  final String? specialization;
  final String? qualification;
  final String? experience;
  final String? address;
  final String? phone;
  final String? email;
  final String? bio;
  final String? workingTime;
  final String? patientsAttended;

  DoctorProfileModel({
    this.cin,
    this.name,
    this.specialization,
    this.qualification,
    this.experience,
    this.address,
    this.phone,
    this.email,
    this.bio,
    this.workingTime,
    this.patientsAttended,
  });

  /// Factory constructor to create a DoctorProfileModel from a JSON response string
  factory DoctorProfileModel.fromResponseString(String responseString) {
    final Map<String, dynamic> json = jsonDecode(responseString);
    return DoctorProfileModel.fromJson(json);
  }

  /// Factory constructor to create a DoctorProfileModel from a JSON map
  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      cin: json['cin'] as String?,
      name: json['name'] as String?,
      specialization: json['specialty'] as String?,
      qualification: json['qualification'] as String?,
      experience: json['experience'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      workingTime: json['working_time'] as String?,
      patientsAttended: json['patients_attended'] as String?,
    );
  }

  /// Convert the DoctorProfileModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (cin != null) 'cin': cin,
      if (name != null) 'name': name,
      if (specialization != null) 'specialty': specialization,
      if (qualification != null) 'qualification': qualification,
      if (experience != null) 'experience': experience,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (bio != null) 'bio': bio,
      if (workingTime != null) 'working_time': workingTime,
      if (patientsAttended != null) 'patients_attended': patientsAttended,
    };
  }

  @override
  String toString() {
    return 'DoctorProfileModel(cin: $cin, name: $name, speciality: $specialization)';
  }
}
