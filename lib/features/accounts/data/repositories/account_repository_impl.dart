import '../../domain/entities/token_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/auth_api.dart';
import '../models/login_request.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';
import '../models/register_request_dto.dart';
import '../models/update_profile_request_dto.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AuthApi api;

  AccountRepositoryImpl(this.api);

  @override
  Future<TokenEntity> login({
    required String username,
    required String password,
  }) {
    return api.login(LoginRequest(username: username, password: password));
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    return await api.getMe();
  }

  @override
  Future<UserModel> register(RegisterRequestDto request) async {
    return await api.register(request);
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequestDto request) async {
    return await api.updateProfile(request);
  }

  Future<TokenModel> refresh(String refreshToken)
  {
    return api.refresh(refreshToken);
  }
}