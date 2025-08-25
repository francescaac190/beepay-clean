// lib/features/travel/domain/repositories/travel_repository.dart
import '../entities/airport.dart';
import '../entities/flight.dart';
import '../entities/search_request.dart';

abstract class TravelRepository {
  Future<List<Airport>> getAirports({required String baseUrl, required String token});

  Future<List<Flight>> searchFlights({
    required String baseUrl,
    required String token,
    required SearchRequest request,
  });
}
