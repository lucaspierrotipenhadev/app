import '../entities/token_entity.dart';
import '../entities/user_entity.dart';
import '../../data/models/user_model.dart';
import '../../data/models/register_request_dto.dart';
import '../../data/models/update_profile_request_dto.dart';

abstract class AccountRepository {
  /// Faz o login no Django e retorna os tokens JWT (access/refresh)
  Future<TokenEntity> login({
    required String username,
    required String password,
  });

  /// Busca os dados do endpoint /accounts/me/ usando o token salvo
  Future<UserEntity> getCurrentUser();
  Future<UserModel> register(RegisterRequestDto request);
  Future<void> updateProfile(UpdateProfileRequestDto dto);
}