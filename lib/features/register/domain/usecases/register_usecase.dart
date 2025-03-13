import 'package:beepay/features/register/domain/entities/register_entity.dart';

import '../repositories/register_repository.dart';

class RegisterUserUseCase {
  final RegisterRepository repository;

  RegisterUserUseCase(this.repository);

  Future<RegisterEntity> call(Map<String, dynamic> userData) {
    return repository.registerUser(userData);
  }
}
