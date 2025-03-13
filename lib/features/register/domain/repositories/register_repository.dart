import 'package:beepay/features/register/domain/entities/checkuser_entity.dart';
import 'package:beepay/features/register/domain/entities/otp_entity.dart';
import 'package:beepay/features/register/domain/entities/register_entity.dart';
import 'package:beepay/features/register/domain/entities/verify_otp_entity.dart';

abstract class RegisterRepository {
  Future<CheckUserEntity> checkUser(
      String email, String phone, String ci, String codigo);
  Future<OtpEntity> sendOtp(String email);
  Future<VerifyOtpEntity> verifyOtp(String email, String otp);
  Future<RegisterEntity> registerUser(Map<String, dynamic> userData);
}
