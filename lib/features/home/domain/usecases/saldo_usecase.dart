import '../entities/saldo_entity.dart';
import '../repositories/home_repository.dart';

class GetSaldoUseCase {
  final HomeRepository repository;

  GetSaldoUseCase(this.repository);

  Future<SaldoEntity> call() async {
    final saldo = await repository.getSaldo();
    if (saldo == null) {
      throw Exception("Error: El saldo recibido es nulo");
    }
    return saldo;
  }
}
