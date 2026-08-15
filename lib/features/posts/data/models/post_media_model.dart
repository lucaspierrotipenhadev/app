import '../../domain/entities/post_media_entity.dart';

class PostMediaModel extends PostMediaEntity {
  PostMediaModel({
    required super.id,
    required super.file,
    required super.mediaType,
    required super.createdAt,
  });

  factory PostMediaModel.fromJson(Map<String, dynamic> json) {
    return PostMediaModel(
      id: json['id'],
      file: json['file'] ?? '',
      mediaType: json['media_type'] ?? 'IMAGE',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}