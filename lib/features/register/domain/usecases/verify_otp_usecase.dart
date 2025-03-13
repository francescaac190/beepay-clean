import 'package:beepay/features/register/domain/entities/verify_otp_entity.dart';

import '../repositories/register_repository.dart';

class VerifyOtpUseCase {
  final RegisterRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<VerifyOtpEntity> call(String email, String otp) {
    return repository.verifyOtp(email, otp);
  }
}
