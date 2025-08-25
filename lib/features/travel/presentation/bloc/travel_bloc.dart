// lib/features/travel/presentation/bloc/travel_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/airport.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/search_request.dart';
import '../../domain/repositories/travel_repository.dart';
import 'travel_event.dart';
import 'travel_state.dart';

class TravelBloc extends Bloc<TravelEvent, TravelState> {
  final TravelRepository repo;
  final String baseUrl;
  final String token;

  TravelBloc({
    required this.repo,
    required this.baseUrl,
    required this.token,
  }) : super(const TravelState(loading: true)) {
    on<TravelLoadAirports>(_onLoadAirports);

    on<TravelSelectOrigin>((e, emit) {
      emit(state.copyWith(
        origin: e.origin,
        clearOrigin: e.origin == null,
      ));
    });

    on<TravelSelectDestination>((e, emit) {
      emit(state.copyWith(
        destination: e.destination,
        clearDestination: e.destination == null,
      ));
    });

    on<TravelSwapAirports>(_onSwap);
    on<TravelSelectTripType>(_onTripType);
    on<TravelPickOneDate>((e, emit) => emit(state.copyWith(oneWayDate: e.date, clearRange: true)));
    on<TravelPickRange>((e, emit) => emit(state.copyWith(rangeStart: e.start, rangeEnd: e.end, clearOneWay: true)));
    on<TravelSetPassengers>((e, emit) => emit(state.copyWith(adults: e.adults, kids: e.kids, babies: e.babies)));
    on<TravelSubmit>(_onSubmit);

    on<TravelSearchFlights>(_onSearchFlights);
    on<TravelChangeSort>(_onChangeSort);
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
    emit(state.copyWith(
      origin: state.destination,
      destination: state.origin,
    ));
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

  Future<void> _onSearchFlights(TravelSearchFlights e, Emitter<TravelState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(resultsError: 'Faltan datos para buscar', resultsLoading: false));
      return;
    }

    emit(state.copyWith(resultsLoading: true, resultsError: null));

    try {
      final req = SearchRequest(
        originIata: state.origin!.iata,
        destinationIata: state.destination!.iata,
        tripType: state.tripType,
        oneWayDate: state.oneWayDate,
        rangeStart: state.rangeStart,
        rangeEnd: state.rangeEnd,
        adults: state.adults,
        kids: state.kids,
        babies: state.babies,
      );

      final list = await repo.searchFlights(
        baseUrl: baseUrl,
        token: token,
        request: req,
      );

      final sorted = _sort(list, state.sort);
      emit(state.copyWith(resultsLoading: false, flights: sorted, resultsError: null));
    } catch (_) {
      emit(state.copyWith(resultsLoading: false, resultsError: 'Error al obtener vuelos'));
    }
  }

  void _onChangeSort(TravelChangeSort e, Emitter<TravelState> emit) {
    final sorted = _sort(state.flights, e.sort);
    emit(state.copyWith(sort: e.sort, flights: sorted));
  }

  List<Flight> _sort(List<Flight> list, TravelSort s) {
    final flights = List<Flight>.from(list);
    switch (s) {
      case TravelSort.priceAsc:
        flights.sort((a, b) => _toDouble(a.totalAmount).compareTo(_toDouble(b.totalAmount)));
        break;
      case TravelSort.cashbackDesc:
        flights.sort((a, b) => _toDouble(b.puntos).compareTo(_toDouble(a.puntos)));
        break;
      case TravelSort.departureEarly:
        DateTime parseDT(Flight f) {
          final d = f.ida.first.departureDate; // yyyy-MM-dd
          final t = f.ida.first.departureTime; // HH:mm
          // Intentos de parseo tolerantes
          return DateTime.tryParse('$d $t') ??
              DateTime.tryParse('${f.ida.first.departureDate}T${f.ida.first.departureTime}:00') ??
              DateTime.fromMillisecondsSinceEpoch(0);
        }
        flights.sort((a, b) => parseDT(a).compareTo(parseDT(b)));
        break;
    }
    return flights;
  }

  double _toDouble(String v) {
    final clean = v.replaceAll(RegExp(r'[^0-9\.\,]'), '').replaceAll(',', '.');
    return double.tryParse(clean) ?? double.infinity;
    // Nota: si quisieras precio no disponible al final, infinity está bien.
  }
}
