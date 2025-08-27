// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({required this.remoteDataSource, required this.secureStorage});

  String _ts() => DateTime.now().toIso8601String();
  void _log(String tag, String msg) => print('[AUTH-REPO][$tag][${_ts()}] $msg');

  @override
  Future<AuthEntity> login(String cel, String password) async {
    _log('LOGIN', '→ remote.login cel=$cel passLen=${password.length}');
    try {
      final AuthModel authModel = await remoteDataSource.login(cel, password);

      _log('LOGIN', 'Guardando en secureStorage...');
      await secureStorage.write(key: 'auth_token', value: authModel.token);
      await secureStorage.write(key: 'auth_message', value: authModel.mensaje);
      _log('LOGIN', 'OK tokenLen=${authModel.token.length} mensaje="${authModel.mensaje}"');

      return authModel;
    } catch (e) {
      _log('LOGIN', 'ERROR: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<AuthEntity> loginBiometric(String deviceId) async {
    _log('BIO', '→ remote.loginBiometric deviceIdLen=${deviceId.length}');
    try {
      final AuthModel authModel = await remoteDataSource.loginBiometric(deviceId);

      _log('BIO', 'Guardando en secureStorage...');
      await secureStorage.write(key: 'auth_token', value: authModel.token);
      await secureStorage.write(key: 'auth_message', value: authModel.mensaje);
      _log('BIO', 'OK tokenLen=${authModel.token.length} mensaje="${authModel.mensaje}"');

      return authModel;
    } catch (e) {
      _log('BIO', 'ERROR: $e');
      throw Exception(e.toString());
    }
  }

  /// obtener token almacenado
  Future<String?> getToken() async {
    final t = await secureStorage.read(key: 'auth_token');
    _log('HELPER', 'getToken -> ${t == null ? 'null' : 'len=${t.length}'}');
    return t;
  }

  /// obtener mensaje almacenado
  Future<String?> getMessage() async {
    final m = await secureStorage.read(key: 'auth_message');
    _log('HELPER', 'getMessage -> "${m ?? 'null'}"');
    return m;
  }

  /// eliminar credenciales (logout)
  Future<void> logout() async {
    _log('HELPER', 'logout -> borrar auth_token y auth_message');
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'auth_message');
  }
}
