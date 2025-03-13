import 'package:beepay/core/config/app_config.dart';
import 'package:dio/dio.dart';

import '../models/actualiza_pass_response.dart';
import '../models/recupera_response.dart';
import '../models/recuperar_cuenta_response.dart';
import '../models/verificar_cuenta_response.dart';

abstract class RecuperaRemoteDataSource {
  Future<RecuperaResponse> recupera(String email);
  Future<ActualizaPassResponse> actualizaPass(
      String email, String phone, String ci, String codigo);
  Future<RecuperaCuentaResponse> recuperarCuenta(String email);
  Future<VerificarCodigoResponse> verificarCodigoCuenta(
      String email, String codigo);
}

class RecuperaRemoteDataSourceImpl implements RecuperaRemoteDataSource {
  final Dio dio;

  RecuperaRemoteDataSourceImpl({required this.dio});

  @override
  Future<RecuperaResponse> recupera(String email) async {
    try {
      final response = await dio
          .post('${AppConfig.baseurl}recupera', data: {'email': email});
      print(response.data);
      return RecuperaResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al enviar codigo");
    }
  }

  @override
  Future<ActualizaPassResponse> actualizaPass(String email, String verificacion,
      String password, String passwordConfirmation) async {
    try {
      final response =
          await dio.post('${AppConfig.baseurl}actualiza_pass', data: {
        'email': email,
        'verificacion': verificacion,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      print(response.data);

      return ActualizaPassResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al actualizar contraseña");
    }
  }

  @override
  Future<RecuperaCuentaResponse> recuperarCuenta(String email) async {
    try {
      final response =
          await dio.post('${AppConfig.baseurl}recuperarCuenta', data: {
        'email': email,
      });

      print(response.data);
      return RecuperaCuentaResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al enviar codigo");
    }
  }

  @override
  Future<VerificarCodigoResponse> verificarCodigoCuenta(
      String email, String codigo) async {
    try {
      final response =
          await dio.post('${AppConfig.baseurl}verificaCodigoCuenta', data: {
        'email': email,
        'codigo': codigo,
      });
      print(response.data);
      return VerificarCodigoResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al verificar codigo");
    }
  }
}
