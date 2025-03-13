import 'dart:convert';

import 'package:beepay/features/register/domain/entities/register_entity.dart';

class RegisterResponse extends RegisterEntity {
  final int estado;
  final String message;

  RegisterResponse({required this.estado, required this.message})
      : super(estado: 0, message: '');

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
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
  static RegisterResponse fromRawJson(String str) =>
      RegisterResponse.fromJson(json.decode(str));

  // Convertir modelo a cadena JSON
  String toRawJson() => json.encode(toJson());
}
