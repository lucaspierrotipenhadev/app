import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/login_request.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';
import '../models/register_request_dto.dart';
import '../models/update_profile_request_dto.dart';

class AuthApi {
  final ApiClient apiClient;

  AuthApi(this.apiClient);

  Future<TokenModel> login(LoginRequest request) async {
    final response = await apiClient.dio.post(
      Endpoints.login,
      data: request.toJson(),
    );
    return TokenModel.fromJson(response.data);
  }

  Future<UserModel> register(RegisterRequestDto request) async {
    // Construção do formulário multipart
    final formData = FormData.fromMap({
      'username': request.username,
      'email': request.email,
      'password': request.password,
      'password_confirm': request.passwordConfirm,
      'display_name': request.displayName,
      'bio': request.bio,
      if (request.birthDate != null)
        'birth_date': request.birthDate!.toIso8601String().split('T').first,
      
      // Anexa o arquivo de imagem caso o usuário tenha selecionado uma foto
      if (request.avatar != null)
        'avatar': await MultipartFile.fromFile(
          request.avatar!.path,
          filename: request.avatar!.path.split('/').last,
        ),
    });

    final response = await apiClient.dio.post(
      Endpoints.register, // Rota do seu backend Django
      data: formData,
    );

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TokenModel> refresh(String refreshToken) async {
    final response = await apiClient.dio.post(
      Endpoints.refresh,
      data: {"refresh": refreshToken},
    );
    return TokenModel.fromJson(response.data);
  }

  Future<UserModel> getMe() async {
    // O ApiClient/Interceptor cuida de injetar o token no header!
    final response = await apiClient.dio.get(Endpoints.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }


  Future<UserModel> updateProfile(UpdateProfileRequestDto request) async {
    final Map<String, dynamic> map = {
      'username': request.username,
      'email': request.email,
      if (request.displayName != null) 'display_name': request.displayName,
      if (request.bio != null) 'bio': request.bio,
      if (request.birthDate != null)
        'birth_date': request.birthDate!.toIso8601String().split('T').first,
    };

    // Adiciona o arquivo apenas se o usuário tiver selecionado um novo avatar
    if (request.avatar != null) {
      final fileName = request.avatar!.path.split('/').last;
      map['avatar'] = await MultipartFile.fromFile(
        request.avatar!.path,
        filename: fileName,
      );
    }

    final formData = FormData.fromMap(map);

    // Ajuste o verbo (PATCH ou PUT) e o path conforme seu backend Django
    final response = await apiClient.dio.patch(
      Endpoints.updateProfile,
      data: formData,
    );

    return UserModel.fromJson(response.data);
  }
}