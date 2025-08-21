import '../../domain/entities/airport.dart';
import '../../domain/repositories/travel_repository.dart';
import '../datasources/travel_remote_datasource.dart';

class TravelRepositoryImpl implements TravelRepository {
  final TravelRemoteDataSource remote;
  TravelRepositoryImpl(this.remote);

  @override
  Future<List<Airport>> getAirports({required String baseUrl, required String token}) {
    return remote.fetchAirports(baseUrl: baseUrl, token: token);
  }
}
