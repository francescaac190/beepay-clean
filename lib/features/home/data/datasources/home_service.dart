import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/secure_storage_service.dart';

class HomeService {
  final Dio dio;

  HomeService(this.dio);
  Future<bool> firstLogin() async {
    try {
      final response = await dio.get(
        '${AppConfig.baseurl}first_login',
        options: Options(headers: _headers()),
      );
      print(response.data);

      final jsonData = response.data;

      if (jsonData['estado'] == 100) {
        return true; // ✅ Es el primer login
      } else {
        return false; // ✅ No es el primer login
      }
    } catch (e) {
      return false; // ✅ Manejo de excepción
    }
  }

  Future<String> getPinBeePay() async {
    try {
      final response = await dio.get(
        '${AppConfig.baseurl}get_pin_beepay',
        options: Options(headers: _headers()),
      );
      print(response.data);
      return response.data['data'];
    } catch (e) {
      throw Exception('Error obteniendo PinBeePay');
    }
  }

  Future<void> postAgregarFactura(String nit, String razonSocial) async {
    try {
      final response = await dio.post(
        '${AppConfig.baseurl}post_user_factura',
        options: Options(headers: _headers()),
        data: jsonEncode({"nit": nit, "razon_social": razonSocial}),
      );
      print(response.data);
    } catch (e) {
      throw Exception('Error al agregar factura');
    }
  }

  Map<String, String> _headers() {
    final token = SecureStorageService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
