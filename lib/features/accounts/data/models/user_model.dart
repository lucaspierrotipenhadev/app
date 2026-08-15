import '../../domain/entities/user_entity.dart';
import 'profile_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.profile,
    super.followersCount,
    super.followingCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile': (profile as ProfileModel?)?.toJson(),
      'followers_count': followersCount,
      'following_count': followingCount,
    };
  }
}