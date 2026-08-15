import '../entities/user_entity.dart';
import '../repositories/account_repository.dart';

class GetCurrentUserUseCase {
  final AccountRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<UserEntity?> call() async {
    return await _repository.getCurrentUser();
  }
}