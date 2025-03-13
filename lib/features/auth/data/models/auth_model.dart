import 'dart:convert';

import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  final int estado;
  final String mensaje;
  final String token;

  AuthModel({
    required this.estado,
    required this.mensaje,
    required this.token,
  }) : super(estado: estado, mensaje: mensaje, token: token);

  // Convertir JSON a AuthModel
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      estado: json['estado'],
      mensaje: json['message'],
      token: json['token'],
    );
  }

  // Convertir AuthModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
      'message': mensaje,
      'token': token,
    };
  }

  // Crear un modelo desde una cadena JSON
  static AuthModel fromRawJson(String str) =>
      AuthModel.fromJson(json.decode(str));

  // Convertir modelo a cadena JSON
  String toRawJson() => json.encode(toJson());
}
