import '../entities/recupera_entity.dart';
import '../repositories/recupera_repository.dart';

class RecuperaUsecase {
  final RecuperaRepository repository;

  RecuperaUsecase(this.repository);

  Future<RecuperaEntity> call(String email) {
    return repository.recupera(email);
  }
}
