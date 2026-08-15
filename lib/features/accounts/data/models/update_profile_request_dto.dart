import 'dart:io';

class UpdateProfileRequestDto {
  final String username;
  final String email;
  final String? displayName;
  final String? bio;
  final File? avatar;
  final DateTime? birthDate;

  UpdateProfileRequestDto({
    required this.username,
    required this.email,
    this.displayName,
    this.bio,
    this.avatar,
    this.birthDate,
  });
}