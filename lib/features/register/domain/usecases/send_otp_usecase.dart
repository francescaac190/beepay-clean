import 'package:beepay/features/register/domain/entities/otp_entity.dart';

import '../repositories/register_repository.dart';

class SendOtpUseCase {
  final RegisterRepository repository;

  SendOtpUseCase(this.repository);

  Future<OtpEntity> call(String email) {
    return repository.sendOtp(email);
  }
}
