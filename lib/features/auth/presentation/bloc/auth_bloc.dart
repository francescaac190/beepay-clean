import 'package:beepay/features/auth/domain/usecases/login_biometric_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final String message;

  AuthAuthenticated(this.token, this.message);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String cel;
  final String password;

  LoginEvent(this.cel, this.password);
}

class LoginBiometricEvent extends AuthEvent {
  final String deviceId;

  LoginBiometricEvent(this.deviceId);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LoginBiometricUseCase loginBiometricUseCase;

  AuthBloc(this.loginUseCase, this.loginBiometricUseCase)
      : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final auth = await loginUseCase.call(event.cel, event.password);
        emit(AuthAuthenticated(auth.token!, auth.mensaje));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll("Exception:", "").trim()));
      }
    });

    on<LoginBiometricEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final auth = await loginBiometricUseCase.call(event.deviceId);
        emit(AuthAuthenticated(auth.token!, auth.mensaje));
      } catch (e) {
        emit(AuthError(e.toString().replaceAll("Exception:", "").trim()));
      }
    });
  }
//   Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
//   await SecureStorageService.instance.deleteToken(); // Elimina el token
//   emit(AuthUnauthenticated());
// }
}
