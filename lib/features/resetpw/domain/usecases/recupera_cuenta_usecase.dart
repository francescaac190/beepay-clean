import '../entities/recupera_cuenta_entity.dart';
import '../repositories/recupera_repository.dart';

class RecuperaCuentaUsecase {
  final RecuperaRepository repository;

  RecuperaCuentaUsecase(this.repository);

  Future<RecuperaCuentaEntity> call(String email) {
    return repository.recuperarCuenta(email);
  }
}
