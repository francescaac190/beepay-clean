import '../../domain/entities/airport.dart';
import '../../domain/entities/flight.dart';

enum TravelSort { priceAsc, cashbackDesc, departureEarly }

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

  // resultados
  final bool resultsLoading;
  final String? resultsError;
  final List<Flight> flights;

  // orden
  final TravelSort sort;

  // vuelo seleccionado
  final Flight? selectedFlight;

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
    this.resultsError,
    this.flights = const [],

    this.sort = TravelSort.priceAsc,

    this.selectedFlight,
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

    bool? resultsLoading,
    String? resultsError,
    List<Flight>? flights,

    TravelSort? sort,

    Flight? selectedFlight,

    // flags para limpiar
    bool clearOneWay = false,
    bool clearRange = false,
    bool clearError = false,
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

      error: clearError ? null : (error ?? this.error),

      resultsLoading: resultsLoading ?? this.resultsLoading,
      resultsError: resultsError,
      flights: flights ?? this.flights,

      sort: sort ?? this.sort,

      selectedFlight: selectedFlight ?? this.selectedFlight,
    );
  }
}
