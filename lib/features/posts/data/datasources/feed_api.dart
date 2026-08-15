import 'dart:io';
import '../../../../core/api/endpoints.dart';
import 'package:app/core/api/api_client.dart';
import 'package:dio/dio.dart';
import '../models/post_model.dart';

class FeedApi {
  final ApiClient apiClient;

  FeedApi(this.apiClient);

  Future<List<PostModel>> getFeed({int page = 1}) async {
    final response = await apiClient.dio.get(
      Endpoints.feed,
      queryParameters: {'page': page},
    );

    final List results = response.data['results'] ?? response.data;
    return results.map((json) => PostModel.fromJson(json)).toList();
  }

  Future<PostModel> createPost({required String text, List<File>? files}) async {
    final formDataMap = <String, dynamic>{
      'text': text,
    };

    if (files != null && files.isNotEmpty) {
      final multipartFiles = <MultipartFile>[];
      for (final file in files) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }
      formDataMap['files'] = multipartFiles;
    }

    final formData = FormData.fromMap(formDataMap);
    final response = await apiClient.dio.post(Endpoints.posts, data: formData);

    return PostModel.fromJson(response.data);
  }

  Future<bool> toggleLike(int postId) async {
    final response = await apiClient.dio.post(Endpoints.likePost(postId));
    return response.data['is_liked'] ?? false;
  }

  Future<void> deletePost(int postId) async {
    await apiClient.dio.delete(Endpoints.deletePost(postId));
  }
}