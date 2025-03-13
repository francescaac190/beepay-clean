import 'package:beepay/core/config/app_config.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/secure_storage_service.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String cel, String password);
  Future<AuthModel> loginBiometric(String deviceId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthModel> login(String cel, String password) async {
    try {
      final requestData = {
        'cel': cel,
        'password': password,
      };

      print("📤 Request Login Data: $requestData");

      final response = await dio.post(
        '${AppConfig.baseurl}login',
        data: requestData,
      );

      print("🔹 Headers: ${response.requestOptions.headers}");
      print("🔹 Login Response Status: ${response.statusCode}");
      print("🔹 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final AuthModel auth = AuthModel.fromJson(response.data);

        // ✅ Guardar nuevo token
        await SecureStorageService.instance.saveToken(auth.token);
        print("✅ Token actualizado: ${auth.token}");

        return AuthModel.fromJson(response.data);
      } else {
        throw Exception('Error desconocido');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Error en login');
      } else {
        throw Exception("Error de conexión con el servidor");
      }
    }
  }

  @override
  Future<AuthModel> loginBiometric(String deviceId) async {
    try {
      final response =
          await dio.post('${AppConfig.baseurl}loginBiometrico', data: {
        'device_id': deviceId,
      });

      print("Biometric Login Response: ${response.statusCode}");
      print("Data: ${response.data}");

      if (response.statusCode == 200) {
        return AuthModel.fromJson(response.data);
      } else {
        throw Exception('Error en login biométrico');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response!.data['message'] ?? 'Error en login biométrico');
      } else {
        throw Exception("Error de conexión con el servidor");
      }
    }
  }
}
