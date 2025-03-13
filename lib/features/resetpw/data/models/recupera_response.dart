import 'dart:convert';

import '../../domain/entities/recupera_entity.dart';

class RecuperaResponse extends RecuperaEntity {
  final int estado;
  final String message;
  final String token;

  RecuperaResponse(
      {required this.estado, required this.message, required this.token})
      : super(estado: estado, message: message, token: token);

  factory RecuperaResponse.fromJson(Map<String, dynamic> json) {
    return RecuperaResponse(
      estado: json['estado'],
      message: json['message'],
      token: json['token'],
    );
  }

  // Convertir AuthModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
      'message': message,
      'token': token,
    };
  }

  // Crear un modelo desde una cadena JSON
  static RecuperaResponse fromRawJson(String str) =>
      RecuperaResponse.fromJson(json.decode(str));

  // Convertir modelo a cadena JSON
  String toRawJson() => json.encode(toJson());
}
