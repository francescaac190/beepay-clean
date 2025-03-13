import 'package:beepay/features/register/domain/entities/checkuser_entity.dart';
import 'package:beepay/features/register/domain/entities/otp_entity.dart';
import 'package:beepay/features/register/domain/entities/register_entity.dart';
import 'package:beepay/features/register/domain/entities/verify_otp_entity.dart';

import '../../domain/repositories/register_repository.dart';
import '../datasources/register_remote_data_source.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSource remoteDataSource;

  RegisterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CheckUserEntity> checkUser(
      String email, String phone, String ci, String codigo) async {
    return await remoteDataSource.checkUser(email, phone, ci, codigo);
  }

  @override
  Future<OtpEntity> sendOtp(String email) async {
    return await remoteDataSource.sendOtp(email);
  }

  @override
  Future<VerifyOtpEntity> verifyOtp(String email, String otp) async {
    return await remoteDataSource.verifyOtp(email, otp);
  }

  @override
  Future<RegisterEntity> registerUser(Map<String, dynamic> userData) async {
    return await remoteDataSource.registerUser(userData);
  }
}
