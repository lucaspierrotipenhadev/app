import 'package:flutter/material.dart';
import 'dart:io';

import '../../../../core/auth/token_manager.dart';
import '../../data/models/register_request_dto.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../../data/models/update_profile_request_dto.dart';

class AccountProvider extends ChangeNotifier {
  final AccountRepository repository;
  final TokenManager tokenManager;

  AccountProvider({
    required this.repository,
    required this.tokenManager,
  });

  bool _loading = false;
  String? _erro;
  bool _authenticated = false;
  UserEntity? _currentUser; // 🟢 Guarda as informações do usuário logado em memória

  bool get loading => _loading;
  String? get erro => _erro;
  bool get authenticated => _authenticated;
  UserEntity? get currentUser => _currentUser; // 🟢 Getter público para telas usarem

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final tokens = await repository.login(
        username: username,
        password: password,
      );
      
      // O TokenManager assume a responsabilidade de salvar no Storage
      await tokenManager.saveTokens(
        access: tokens.access,
        refresh: tokens.refresh,
      );

      // 🟢 Após salvar os tokens, busca as informações do usuário logado
      _currentUser = await repository.getCurrentUser();
      _authenticated = true;
      return true;
    } catch (e) {
      _erro = "Usuário ou senha estão incorretos!";
      _authenticated = false;
      _currentUser = null;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await tokenManager.logout();
    _authenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkLogin() async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final token = await tokenManager.getAccessToken();

      // Se nem tiver token no storage, já define como não autenticado
      if (token == null || token.isEmpty) {
        _authenticated = false;
        _currentUser = null;
        return;
      }

      // 🟢 Chame o método correto da sua interface: getCurrentUser()
      _currentUser = await repository.getCurrentUser();
      _authenticated = true;
    } catch (e) {
      // Se a API retornar 401/403 (token expirado ou inválido)
      _authenticated = false;
      _currentUser = null;
      await tokenManager.logout(); // Limpa tokens corrompidos/expirados do storage
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Ação de Registro
  Future<bool> register(RegisterRequestDto request) async {
    _loading = true;
    _erro = null;

    try {
      await repository.register(request);
      final successLogin = await login(
        username: request.username,
        password: request.password,
      );
      return successLogin;
    } catch (e) {
      _erro = 'Falha ao registrar conta. Verifique os dados.';
      return false;
    } finally {
      _loading = false;
    }
  }

  // 🟢 Ação de Atualização de Perfil
  Future<bool> updateProfile({
    required String username,
    required String email,
    String? displayName,
    String? bio,
    File? avatar,
    DateTime? birthDate,
  }) async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final dto = UpdateProfileRequestDto(
        username: username,
        email: email,
        displayName: displayName,
        bio: bio,
        avatar: avatar,
        birthDate: birthDate,
      );

      await repository.updateProfile(dto);
      
      // 🟢 Recarrega o usuário atualizado da API para sincronizar o estado local
      _currentUser = await repository.getCurrentUser();
      return true;
    } catch (e) {
      _erro = 'Falha ao atualizar perfil. Verifique os dados.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}