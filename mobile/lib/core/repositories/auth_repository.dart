import '../../shared/models/api_models.dart';
import '../network/api_exceptions.dart';
import '../network/services/auth_api_service.dart';
import '../network/token_storage.dart';

class AuthRepository {
  AuthRepository({
    required AuthApiService authApiService,
    required TokenStorage tokenStorage,
  })  : _api = authApiService,
        _tokenStorage = tokenStorage;

  final AuthApiService _api;
  final TokenStorage _tokenStorage;

  Future<UserProfile> login(String email, String password) async {
    final raw = await _api.login(email: email, password: password);
    final response = AuthResponse.fromJson(raw);
    await _tokenStorage.saveTokens(
      access: response.tokens.access,
      refresh: response.tokens.refresh,
    );
    return response.user;
  }

  Future<UserProfile> register(
    String email,
    String password,
    String passwordConfirm,
  ) async {
    final raw = await _api.register(
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
    );
    final response = AuthResponse.fromJson(raw);
    await _tokenStorage.saveTokens(
      access: response.tokens.access,
      refresh: response.tokens.refresh,
    );
    return response.user;
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  Future<bool> isLoggedIn() => _tokenStorage.hasTokens();

  Future<UserProfile?> getCurrentUser() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) return null;
    try {
      final raw = await _api.getMe();
      return UserProfile.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isSessionValid() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) return false;
    try {
      await _api.getMe();
      return true;
    } on UnauthorizedException {
      await _tokenStorage.clearTokens();
      return false;
    } catch (_) {
      return true;
    }
  }
}
