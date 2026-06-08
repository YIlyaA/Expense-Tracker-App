import 'package:expenses_tracker/core/network/token_storage.dart';
import 'package:expenses_tracker/core/repositories/auth_repository.dart';
import 'package:expenses_tracker/core/network/api_client.dart';
import 'package:expenses_tracker/core/network/services/auth_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TokenStorage tokenStorage;
  late AuthRepository repo;

  setUp(() {
    tokenStorage = TokenStorage.inMemory();
    final apiClient = ApiClient(tokenStorage: tokenStorage);
    final authApi = AuthApiService(apiClient: apiClient);
    repo = AuthRepository(
      authApiService: authApi,
      tokenStorage: tokenStorage,
    );
  });

  test('isLoggedIn returns false when no tokens', () async {
    final result = await repo.isLoggedIn();
    expect(result, false);
  });

  test('logout clears tokens', () async {
    await tokenStorage.saveTokens(access: 'test_access', refresh: 'test_refresh');
    expect(await repo.isLoggedIn(), true);

    await repo.logout();
    expect(await repo.isLoggedIn(), false);
  });

  test('getCurrentUser returns null when no tokens', () async {
    final user = await repo.getCurrentUser();
    expect(user, isNull);
  });
}
