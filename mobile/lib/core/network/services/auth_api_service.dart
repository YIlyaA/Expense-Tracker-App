import '../api_client.dart';

class AuthApiService {
  AuthApiService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/register/',
      data: {
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
      },
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login/',
      data: {'email': email, 'password': password},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/refresh/',
      data: {'refresh': refreshToken},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _api.get<Map<String, dynamic>>('/auth/me/');
    return response.data!;
  }
}
