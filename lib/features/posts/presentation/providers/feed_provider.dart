import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/feed_repository.dart';

class FeedProvider extends ChangeNotifier {
  final FeedRepository repository;

  FeedProvider({required this.repository});

  List<PostEntity> _posts = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<PostEntity> get posts => _posts;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchFeed({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _loading = true;
    } else {
      if (!_hasMore || _loadingMore) return;
      _loadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final newPosts = await repository.getFeed(page: _currentPage);
      
      if (refresh) {
        _posts = newPosts;
      } else {
        _posts.addAll(newPosts);
      }

      if (newPosts.length < 10) {
        _hasMore = false;
      } else {
        _currentPage++;
      }
    } catch (e) {
      _error = 'Erro ao carregar publicações.';
    } finally {
      _loading = false;
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> toggleLike(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return false;

    final post = _posts[index];
    
    // Atualização otimista no cliente para renderização instantânea
    final wasLiked = post.hasLiked;
    post.hasLiked = !wasLiked;
    post.likesCount += wasLiked ? -1 : 1;
    notifyListeners();

    try {
      final isLikedServer = await repository.toggleLike(postId);
      post.hasLiked = isLikedServer;
      return true;
    } catch (e) {
      // Reverte em caso de falha no servidor
      post.hasLiked = wasLiked;
      post.likesCount += wasLiked ? 1 : -1;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPost({required String text, List<File>? files}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final newPost = await repository.createPost(text: text, files: files);
      _posts.insert(0, newPost); // Insere no topo do feed
      return true;
    } catch (e) {
      _error = 'Erro ao publicar o post.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void incrementCommentCount(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index].commentsCount++;
      notifyListeners();
    }
  }

  void decrementCommentCount(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1 && _posts[index].commentsCount > 0) {
      _posts[index].commentsCount--;
      notifyListeners();
    }
  }
}