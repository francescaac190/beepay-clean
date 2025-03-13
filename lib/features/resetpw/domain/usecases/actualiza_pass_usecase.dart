import '../entities/actualiza_pass_entity.dart';
import '../repositories/recupera_repository.dart';

class ActualizaPassUsecase {
  final RecuperaRepository repository;

  ActualizaPassUsecase(this.repository);

  Future<ActualizaPassEntity> call(String email, String verificacion,
      String password, String passwordConfirmation) {
    return repository.actualizaPass(
        email, verificacion, password, passwordConfirmation);
  }
}
