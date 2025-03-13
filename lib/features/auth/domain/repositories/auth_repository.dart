import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String cel, String password);
  Future<AuthEntity> loginBiometric(
      String deviceId); // <-- Agregamos login biométrico
}
