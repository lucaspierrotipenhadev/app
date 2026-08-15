import 'package:dio/dio.dart';

import '../api/endpoints.dart';
import '../storage/token_storage.dart';

class TokenManager
{
  final Dio _refreshDio;
  final TokenStorage tokenStorage;

  TokenManager({required this.tokenStorage,}) : _refreshDio = Dio
  (
    BaseOptions(
      baseUrl: Endpoints.root,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  bool _isRefreshing = false;
  Future<String?>? _refreshFuture;

  Future<String?> getAccessToken()
  {
    return tokenStorage.getAccessToken();
  }

  Future<void> saveTokens({required String access, required String refresh,})
  {
    return tokenStorage.saveTokens(access: access, refresh: refresh);
  }

  Future<void> logout()
  {
    return tokenStorage.clear();
  }

  Future<String?> _performRefresh() async
  {
    try
    {
      final refreshToken = await tokenStorage.getRefreshToken();

      if(refreshToken == null) return null;

      final response = await _refreshDio.post(
        Endpoints.refresh,
        data: {"refresh":refreshToken,},
        options: Options(headers: {"Authorization":null,},),
      );

      final newAccess = response.data['access'];
      await tokenStorage.saveTokens(access: newAccess, refresh: refreshToken);

      return newAccess;
    }catch(_)
    {
      await tokenStorage.clear();
      return null;
    }
  }

  Future<String?> refreshAccessToken() async
  {
    if(_isRefreshing) return _refreshFuture;
    _isRefreshing = true;
    _refreshFuture = _performRefresh();

    final token = await _refreshFuture;

    _isRefreshing = false;
    _refreshFuture = null;

    return token;
  }
}