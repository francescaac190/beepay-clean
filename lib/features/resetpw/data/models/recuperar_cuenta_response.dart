import 'dart:convert';

import '../../domain/entities/recupera_cuenta_entity.dart';

class RecuperaCuentaResponse extends RecuperaCuentaEntity {
  final int estado;
  final String message;
  final String codigo;

  RecuperaCuentaResponse(
      {required this.estado, required this.message, required this.codigo})
      : super(estado: estado, message: message, codigo: codigo);

  factory RecuperaCuentaResponse.fromJson(Map<String, dynamic> json) {
    return RecuperaCuentaResponse(
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
  static RecuperaCuentaResponse fromRawJson(String str) =>
      RecuperaCuentaResponse.fromJson(json.decode(str));

  // Convertir modelo a cadena JSON
  String toRawJson() => json.encode(toJson());
}
