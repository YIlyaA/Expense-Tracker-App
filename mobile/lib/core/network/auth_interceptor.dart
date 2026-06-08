import 'dart:async';

import 'package:dio/dio.dart';

import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
  })  : _dio = dio,
        _tokenStorage = tokenStorage;

  final Dio _dio;
  final TokenStorage _tokenStorage;

  void Function()? onSessionExpired;

  bool _isRefreshing = false;
  final _pendingRequests = <Completer<void>>[];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (err.requestOptions.path.contains('/auth/refresh/')) {
      await _tokenStorage.clearTokens();
      onSessionExpired?.call();
      return handler.next(err);
    }

    if (_isRefreshing) {
      final completer = Completer<void>();
      _pendingRequests.add(completer);
      try {
        await completer.future;
        final retryResponse = await _retryRequest(err.requestOptions);
        return handler.resolve(retryResponse);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearTokens();
        onSessionExpired?.call();
        return handler.next(err);
      }

      final response = await _dio.post(
        '/auth/refresh/',
        data: {'refresh': refreshToken},
        options: Options(headers: {}), // no auth header
      );

      final newAccess = response.data['access'] as String;
      final newRefresh =
          response.data['refresh'] as String? ?? refreshToken;

      await _tokenStorage.saveTokens(
        access: newAccess,
        refresh: newRefresh,
      );

      for (final completer in _pendingRequests) {
        completer.complete();
      }
      _pendingRequests.clear();

      final retryResponse = await _retryRequest(err.requestOptions);
      return handler.resolve(retryResponse);
    } on DioException {
      await _tokenStorage.clearTokens();
      for (final completer in _pendingRequests) {
        completer.completeError(err);
      }
      _pendingRequests.clear();
      onSessionExpired?.call();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    final token = await _tokenStorage.getAccessToken();
    options.headers['Authorization'] = 'Bearer $token';
    return _dio.fetch(options);
  }
}
