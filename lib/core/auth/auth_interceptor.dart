import 'package:dio/dio.dart';
import '../auth/token_manager.dart';
import '../api/endpoints.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager tokenManager;

  AuthInterceptor({required this.tokenManager});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await tokenManager.getAccessToken();

    if (accessToken?.isNotEmpty == true) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Se o erro de 401 ocorreu na própria rota de refresh, faz logout e encerra
      if (err.requestOptions.path == Endpoints.refresh) {
        await tokenManager.logout();
        return handler.next(err);
      }

      // Tenta atualizar o token
      final newAccess = await tokenManager.refreshAccessToken();

      if (newAccess != null) {
        final options = err.requestOptions;
        
        // Atualiza o cabeçalho Authorization com o novo token
        options.headers["Authorization"] = "Bearer $newAccess";

        try {
          // Instancia um Dio exclusivo com as mesmas opções de base (baseUrl, timeouts)
          final retryDio = Dio(
            BaseOptions(
              baseUrl: options.baseUrl,
              connectTimeout: options.connectTimeout,
              receiveTimeout: options.receiveTimeout,
            ),
          );

          // Refaz a requisição original clonada
          final cloneResponse = await retryDio.fetch(options);
          
          // Retorna o resultado com sucesso
          return handler.resolve(cloneResponse);
        } catch (retryError) {
          if (retryError is DioException) {
            return handler.next(retryError);
          }
          return handler.next(err);
        }
      }

      // Se não conseguiu um novo token, faz o logout
      await tokenManager.logout();
    }

    return handler.next(err);
  }
}