import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exceptions.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    _authInterceptor = AuthInterceptor(
      dio: _dio,
      tokenStorage: tokenStorage,
    );
    _dio.interceptors.add(_authInterceptor);
  }

  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  void setOnSessionExpired(void Function() callback) {
    _authInterceptor.onSessionExpired = callback;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<void>> delete(String path) async {
    try {
      return await _dio.delete<void>(path);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Dio get dio => _dio;
}
