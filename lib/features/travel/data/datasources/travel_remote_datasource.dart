import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/airport.dart';

abstract class TravelRemoteDataSource {
  Future<List<Airport>> fetchAirports({required String baseUrl, required String token});
}

class TravelRemoteDataSourceImpl implements TravelRemoteDataSource {
  final http.Client client;
  TravelRemoteDataSourceImpl(this.client);

  @override
  Future<List<Airport>> fetchAirports({required String baseUrl, required String token}) async {
    // Si no hay baseUrl configurada, devolvemos un mock funcional
    if (baseUrl.isEmpty) {
      return _mockAirports();
    }

    final uri = Uri.parse('${baseUrl}get-aeropuertos');
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
      // Fallback mock si la API falla
      return _mockAirports();
    } catch (_) {
      return _mockAirports();
    }
  }

  List<Airport> _mockAirports() => const [
        Airport(iata: 'VVI', name: 'Viru Viru', concatenacion: 'VVI - Viru Viru (Santa Cruz, BO)'),
        Airport(iata: 'LPB', name: 'El Alto', concatenacion: 'LPB - El Alto (La Paz, BO)'),
        Airport(iata: 'CBB', name: 'J Wilstermann', concatenacion: 'CBB - J Wilstermann (Cochabamba, BO)'),
        Airport(iata: 'EZE', name: 'Ministro Pistarini', concatenacion: 'EZE - Ezeiza (Buenos Aires, AR)'),
        Airport(iata: 'GRU', name: 'Guarulhos', concatenacion: 'GRU - Guarulhos (São Paulo, BR)'),
      ];
}
