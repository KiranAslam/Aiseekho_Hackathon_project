import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureSessionServiceProvider = Provider<SecureSessionService>((ref) {
  return SecureSessionService(const FlutterSecureStorage());
});

class SecureSessionService {
  SecureSessionService(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'rahe_sehat_auth_token';

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
