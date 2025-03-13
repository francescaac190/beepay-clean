import 'dart:convert';

import 'package:beepay/features/register/domain/entities/otp_entity.dart';

class OtpResponse extends OtpEntity {
  final int estado;
  final String message;
  final String codigo;

  OtpResponse(
      {required this.estado, required this.message, required this.codigo})
      : super(estado: estado, message: message, codigo: codigo);

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      estado: json['estado'],
      message: json['message'],
      codigo: json['codigo'],
    );
  }

  // Convertir AuthModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
      'message': message,
      'codigo': codigo,
    };
  }

  // Crear un modelo desde una cadena JSON
  static OtpResponse fromRawJson(String str) =>
      OtpResponse.fromJson(json.decode(str));

  // Convertir modelo a cadena JSON
  String toRawJson() => json.encode(toJson());
}
