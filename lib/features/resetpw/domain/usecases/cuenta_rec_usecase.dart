import '../entities/cuenta_rec_entity.dart';
import '../repositories/recupera_repository.dart';

class CuentaRecUseCase {
  final RecuperaRepository repository;

  CuentaRecUseCase(this.repository);

  Future<CuentaRecEntity> call(String email, String codigo) {
    return repository.verificarCodigoCuenta(email, codigo);
  }
}
