import 'package:app/features/accounts/domain/entities/token_entity.dart';

import '../repositories/account_repository.dart';

class LoginUseCase {
  final AccountRepository _repository;

  LoginUseCase(this._repository);

  Future<TokenEntity> call({
    required String username,
    required String password,
  }) async {
    // Validações de regra de negócio antes de chamar o repositório
    if (username.isEmpty) {
      throw Exception('Usuário inválido.');
    }

    if (password.length < 6) {
      throw Exception('A senha deve ter pelo menos 6 caracteres.');
    }

    return await _repository.login(username: username, password: password);
  }
}