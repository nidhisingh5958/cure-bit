import 'dart:convert';

class UserModel {
  final String cin;
  final String name;
  final String email;
  final String token;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.cin,
    required this.name,
    required this.email,
    required this.token,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? cin,
    String? name,
    String? email,
    String? token,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      cin: cin ?? this.cin,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cin': cin,
      'name': name,
      'email': email,
      'token': token,
      'role': role, // Include role in toMap
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      cin: map['cin'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      token: map['token'] as String,
      role: map['role'] as String, // Extract role from map
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(cin: $cin, name: $name, email: $email, token: $token, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.cin == cin &&
        other.name == name &&
        other.email == email &&
        other.token == token &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return cin.hashCode ^
        name.hashCode ^
        email.hashCode ^
        token.hashCode ^
        role.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
