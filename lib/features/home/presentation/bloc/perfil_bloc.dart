import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/perfil_usecase.dart';
import '../../domain/entities/perfil_entity.dart';
import '../../../../core/services/filesystem_manager.dart';

abstract class PerfilState {}

class PerfilInitial extends PerfilState {}

class PerfilLoading extends PerfilState {}

class PerfilLoaded extends PerfilState {
  final Perfil perfil;
  PerfilLoaded(this.perfil);
}

class PerfilError extends PerfilState {
  final String message;
  PerfilError(this.message);
}

class PerfilEvent {}

class GetPerfilEvent extends PerfilEvent {}

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  final GetCompletoUseCase getCompletoUseCase;

  PerfilBloc(this.getCompletoUseCase) : super(PerfilInitial()) {
    on<GetPerfilEvent>((event, emit) async {
      emit(PerfilLoading());
      try {
        final perfil = await getCompletoUseCase.call();

        // ✅ guarda los datos para toda la app
        FileSystemManager.instance.setPerfil(perfil);

        emit(PerfilLoaded(perfil));
      } catch (e) {
        emit(PerfilError("Error al obtener perfil"));
      }
    });
  }
}