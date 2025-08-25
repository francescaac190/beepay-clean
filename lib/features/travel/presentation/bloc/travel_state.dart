// lib/features/travel/presentation/bloc/travel_state.dart
import '../../domain/entities/airport.dart';
import '../../domain/entities/flight.dart';
import 'travel_event.dart';

class TravelState {
  final bool loading;                 // carga de aeropuertos
  final List<Airport> airports;

  final Airport? origin;
  final Airport? destination;

  final String tripType;              // 'OW' | 'RT'
  final DateTime? oneWayDate;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  final int adults;
  final int kids;
  final int babies;

  final String? error;                // errores de formulario

  // ---- Resultados Vuelos ----
  final bool resultsLoading;
  final List<Flight> flights;
  final String? resultsError;
  final TravelSort sort;

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

    this.resultsLoading = false,
    this.flights = const [],
    this.resultsError,
    this.sort = TravelSort.priceAsc,
  });

  TravelState copyWith({
    bool? loading,
    List<Airport>? airports,

    // Para setear/limpiar explícitamente, usá clearOrigin/clearDestination
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

    bool? resultsLoading,
    List<Flight>? flights,
    String? resultsError,
    TravelSort? sort,

    bool clearOneWay = false,
    bool clearRange = false,
    bool clearOrigin = false,
    bool clearDestination = false,
  }) {
    return TravelState(
      loading: loading ?? this.loading,
      airports: airports ?? this.airports,

      origin: clearOrigin ? null : (origin ?? this.origin),
      destination: clearDestination ? null : (destination ?? this.destination),

      tripType: tripType ?? this.tripType,

      oneWayDate: clearOneWay ? null : (oneWayDate ?? this.oneWayDate),
      rangeStart: clearRange ? null : (rangeStart ?? this.rangeStart),
      rangeEnd: clearRange ? null : (rangeEnd ?? this.rangeEnd),

      adults: adults ?? this.adults,
      kids: kids ?? this.kids,
      babies: babies ?? this.babies,

      error: error,

      resultsLoading: resultsLoading ?? this.resultsLoading,
      flights: flights ?? this.flights,
      resultsError: resultsError,
      sort: sort ?? this.sort,
    );
  }
}
