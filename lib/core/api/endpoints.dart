// lib/core/api/endpoints.dart
abstract class Endpoints {
  // Configuração para emulador Android local (10.0.2.2). Se for iOS ou Web, use localhost
  static const root = "http://127.0.0.1:8000/api/v1";

  // Accounts
  static const register = "/accounts/register/";
  static const login = "/accounts/token/";
  static const refresh = "/accounts/token/refresh/";
  static const me = "/accounts/me/";
  static const updateProfile = "/accounts/profile/update/";

  // Feed & Posts
  static const feed = "/feed/feed/";
  static const posts = "/posts/";
  static String deletePost(int postId) => "/posts/$postId/";
  
  // Interações
  static const comments = "/interactions/comments/";
  static String getComments(int postId) => "/interactions/comments/?post=$postId";
  static String addComment(int postId) => '/interactions/comments/';

  // Métodos auxiliares para rotas dinâmicas com parâmetros
  static String likePost(int postId) => "/interactions/posts/$postId/like/";
  static String likeComment(int commentId) => "/interactions/comments/$commentId/like/";
  static String followUser(int userId) => "/social/users/$userId/follow/";
  static String userFollowers(int userId) => "/social/users/$userId/followers/";
  static String userFollowing(int userId) => "/social/users/$userId/following/";
}