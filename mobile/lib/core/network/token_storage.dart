import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _memoryStore = null;

  TokenStorage.inMemory()
      : _storage = null,
        _memoryStore = {};

  final FlutterSecureStorage? _storage;
  final Map<String, String>? _memoryStore;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    if (_memoryStore != null) {
      _memoryStore[_accessKey] = access;
      _memoryStore[_refreshKey] = refresh;
      return;
    }
    final storage = _storage!;
    await Future.wait([
      storage.write(key: _accessKey, value: access),
      storage.write(key: _refreshKey, value: refresh),
    ]);
  }

  Future<String?> getAccessToken() async {
    if (_memoryStore != null) return _memoryStore[_accessKey];
    return _storage!.read(key: _accessKey);
  }

  Future<String?> getRefreshToken() async {
    if (_memoryStore != null) return _memoryStore[_refreshKey];
    return _storage!.read(key: _refreshKey);
  }

  Future<void> clearTokens() async {
    if (_memoryStore != null) {
      _memoryStore.remove(_accessKey);
      _memoryStore.remove(_refreshKey);
      return;
    }
    final storage = _storage!;
    await Future.wait([
      storage.delete(key: _accessKey),
      storage.delete(key: _refreshKey),
    ]);
  }

  Future<bool> hasTokens() async {
    final access = await getAccessToken();
    return access != null && access.isNotEmpty;
  }
}
