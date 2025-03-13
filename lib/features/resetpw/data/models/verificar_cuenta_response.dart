import 'dart:convert';

import '../../domain/entities/cuenta_rec_entity.dart';

class VerificarCodigoResponse extends CuentaRecEntity {
  final int estado;
  final String message;
  final String telefono;

  VerificarCodigoResponse(
      {required this.estado, required this.message, required this.telefono})
      : super(estado: estado, message: message, telefono: telefono);

  factory VerificarCodigoResponse.fromJson(Map<String, dynamic> json) {
    return VerificarCodigoResponse(
      estado: json['estado'],
      message: json['message'],
      telefono: json['telefono'],
    );
  }

  // Convertir AuthModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
      'message': message,
      'telefono': telefono,
    };
  }

  // Crear un modelo desde una cadena JSON
  static VerificarCodigoResponse fromRawJson(String str) =>
      VerificarCodigoResponse.fromJson(json.decode(str));

  // Convertir modelo a cadena JSON
  String toRawJson() => json.encode(toJson());
}
