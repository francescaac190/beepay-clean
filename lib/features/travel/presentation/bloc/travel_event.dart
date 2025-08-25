import 'package:beepay/features/travel/presentation/bloc/travel_state.dart' show TravelSort;

import '../../domain/entities/airport.dart';
import '../../domain/entities/flight.dart';

// --------- EVENTS ----------
abstract class TravelEvent {}

class TravelLoadAirports extends TravelEvent {}

class TravelSelectOrigin extends TravelEvent {
  final Airport? origin;
  TravelSelectOrigin(this.origin);
}

class TravelSelectDestination extends TravelEvent {
  final Airport? destination;
  TravelSelectDestination(this.destination);
}

class TravelSwapAirports extends TravelEvent {}

class TravelSelectTripType extends TravelEvent {
  final String type; // 'OW' | 'RT'
  TravelSelectTripType(this.type);
}

class TravelPickOneDate extends TravelEvent {
  final DateTime date;
  TravelPickOneDate(this.date);
}

class TravelPickRange extends TravelEvent {
  final DateTime start;
  final DateTime end;
  TravelPickRange(this.start, this.end);
}

class TravelSetPassengers extends TravelEvent {
  final int adults;
  final int kids;
  final int babies;
  TravelSetPassengers(this.adults, this.kids, this.babies);
}

class TravelSubmit extends TravelEvent {}

/// Lanzar búsqueda de vuelos (si querés separarlo explícitamente del Submit)
class TravelSearchFlights extends TravelEvent {}

/// Cambio de orden de resultados
class TravelChangeSort extends TravelEvent {
  final TravelSort sort;
  TravelChangeSort(this.sort);
}

/// Seleccionar un vuelo para ver/continuar
class TravelSelectFlight extends TravelEvent {
  final Flight flight;
  TravelSelectFlight(this.flight);
}
