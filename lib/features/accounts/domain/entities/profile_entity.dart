class ProfileEntity {
  final int id;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final DateTime? birthDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.id,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
    this.birthDate,
    required this.createdAt,
    required this.updatedAt,
  });
}