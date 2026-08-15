import 'dart:io';
import '../entities/post_entity.dart';

abstract class FeedRepository {
  Future<List<PostEntity>> getFeed({int page = 1});
  Future<PostEntity> createPost({required String text, List<File>? files});
  Future<bool> toggleLike(int postId);
  Future<void> deletePost(int postId);
}