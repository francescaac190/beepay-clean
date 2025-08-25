// lib/features/travel/data/datasources/travel_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/airport.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/search_request.dart';
import '../models/flight_model.dart';

abstract class TravelRemoteDataSource {
  Future<List<Airport>> fetchAirports({required String baseUrl, required String token});

  Future<List<Flight>> fetchFlights({
    required String baseUrl,
    required String token,
    required SearchRequest request,
  });
}

class TravelRemoteDataSourceImpl implements TravelRemoteDataSource {
  final http.Client client;
  TravelRemoteDataSourceImpl(this.client);

  @override
  Future<List<Airport>> fetchAirports({required String baseUrl, required String token}) async {
    if (baseUrl.isEmpty) {
      return _mockAirports();
    }

    final uri = Uri.parse('$baseUrl' 'get-aeropuertos');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final res = await client.get(uri, headers: headers);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final jsonBody = json.decode(res.body);
        final List<dynamic> datos = (jsonBody['datos'] ?? []) as List<dynamic>;
        datos.sort((a, b) => (a['concatenacion'] ?? '').toString().compareTo((b['concatenacion'] ?? '').toString()));
        return datos
            .map((it) => Airport(
                  iata: (it['iata'] ?? '').toString(),
                  name: (it['nombre'] ?? '').toString(),
                  concatenacion: (it['concatenacion'] ?? '').toString(),
                ))
            .toList();
      }
      return _mockAirports();
    } catch (_) {
      return _mockAirports();
    }
  }

  @override
  Future<List<Flight>> fetchFlights({
    required String baseUrl,
    required String token,
    required SearchRequest request,
  }) async {
    final uri = Uri.parse('$baseUrl' 'get-disponibilida_v3');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    // Body según tu API anterior
    final body = {
      "adultos": request.adults.toString(),
      "senior": "0",
      "infante": request.babies.toString(), // bebés
      "menor": request.kids.toString(),     // niños
      "origen": request.originIata,
      "destino": request.destinationIata,
      "fecha_ida": request.tripType == 'OW'
          ? _fmt(request.oneWayDate)
          : _fmt(request.rangeStart),
      "fecha_vuelta": request.tripType == 'RT'
          ? _fmt(request.rangeEnd)
          : "",
      "tipo_busqueda": request.tripType, // 'OW' | 'RT'
      "fechaFexible": "0",
      "vuelos_directos": "0",
      "vuelos_incluyenequipaje": "0",
      "tipo_cabina": "",
      "aerolinea": "",
      "hora_salida": "",
      "hora_regreso": "",
      "id_session": ""
    };

    try {
      final res = await client.post(uri, headers: headers, body: json.encode(body));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final jsonBody = json.decode(res.body);
        final List<dynamic> datos = (jsonBody['datos'] ?? []) as List<dynamic>;
        return datos.map((it) => FlightModel.fromJson(it as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error HTTP ${res.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  List<Airport> _mockAirports() => const [
        Airport(iata: 'VVI', name: 'Viru Viru', concatenacion: 'VVI - Viru Viru (Santa Cruz, BO)'),
        Airport(iata: 'LPB', name: 'El Alto', concatenacion: 'LPB - El Alto (La Paz, BO)'),
        Airport(iata: 'CBB', name: 'J Wilstermann', concatenacion: 'CBB - J Wilstermann (Cochabamba, BO)'),
        Airport(iata: 'EZE', name: 'Ministro Pistarini', concatenacion: 'EZE - Ezeiza (Buenos Aires, AR)'),
        Airport(iata: 'GRU', name: 'Guarulhos', concatenacion: 'GRU - Guarulhos (São Paulo, BR)'),
      ];

  String _fmt(DateTime? d) => d == null
      ? ''
      : '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
