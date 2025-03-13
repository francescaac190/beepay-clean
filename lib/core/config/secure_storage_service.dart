import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SecureStorageService._internal();

  /// Guardar el token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Obtener el token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Eliminar el token (para logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
