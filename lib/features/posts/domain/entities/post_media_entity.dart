class PostMediaEntity {
  final int id;
  final String file;
  final String mediaType; // 'IMAGE', 'VIDEO', 'GIF', 'DOCUMENT'
  final DateTime createdAt;

  PostMediaEntity({
    required this.id,
    required this.file,
    required this.mediaType,
    required this.createdAt,
  });
}