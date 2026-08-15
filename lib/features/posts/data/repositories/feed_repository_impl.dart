// lib/features/posts/data/repositories/feed_repository_impl.dart
import 'dart:io';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_api.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedApi api;

  FeedRepositoryImpl(this.api);

  @override
  Future<List<PostEntity>> getFeed({int page = 1}) {
    return api.getFeed(page: page);
  }

  @override
  Future<PostEntity> createPost({required String text, List<File>? files}) {
    return api.createPost(text: text, files: files);
  }

  @override
  Future<bool> toggleLike(int postId) {
    return api.toggleLike(postId);
  }

  @override
  Future<void> deletePost(int postId) {
    return api.deletePost(postId);
  }
}