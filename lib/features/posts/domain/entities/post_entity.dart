import '../../../accounts/domain/entities/user_entity.dart';
import 'post_media_entity.dart';

class PostEntity {
  final int id;
  final UserEntity author;
  final String text;
  final bool edited;
  final List<PostMediaEntity> media;
  final DateTime createdAt;
  final DateTime updatedAt;
  int likesCount;
  int commentsCount;
  bool hasLiked;

  PostEntity({
    required this.id,
    required this.author,
    required this.text,
    required this.edited,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.hasLiked,
  });
}