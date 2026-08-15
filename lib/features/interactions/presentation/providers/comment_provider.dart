import 'package:flutter/material.dart';
import '../../data/datasources/comment_api.dart';
import '../../data/models/comment_model.dart';
import '../../domain/entities/comment_entity.dart';

class CommentProvider extends ChangeNotifier {
  final CommentApi _api;
  final int postId;

  CommentProvider({required this._api, required this.postId});

  List<CommentEntity> _comments = [];
  bool _loading = false;
  bool _sending = false;
  String? _error;

  List<CommentEntity> get comments => _comments;
  bool get loading => _loading;
  bool get sending => _sending;
  String? get error => _error;

  Future<void> fetchComments() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _comments = await _api.getComments(postId);
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar comentários: $e');
      debugPrint('StackTrace: $stackTrace');
      _error = 'Erro ao carregar comentários.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addComment(String text) async {
    if (text.trim().isEmpty) return false;

    _sending = true;
    _error = null;
    notifyListeners();

    try {
      final newComment = await _api.addComment(postId, text);
      
      // Adiciona o comentário na lista local
      _comments.add(newComment);
      
      _sending = false;
      notifyListeners(); // 👈 Notifica a UI com a lista atualizada ANTES de retornar sucesso
      return true;
    } catch (e) {
      debugPrint('Erro ao enviar comentário: $e');
      _error = 'Erro ao enviar comentário.';
      _sending = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleLike(int commentId) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    final comment = _comments[index];
    if (comment is! CommentModel) return;

    final wasLiked = comment.hasLiked;
    final currentLikes = comment.likesCount;

    // Atualização otimista usando copyWith
    _comments[index] = comment.copyWith(
      hasLiked: !wasLiked,
      likesCount: wasLiked ? currentLikes - 1 : currentLikes + 1,
    );
    notifyListeners();

    try {
      final isLikedServer = await _api.toggleCommentLike(commentId);
      // Confirma o estado vindo do servidor
      if (_comments[index] is CommentModel) {
        _comments[index] = (_comments[index] as CommentModel).copyWith(
          hasLiked: isLikedServer,
        );
        notifyListeners();
      }
    } catch (e) {
      // Reverte estado anterior em caso de erro
      _comments[index] = comment;
      notifyListeners();
    }
  }
}