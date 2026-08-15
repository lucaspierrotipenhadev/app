import '../../../accounts/data/models/user_model.dart';
import '../../domain/entities/post_entity.dart';
import 'post_media_model.dart';

class PostModel extends PostEntity {
  PostModel({
    required super.id,
    required super.author,
    required super.text,
    required super.edited,
    required super.media,
    required super.createdAt,
    required super.updatedAt,
    required super.likesCount,
    required super.commentsCount,
    required super.hasLiked,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Tratamento para ler 'media' (FeedPostSerializer) ou 'medias' (PostSerializer)
    final mediaList = (json['media'] ?? json['medias'] ?? []) as List;

    return PostModel(
      id: json['id'],
      author: UserModel.fromJson(json['author']),
      text: json['text'] ?? '',
      edited: json['edited'] ?? false,
      media: mediaList.map((m) => PostMediaModel.fromJson(m)).toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      hasLiked: json['has_liked'] ?? false,
    );
  }
}