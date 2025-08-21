import '../entities/airport.dart';

abstract class TravelRepository {
  Future<List<Airport>> getAirports({required String baseUrl, required String token});
}
