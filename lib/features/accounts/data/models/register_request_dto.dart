import 'dart:io';

class RegisterRequestDto {
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;
  final String displayName;
  final String bio;
  final File? avatar;
  final DateTime? birthDate; // Formato esperado pela API: "YYYY-MM-DD"

  RegisterRequestDto({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.displayName,
    required this.bio,
    this.avatar,
    this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'password_confirm': passwordConfirm,
      'display_name': displayName,
      'bio': bio,
      'avatar': avatar,
      'birth_date': birthDate,
    };
  }
}