import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(
      {required this.remoteDataSource, required this.secureStorage});

  @override
  Future<AuthEntity> login(String cel, String password) async {
    try {
      final authModel = await remoteDataSource.login(cel, password);

      // Guardar token y mensaje en almacenamiento seguro
      await secureStorage.write(key: 'auth_token', value: authModel.token);
      await secureStorage.write(key: 'auth_message', value: authModel.mensaje);

      return authModel;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<AuthEntity> loginBiometric(String deviceId) async {
    try {
      final authModel = await remoteDataSource.loginBiometric(deviceId);

      // Guardar token y mensaje en almacenamiento seguro
      await secureStorage.write(key: 'auth_token', value: authModel.token);
      await secureStorage.write(key: 'auth_message', value: authModel.mensaje);

      return authModel;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// obtener token almacenado
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  /// obtener mensaje almacenado
  Future<String?> getMessage() async {
    return await secureStorage.read(key: 'auth_message');
  }

  /// eliminar credenciales (logout)
  Future<void> logout() async {
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'auth_message');
  }
}
