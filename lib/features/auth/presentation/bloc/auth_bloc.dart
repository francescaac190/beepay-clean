// lib/features/auth/presentation/bloc/auth_bloc.dart
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

  String _ts() => DateTime.now().toIso8601String();
  void _log(String tag, String msg) => print('[AUTH-BLOC][$tag][${_ts()}] $msg');

  AuthBloc(this.loginUseCase, this.loginBiometricUseCase) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      _log('EVENT', 'LoginEvent cel=${event.cel} passLen=${event.password.length}');
      emit(AuthLoading());
      _log('STATE', '→ AuthLoading');
      try {
        final auth = await loginUseCase.call(event.cel, event.password);
        _log('OK', 'UseCase login completado tokenLen=${auth.token?.length ?? 0} msg="${auth.mensaje}"');
        emit(AuthAuthenticated(auth.token!, auth.mensaje));
        _log('STATE', '→ AuthAuthenticated');
      } catch (e) {
        final msg = e.toString().replaceAll("Exception:", "").trim();
        _log('ERR', 'Login falló: $msg');
        emit(AuthError(msg));
        _log('STATE', '→ AuthError("$msg")');
      }
    });

    on<LoginBiometricEvent>((event, emit) async {
      _log('EVENT', 'LoginBiometricEvent deviceIdLen=${event.deviceId.length}');
      emit(AuthLoading());
      _log('STATE', '→ AuthLoading');
      try {
        final auth = await loginBiometricUseCase.call(event.deviceId);
        _log('OK', 'UseCase biométrico completado tokenLen=${auth.token?.length ?? 0} msg="${auth.mensaje}"');
        emit(AuthAuthenticated(auth.token!, auth.mensaje));
        _log('STATE', '→ AuthAuthenticated');
      } catch (e) {
        final msg = e.toString().replaceAll("Exception:", "").trim();
        _log('ERR', 'Biométrico falló: $msg');
        emit(AuthError(msg));
        _log('STATE', '→ AuthError("$msg")');
      }
    });
  }
}
