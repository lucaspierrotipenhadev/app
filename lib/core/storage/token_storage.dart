import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage
{
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const _accessToken = "access_token";
  static const _refreshToken = "refresh_token";

  Future<void> saveTokens({required String access, required String refresh,}) async
  {
    await _storage.write(key: _accessToken, value: access);
    await _storage.write(key: _refreshToken, value: refresh);
  }

  Future<String?> getAccessToken()
  {
    return _storage.read(key: _accessToken);
  }

  Future<String?> getRefreshToken()
  {
    return _storage.read(key: _refreshToken);
  }

  Future<void> clear() async
  {
    await _storage.deleteAll();
  }
}