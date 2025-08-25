// lib/features/travel/data/repositories/travel_repository_impl.dart
import '../../domain/entities/airport.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/search_request.dart';
import '../../domain/repositories/travel_repository.dart';
import '../datasources/travel_remote_datasource.dart';

class TravelRepositoryImpl implements TravelRepository {
  final TravelRemoteDataSource remote;
  TravelRepositoryImpl(this.remote);

  @override
  Future<List<Airport>> getAirports({required String baseUrl, required String token}) {
    return remote.fetchAirports(baseUrl: baseUrl, token: token);
  }

  @override
  Future<List<Flight>> searchFlights({
    required String baseUrl,
    required String token,
    required SearchRequest request,
  }) {
    return remote.fetchFlights(baseUrl: baseUrl, token: token, request: request);
  }
}
