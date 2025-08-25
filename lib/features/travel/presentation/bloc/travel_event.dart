// lib/features/travel/presentation/bloc/travel_event.dart
import '../../domain/entities/airport.dart';

/// Orden disponible en resultados
enum TravelSort { priceAsc, cashbackDesc, departureEarly }

/// Eventos del BLoC de Travel
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

/// 'OW' | 'RT'
class TravelSelectTripType extends TravelEvent {
  final String type;
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

/// Valida el formulario
class TravelSubmit extends TravelEvent {}

/// Dispara la búsqueda de vuelos con los datos del estado
class TravelSearchFlights extends TravelEvent {}

/// Cambia el orden de los vuelos y resortear
class TravelChangeSort extends TravelEvent {
  final TravelSort sort;
  TravelChangeSort(this.sort);
}
