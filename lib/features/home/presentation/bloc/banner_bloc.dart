// 📌 Eventos del Bloc
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/banner_entity.dart';
import '../../domain/usecases/banner_usecase.dart';

abstract class BannerEvent {}

class GetBannersEvent extends BannerEvent {}

// 📌 Estados del Bloc
abstract class BannerState {}

class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {}

class BannerLoaded extends BannerState {
  final List<BannerEntity> banners;
  BannerLoaded(this.banners);
}

class BannerError extends BannerState {
  final String message;
  BannerError(this.message);
}

// 📌 Bloc
class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final GetBannersUseCase getBannersUseCase;

  BannerBloc(this.getBannersUseCase) : super(BannerInitial()) {
    on<GetBannersEvent>((event, emit) async {
      emit(BannerLoading());
      try {
        final banners = await getBannersUseCase.call();
        emit(BannerLoaded(banners));
      } catch (e) {
        emit(BannerError("Error al obtener banners"));
      }
    });
  }
}
