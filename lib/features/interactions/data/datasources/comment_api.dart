import 'package:app/core/api/api_client.dart';
import '../models/comment_model.dart';
import '../../../../core/api/endpoints.dart';

class CommentApi {
  final ApiClient apiClient;

  CommentApi(this.apiClient);

  Future<List<CommentModel>> getComments(int postId) async {
    final response = await apiClient.dio.get(Endpoints.getComments(postId));
    final dynamic data = response.data;
    final List results = (data is List) ? data : (data['results'] as List<dynamic>? ?? []);
    return results.map((json) => CommentModel.fromJson(json)).toList();
  }

  Future<CommentModel> addComment(int postId, String text) async {
    final response = await apiClient.dio.post(
      Endpoints.addComment(postId),
      data: {'post': postId, 'text': text},
    );
    return CommentModel.fromJson(response.data);
  }

  Future<bool> toggleCommentLike(int commentId) async {
    final response = await apiClient.dio.post(Endpoints.likeComment(commentId));
    return response.data['is_liked'] ?? false;
  }
}