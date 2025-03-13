import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginBiometricUseCase {
  final AuthRepository repository;

  LoginBiometricUseCase(this.repository);

  Future<AuthEntity> call(String deviceId) {
    return repository.loginBiometric(deviceId);
  }
}
