import 'package:beepay/features/register/domain/entities/checkuser_entity.dart';

import '../repositories/register_repository.dart';

class CheckUserUseCase {
  final RegisterRepository repository;

  CheckUserUseCase(this.repository);

  Future<CheckUserEntity> call(
      String email, String phone, String ci, String codigo) {
    return repository.checkUser(email, phone, ci, codigo);
  }
}
