import 'profile_entity.dart';

class UserEntity {
  final int id;
  final String username;
  final String email;
  final ProfileEntity? profile;
  final int followersCount;
  final int followingCount;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.profile,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  String get nameToShow =>
      (profile?.displayName.isNotEmpty ?? false) ? profile!.displayName : username;
}