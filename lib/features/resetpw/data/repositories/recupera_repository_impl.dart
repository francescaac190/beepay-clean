import 'package:beepay/features/resetpw/domain/entities/actualiza_pass_entity.dart';
import 'package:beepay/features/resetpw/domain/entities/recupera_cuenta_entity.dart';

import '../../domain/entities/cuenta_rec_entity.dart';
import '../../domain/entities/recupera_entity.dart';
import '../../domain/repositories/recupera_repository.dart';
import '../datasources/recupera_remote_data_source.dart';

class RecuperaRepositoryImpl implements RecuperaRepository {
  final RecuperaRemoteDataSource remoteDatasource;

  RecuperaRepositoryImpl({required this.remoteDatasource});

  @override
  Future<RecuperaEntity> recupera(String email) async {
    return await remoteDatasource.recupera(email);
  }

  Future<ActualizaPassEntity> actualizaPass(String email, String verificacion,
      String password, String passwordConfirmation) async {
    return await remoteDatasource.actualizaPass(
        email, verificacion, password, passwordConfirmation);
  }

  Future<RecuperaCuentaEntity> recuperarCuenta(String email) async {
    return await remoteDatasource.recuperarCuenta(email);
  }

  Future<CuentaRecEntity> verificarCodigoCuenta(
      String email, String codigo) async {
    return await remoteDatasource.verificarCodigoCuenta(email, codigo);
  }
}
