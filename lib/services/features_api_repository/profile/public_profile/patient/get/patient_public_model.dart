class PatientPublicProfileModel {
  final String cin;
  final String username;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String dateOfBirth;
  final int age;
  final String joinedDate;
  final String profileImageUrl;

  PatientPublicProfileModel({
    required this.cin,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.dateOfBirth,
    required this.age,
    required this.joinedDate,
    required this.profileImageUrl,
  });

  factory PatientPublicProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientPublicProfileModel(
      cin: json['cin'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      age: json['age'] ?? 0,
      joinedDate: json['joinedDate'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cin': cin,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'joinedDate': joinedDate,
      'profileImageUrl': profileImageUrl,
    };
  }

  PatientPublicProfileModel copyWith({
    String? cin,
    String? username,
    String? name,
    String? email,
    String? phone,
    String? location,
    String? dateOfBirth,
    int? age,
    String? joinedDate,
    String? profileImageUrl,
  }) {
    return PatientPublicProfileModel(
      cin: cin ?? this.cin,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      joinedDate: joinedDate ?? this.joinedDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
