import "package:dio/dio.dart";

import 'endpoints.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required List<Interceptor> interceptors})
      : dio = Dio(
          BaseOptions(
            baseUrl: Endpoints.root,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        ) 
  {
    dio.interceptors.addAll(interceptors);
  }
}