import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.originalError});

  final String message;
  final int? statusCode;
  final DioException? originalError;

  factory ApiException.fromDioError(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      return UnauthorizedException(
        error.response?.data?['detail'] as String? ?? 'Unauthorized',
        originalError: error,
      );
    }

    if (statusCode == 400) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        return ValidationException(
          fieldErrors: data.map(
            (key, value) => MapEntry(
              key,
              value is List
                  ? value.map((e) => e.toString()).toList()
                  : [value.toString()],
            ),
          ),
          originalError: error,
        );
      }
    }

    if (statusCode != null && statusCode >= 500) {
      return ServerException(originalError: error);
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException(originalError: error);
    }

    return ApiException(
      error.message ?? 'Unknown error',
      statusCode: statusCode,
      originalError: error,
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {super.originalError, super.statusCode = 401});
}

class ValidationException extends ApiException {
  ValidationException({
    required this.fieldErrors,
    super.originalError,
  }) : super('Validation failed', statusCode: 400);

  final Map<String, List<String>> fieldErrors;

  String get firstError {
    for (final errors in fieldErrors.values) {
      if (errors.isNotEmpty) return errors.first;
    }
    return 'Validation failed';
  }
}

class NetworkException extends ApiException {
  NetworkException({super.originalError})
      : super('No internet connection or server unreachable');
}

class ServerException extends ApiException {
  ServerException({super.originalError})
      : super('Internal server error', statusCode: 500);
}
