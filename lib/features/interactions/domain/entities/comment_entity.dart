import '../../../accounts/domain/entities/user_entity.dart';

class CommentEntity {
  final int id;
  final UserEntity author;
  final String text;
  final DateTime createdAt;
  int likesCount;
  bool hasLiked;

  CommentEntity({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    required this.likesCount,
    required this.hasLiked,
  });
}