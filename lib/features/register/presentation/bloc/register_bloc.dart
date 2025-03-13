import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_user_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterUserChecked extends RegisterState {
  final String message;
  RegisterUserChecked(this.message);
}

class RegisterOtpSent extends RegisterState {
  final String codigo;
  RegisterOtpSent(this.codigo);
}

class RegisterOtpVerified extends RegisterState {
  final String message;
  RegisterOtpVerified(this.message);
}

class RegisterCompleted extends RegisterState {
  final String message;
  RegisterCompleted(this.message);
}

class RegisterError extends RegisterState {
  final String message;
  RegisterError(this.message);
}

abstract class RegisterEvent {}

class CheckUserEvent extends RegisterEvent {
  final String email, phone, ci, codigo;
  CheckUserEvent(this.email, this.phone, this.ci, this.codigo);
}

class SendOtpEvent extends RegisterEvent {
  final String email;
  SendOtpEvent(this.email);
}

class VerifyOtpEvent extends RegisterEvent {
  final String email, otp;
  VerifyOtpEvent(this.email, this.otp);
}

class RegisterUserEvent extends RegisterEvent {
  final Map<String, dynamic> userData;
  RegisterUserEvent(this.userData);
}

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final CheckUserUseCase checkUserUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final RegisterUserUseCase registerUserUseCase;

  RegisterBloc(this.checkUserUseCase, this.sendOtpUseCase,
      this.verifyOtpUseCase, this.registerUserUseCase)
      : super(RegisterInitial()) {
    on<CheckUserEvent>(_onCheckUser);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterUserEvent>(_onRegisterUser);
  }

  Future<void> _onCheckUser(
      CheckUserEvent event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    try {
      final result = await checkUserUseCase.call(
          event.email, event.phone, event.ci, event.codigo);
      if (result.message == "¡Correcto!") {
        emit(RegisterUserChecked(
            result.message)); // ✅ Usuario puede registrarse, enviar OTP
      } else {
        emit(RegisterError(result.message)); // ❌ Mostrar mensaje de error
      }
    } catch (e) {
      emit(RegisterError("Error al verificar usuario"));
    }
  }

  Future<void> _onSendOtp(
      SendOtpEvent event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    try {
      final result = await sendOtpUseCase.call(event.email);
      if (result.estado == 100) {
        emit(RegisterOtpSent(result.codigo)); // ✅ OTP enviado correctamente
      } else {
        emit(RegisterError(result.message)); // ❌ Error en el envío del OTP
      }
    } catch (e) {
      emit(RegisterError("Error al enviar OTP"));
    }
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    try {
      final result = await verifyOtpUseCase.call(event.email, event.otp);
      if (result.estado == 200) {
        emit(RegisterOtpVerified(result.message)); // ✅ Código OTP correcto
      } else {
        emit(RegisterError(result.message)); // ❌ Código OTP incorrecto
      }
    } catch (e) {
      emit(RegisterError("Error al verificar OTP"));
    }
  }

  Future<void> _onRegisterUser(
      RegisterUserEvent event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    try {
      final result = await registerUserUseCase.call(event.userData);

      if (result.estado == 100) {
        emit(RegisterCompleted(result.message)); // ✅ Registro exitoso
      } else {
        emit(RegisterError(result.message)); // ❌ Error en el registro
      }
    } catch (e) {
      emit(RegisterError("Error al registrar usuario"));
    }
  }
}
