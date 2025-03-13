import 'dart:convert';

import '../../domain/entities/actualiza_pass_entity.dart';

class ActualizaPassResponse extends ActualizaPassEntity {
  final int estado;
  final String message;

  ActualizaPassResponse({required this.estado, required this.message})
      : super(estado: estado, message: message);

  factory ActualizaPassResponse.fromJson(Map<String, dynamic> json) {
    return ActualizaPassResponse(
      estado: json['estado'],
      message: json['message'],
    );
  }

  // Convertir AuthModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
      'message': message,
    };
  }

  // Crear un modelo desde una cadena JSON
  static ActualizaPassResponse fromRawJson(String str) =>
      ActualizaPassResponse.fromJson(json.decode(str));

  // Convertir modelo a cadena JSON
  String toRawJson() => json.encode(toJson());
}
