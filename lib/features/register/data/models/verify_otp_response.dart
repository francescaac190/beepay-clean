import 'dart:convert';

import 'package:beepay/features/register/domain/entities/verify_otp_entity.dart';

class VerifyOtpResponse extends VerifyOtpEntity {
  final int estado;
  final String message;

  VerifyOtpResponse({required this.estado, required this.message})
      : super(estado: 0, message: '');

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
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
  static VerifyOtpResponse fromRawJson(String str) =>
      VerifyOtpResponse.fromJson(json.decode(str));

  // Convertir modelo a cadena JSON
  String toRawJson() => json.encode(toJson());
}
