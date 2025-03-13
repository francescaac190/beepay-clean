import 'dart:convert';

import '../../domain/entities/checkuser_entity.dart';

class CheckUserResponse extends CheckUserEntity {
  final String message;

  CheckUserResponse({required this.message}) : super(message: message);

  factory CheckUserResponse.fromJson(Map<String, dynamic> json) {
    return CheckUserResponse(
      message: json['message'],
    );
  }

  // Convertir AuthModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  // Crear un modelo desde una cadena JSON
  static CheckUserResponse fromRawJson(String str) =>
      CheckUserResponse.fromJson(json.decode(str));

  // Convertir modelo a cadena JSON
  String toRawJson() => json.encode(toJson());
}
