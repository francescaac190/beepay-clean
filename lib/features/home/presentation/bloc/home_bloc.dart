// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/usecases/first_login_usecase.dart';
// import '../../domain/usecases/makeapicall_usecase.dart';
// import '../../domain/usecases/post_factura_usecase.dart';

// abstract class HomeEvent {}

// class FirstLoginEvent extends HomeEvent {}

// class ShowFirstLoginDialogsEvent extends HomeEvent {}

// class PostFacturaEvent extends HomeEvent {
//   final String nit;
//   final String razonSocial;
//   PostFacturaEvent(this.nit, this.razonSocial);
// }

// abstract class HomeState {}

// class HomeInitial extends HomeState {}

// class HomeLoading extends HomeState {}

// class FirstLoginSuccess extends HomeState {}

// class PostFacturaSuccess extends HomeState {
//   final String message;
//   PostFacturaSuccess(this.message);
// }

// class HomeError extends HomeState {
//   final String message;
//   HomeError(this.message);
// }

// class HomeBloc extends Bloc<HomeEvent, HomeState> {
//   final FirstLoginUseCase firstLoginUseCase;
//   final MakeApiCallUseCase makeApiCallUseCase;
//   final PostFacturaUseCase postFacturaUseCase;
//   final RazonSocialUseCase razonSocialUseCase;
//   final ActivarBiometricoUseCase activarBiometricoUseCase;

//   HomeBloc({
//     required this.firstLoginUseCase,
//     required this.makeApiCallUseCase,
//     required this.postFacturaUseCase,
//     required this.razonSocialUseCase,
//     required this.activarBiometricoUseCase,
//   }) : super(HomeInitial()) {
//     on<FirstLoginEvent>(_handleFirstLogin);
//     on<ShowFirstLoginDialogsEvent>(_showDialogs);
//     on<PostFacturaEvent>(_handlePostFactura);
//   }

//   Future<void> _handleFirstLogin(
//       FirstLoginEvent event, Emitter<HomeState> emit) async {
//     emit(HomeLoading());
//     final result = await firstLoginUseCase.call();
//     if (result) {
//       emit(FirstLoginSuccess());
//     } else {
//       emit(HomeError("Error en FirstLogin"));
//     }
//   }

//   Future<void> _showDialogs(
//       ShowFirstLoginDialogsEvent event, Emitter<HomeState> emit) async {
//     await makeApiCallUseCase.call();
//     await razonSocialUseCase.call();
//     await activarBiometricoUseCase.call();
//   }

//   Future<void> _handlePostFactura(
//       PostFacturaEvent event, Emitter<HomeState> emit) async {
//     emit(HomeLoading());
//     final result = await postFacturaUseCase.call(event.nit, event.razonSocial);
//     if (result != null) {
//       emit(PostFacturaSuccess(result));
//     } else {
//       emit(HomeError("Error al agregar factura"));
//     }
//   }
// }
