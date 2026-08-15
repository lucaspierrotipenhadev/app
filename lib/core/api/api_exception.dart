// lib/core/api/api_exception.dart
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Conexão expirada. Verifique sua internet.',
        );

      case DioExceptionType.badResponse:
        final response = dioError.response;
        final statusCode = response?.statusCode;
        final data = response?.data;

        String message = 'Ocorreu um erro no servidor ($statusCode).';

        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail')) {
            message = data['detail'].toString();
          } else if (data.isNotEmpty) {
            // Pega o primeiro erro de validação retornado pelo Django DRF
            final firstKey = data.keys.first;
            final firstValue = data[firstKey];
            if (firstValue is List && firstValue.isNotEmpty) {
              message = '$firstKey: ${firstValue.first}';
            } else {
              message = '$firstKey: $firstValue';
            }
          }
        }

        return ApiException(message: message, statusCode: statusCode);

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Sem conexão com o servidor. Verifique se a API está rodando.',
        );

      default:
        return ApiException(
          message: 'Ocorreu um erro inesperado. Tente novamente.',
        );
    }
  }

  @override
  String toString() => message;
}