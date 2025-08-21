import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../travel/domain/entities/airport.dart';
import '../../../travel/domain/repositories/travel_repository.dart';

// --------- EVENTS ----------
abstract class TravelEvent {}

class TravelLoadAirports extends TravelEvent {}
class TravelSelectOrigin extends TravelEvent { final Airport? origin; TravelSelectOrigin(this.origin); }
class TravelSelectDestination extends TravelEvent { final Airport? destination; TravelSelectDestination(this.destination); }
class TravelSwapAirports extends TravelEvent {}
class TravelSelectTripType extends TravelEvent { final String type; TravelSelectTripType(this.type); } // 'OW' | 'RT'
class TravelPickOneDate extends TravelEvent { final DateTime date; TravelPickOneDate(this.date); }
class TravelPickRange extends TravelEvent { final DateTime start; final DateTime end; TravelPickRange(this.start, this.end); }
class TravelSetPassengers extends TravelEvent { final int adults; final int kids; final int babies; TravelSetPassengers(this.adults, this.kids, this.babies); }
class TravelSubmit extends TravelEvent {}

// --------- STATE ----------
class TravelState {
  final bool loading;
  final List<Airport> airports;
  final Airport? origin;
  final Airport? destination;
  final String tripType; // 'OW' | 'RT'
  final DateTime? oneWayDate;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final int adults;
  final int kids;
  final int babies;
  final String? error;

  bool get isValid {
    if (origin == null || destination == null) return false;
    if (tripType == 'OW') return oneWayDate != null;
    return rangeStart != null && rangeEnd != null;
  }

  const TravelState({
    this.loading = false,
    this.airports = const [],
    this.origin,
    this.destination,
    this.tripType = 'RT',
    this.oneWayDate,
    this.rangeStart,
    this.rangeEnd,
    this.adults = 1,
    this.kids = 0,
    this.babies = 0,
    this.error,
  });

  TravelState copyWith({
    bool? loading,
    List<Airport>? airports,
    Airport? origin,
    Airport? destination,
    String? tripType,
    DateTime? oneWayDate,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    int? adults,
    int? kids,
    int? babies,
    String? error,
    bool clearOneWay = false,
    bool clearRange = false,
  }) {
    return TravelState(
      loading: loading ?? this.loading,
      airports: airports ?? this.airports,
      origin: origin,
      destination: destination,
      tripType: tripType ?? this.tripType,
      oneWayDate: clearOneWay ? null : (oneWayDate ?? this.oneWayDate),
      rangeStart: clearRange ? null : (rangeStart ?? this.rangeStart),
      rangeEnd: clearRange ? null : (rangeEnd ?? this.rangeEnd),
      adults: adults ?? this.adults,
      kids: kids ?? this.kids,
      babies: babies ?? this.babies,
      error: error,
    );
  }
}

// --------- BLOC ----------
class TravelBloc extends Bloc<TravelEvent, TravelState> {
  final TravelRepository repo;
  final String baseUrl;
  final String token;

  TravelBloc({required this.repo, required this.baseUrl, required this.token})
      : super(const TravelState(loading: true)) {
    on<TravelLoadAirports>(_onLoadAirports);
    on<TravelSelectOrigin>((e, emit) => emit(state.copyWith(origin: e.origin)));
    on<TravelSelectDestination>((e, emit) => emit(state.copyWith(destination: e.destination)));
    on<TravelSwapAirports>(_onSwap);
    on<TravelSelectTripType>(_onTripType);
    on<TravelPickOneDate>((e, emit) => emit(state.copyWith(oneWayDate: e.date, clearRange: true)));
    on<TravelPickRange>((e, emit) => emit(state.copyWith(rangeStart: e.start, rangeEnd: e.end, clearOneWay: true)));
    on<TravelSetPassengers>((e, emit) => emit(state.copyWith(adults: e.adults, kids: e.kids, babies: e.babies)));
    on<TravelSubmit>(_onSubmit);
  }

  Future<void> _onLoadAirports(TravelLoadAirports e, Emitter<TravelState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await repo.getAirports(baseUrl: baseUrl, token: token);
      emit(state.copyWith(loading: false, airports: list));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'No se pudieron cargar aeropuertos'));
    }
  }

  void _onSwap(TravelSwapAirports e, Emitter<TravelState> emit) {
    emit(state.copyWith(origin: state.destination, destination: state.origin));
  }

  void _onTripType(TravelSelectTripType e, Emitter<TravelState> emit) {
    if (e.type == 'OW') {
      emit(state.copyWith(tripType: 'OW', clearRange: true));
    } else {
      emit(state.copyWith(tripType: 'RT', clearOneWay: true));
    }
  }

  void _onSubmit(TravelSubmit e, Emitter<TravelState> emit) {
    if (!state.isValid) {
      emit(state.copyWith(error: 'Completa origen, destino y fechas'));
    } else {
      emit(state.copyWith(error: null));
    }
  }
}
