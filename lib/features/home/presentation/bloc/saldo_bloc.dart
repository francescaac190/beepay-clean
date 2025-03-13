import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/saldo_entity.dart';
import '../../domain/usecases/saldo_usecase.dart';

abstract class SaldoState {}

class SaldoInitial extends SaldoState {}

class SaldoLoading extends SaldoState {}

class SaldoLoaded extends SaldoState {
  final SaldoEntity saldo;
  SaldoLoaded(this.saldo);
}

class SaldoError extends SaldoState {
  final String message;
  SaldoError(this.message);
}

abstract class SaldoEvent {}

class GetSaldoEvent extends SaldoEvent {}

class SaldoBloc extends Bloc<SaldoEvent, SaldoState> {
  final GetSaldoUseCase getSaldoUseCase;

  SaldoBloc(this.getSaldoUseCase) : super(SaldoInitial()) {
    on<GetSaldoEvent>((event, emit) async {
      emit(SaldoLoading());
      try {
        final saldo = await getSaldoUseCase.call();
        emit(SaldoLoaded(saldo));
      } catch (e) {
        emit(SaldoError("Error al obtener saldo"));
      }
    });
  }
}
