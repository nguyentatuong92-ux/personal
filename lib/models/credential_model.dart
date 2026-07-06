import 'dart:convert';

class CredentialModel {
  final String id;
  final String serviceName; // Gmail, Facebook, Zalo, etc.
  final String username;
  final String password;
  final String notes;
  final DateTime createdAt;
  final int? colorValue; // Store color as an integer ARGB value

  CredentialModel({
    required this.id,
    required this.serviceName,
    required this.username,
    required this.password,
    this.notes = '',
    required this.createdAt,
    this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceName': serviceName,
      'username': username,
      'password': password,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'colorValue': colorValue,
    };
  }

  factory CredentialModel.fromMap(Map<String, dynamic> map) {
    return CredentialModel(
      id: map['id'] ?? '',
      serviceName: map['serviceName'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      colorValue: map['colorValue'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CredentialModel.fromJson(String source) =>
      CredentialModel.fromMap(json.decode(source));
}
