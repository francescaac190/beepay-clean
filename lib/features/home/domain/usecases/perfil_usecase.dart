import '../entities/perfil_entity.dart';
import '../repositories/home_repository.dart';

class GetCompletoUseCase {
  final HomeRepository repository;

  GetCompletoUseCase(this.repository);

  Future<Perfil> call() async {
    final perfil = await repository.getCompleto();

    if (perfil != null) {
      return perfil;
    } else {
      throw Exception("Error: No se pudo obtener el perfil.");
    }
  }
}
