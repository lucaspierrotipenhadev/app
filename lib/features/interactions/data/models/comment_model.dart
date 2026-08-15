import '../../../accounts/data/models/user_model.dart';
import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  CommentModel({
    required super.id,
    required super.author,
    required super.text,
    required super.createdAt,
    required super.likesCount,
    required super.hasLiked,
  });

  CommentModel copyWith({
    int? id,
    String? text,
    DateTime? createdAt,
    bool? hasLiked,
    int? likesCount,
    UserModel? author,
  }) {
    return CommentModel(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      hasLiked: hasLiked ?? this.hasLiked,
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      author: UserModel.fromJson(json['author']),
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      likesCount: json['likes_count'] ?? 0,
      hasLiked: json['is_liked'] ?? json['has_liked'] ?? false,
    );
  }
}