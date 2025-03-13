import 'package:beepay/core/config/app_config.dart';
import 'package:beepay/features/register/data/models/checkuser_response.dart';
import 'package:dio/dio.dart';
import '../models/otp_response.dart';
import '../models/verify_otp_response.dart';
import '../models/register_response.dart';

abstract class RegisterRemoteDataSource {
  Future<CheckUserResponse> checkUser(
      String email, String phone, String ci, String codigo);
  Future<OtpResponse> sendOtp(String email);
  Future<VerifyOtpResponse> verifyOtp(String email, String otp);
  Future<RegisterResponse> registerUser(Map<String, dynamic> userData);
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  final Dio dio;

  RegisterRemoteDataSourceImpl({required this.dio});

  @override
  Future<CheckUserResponse> checkUser(
      String email, String phone, String ci, String codigo) async {
    try {
      final response = await dio.post('${AppConfig.baseurl}checkUserExists',
          data: {'email': email, 'cel': phone, 'ci': ci, 'codigo': codigo});
      print(response.data);
      return CheckUserResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al verificar usuario");
    }
  }

  @override
  Future<OtpResponse> sendOtp(String email) async {
    try {
      final response = await dio.post('${AppConfig.baseurl}otp_correo', data: {
        'email': email,
      });
      print(response.data);

      return OtpResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al enviar OTP");
    }
  }

  @override
  Future<VerifyOtpResponse> verifyOtp(String email, String otp) async {
    try {
      final response =
          await dio.post('${AppConfig.baseurl}verifica_codigo_correo', data: {
        'email': email,
        'codigo': otp,
      });

      print(response.data);
      return VerifyOtpResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Código incorrecto");
    }
  }

  @override
  Future<RegisterResponse> registerUser(Map<String, dynamic> userData) async {
    try {
      final response =
          await dio.post('${AppConfig.baseurl}register', data: userData);
      print(response.data);
      return RegisterResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al registrar usuario");
    }
  }
}
