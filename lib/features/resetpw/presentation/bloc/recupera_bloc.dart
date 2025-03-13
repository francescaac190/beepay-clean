import 'package:beepay/features/resetpw/domain/usecases/actualiza_pass_usecase.dart';
import 'package:beepay/features/resetpw/domain/usecases/cuenta_rec_usecase.dart';
import 'package:beepay/features/resetpw/domain/usecases/recupera_cuenta_usecase.dart';
import 'package:beepay/features/resetpw/domain/usecases/recupera_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecuperaState {}

class RecuperaInitial extends RecuperaState {}

class RecuperaLoading extends RecuperaState {}

class Recupera extends RecuperaState {
  final String message;
  final String token;
  Recupera(this.message, this.token);
}

class ActualizaPass extends RecuperaState {
  final String message;
  ActualizaPass(this.message);
}

class RecuperaCuenta extends RecuperaState {
  final String message;
  final String codigo;
  RecuperaCuenta(this.message, this.codigo);
}

class VerificaCod extends RecuperaState {
  final String message;
  final String telefono;
  VerificaCod(this.message, this.telefono);
}

class RecuperaError extends RecuperaState {
  final String message;
  RecuperaError(this.message);
}

abstract class RecuperaEvent {}

class RecuperaaEvent extends RecuperaEvent {
  final String email;
  RecuperaaEvent(this.email);
}

class ActualizaPassEvent extends RecuperaEvent {
  final String email;
  final String verificacion;
  final String password;
  final String passwordConfirmation;
  ActualizaPassEvent(
      this.email, this.verificacion, this.password, this.passwordConfirmation);
}

class RecuperaCuentaEvent extends RecuperaEvent {
  final String email;
  RecuperaCuentaEvent(this.email);
}

class VerificaCodEvent extends RecuperaEvent {
  final String email;
  final String codigo;
  VerificaCodEvent(this.email, this.codigo);
}

class RecuperaBloc extends Bloc<RecuperaEvent, RecuperaState> {
  final RecuperaUsecase recuperaUseCase;
  final ActualizaPassUsecase actualizaPassUseCase;
  final RecuperaCuentaUsecase recuperaCuentaUseCase;
  final CuentaRecUseCase verificaUseCase;

  RecuperaBloc(this.recuperaUseCase, this.actualizaPassUseCase,
      this.recuperaCuentaUseCase, this.verificaUseCase)
      : super(RecuperaInitial()) {
    on<RecuperaaEvent>(_onRecupera);
    on<ActualizaPassEvent>(_onActualizaPass);
    on<RecuperaCuentaEvent>(_onRecuperaCuenta);
    on<VerificaCodEvent>(_onVerificaCod);
  }

  Future<void> _onRecupera(
      RecuperaaEvent event, Emitter<RecuperaState> emit) async {
    emit(RecuperaLoading());
    try {
      final result = await recuperaUseCase.call(event.email);
      if (result.estado == 100) {
        emit(Recupera(
            result.message, result.token)); // ✅ Código enviado correctamente
      } else {
        emit(RecuperaError(result.message)); // ❌ Error al enviar código
      }
    } catch (e) {
      emit(RecuperaError("Error al enviar código de verificación"));
    }
  }

  Future<void> _onRecuperaCuenta(
      RecuperaCuentaEvent event, Emitter<RecuperaState> emit) async {
    emit(RecuperaLoading());
    try {
      final result = await recuperaCuentaUseCase.call(event.email);

      if (result.estado == 100) {
        emit(RecuperaCuenta(
            result.message, result.codigo)); // ✅ OTP enviado correctamente
      } else {
        emit(RecuperaError(result.message)); // ❌ Error en el envío del OTP
      }
    } catch (e) {
      emit(RecuperaError("Error al enviar código de verificación"));
    }
  }

  Future<void> _onVerificaCod(
      VerificaCodEvent event, Emitter<RecuperaState> emit) async {
    emit(RecuperaLoading());
    try {
      final result = await verificaUseCase.call(event.email, event.codigo);
      print(result.estado);
      if (result.estado == 200) {
        emit(VerificaCod(
            result.message, result.telefono)); // ✅ Código OTP correcto
      } else {
        emit(RecuperaError(result.message)); // ❌ Código OTP incorrecto
      }
    } catch (e) {
      emit(RecuperaError("Error al verificar OTP"));
    }
  }

  Future<void> _onActualizaPass(
      ActualizaPassEvent event, Emitter<RecuperaState> emit) async {
    emit(RecuperaLoading());
    try {
      final result = await actualizaPassUseCase.call(event.email,
          event.verificacion, event.password, event.passwordConfirmation);

      if (result.estado == 100) {
        emit(ActualizaPass(result.message)); // ✅ Registro exitoso
      } else {
        emit(RecuperaError(result.message)); // ❌ Error en el registro
      }
    } catch (e) {
      emit(RecuperaError("Error al cambiar contraseña"));
    }
  }
}
