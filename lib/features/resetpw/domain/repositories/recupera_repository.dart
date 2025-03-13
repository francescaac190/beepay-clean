import 'package:beepay/features/resetpw/domain/entities/actualiza_pass_entity.dart';
import 'package:beepay/features/resetpw/domain/entities/cuenta_rec_entity.dart';
import 'package:beepay/features/resetpw/domain/entities/recupera_cuenta_entity.dart';

import '../entities/recupera_entity.dart';

abstract class RecuperaRepository {
  Future<RecuperaEntity> recupera(String email);
  Future<ActualizaPassEntity> actualizaPass(String email, String verificacion,
      String password, String passwordConfirmation);
  Future<RecuperaCuentaEntity> recuperarCuenta(String email);
  Future<CuentaRecEntity> verificarCodigoCuenta(String email, String codigo);
}
