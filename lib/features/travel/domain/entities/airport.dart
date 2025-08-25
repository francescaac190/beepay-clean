// lib/features/travel/domain/entities/airport.dart
class Airport {
  final String iata;
  final String name;
  final String concatenacion;

  const Airport({
    required this.iata,
    required this.name,
    required this.concatenacion,
  });

  factory Airport.fromJson(Map<String, dynamic> j) => Airport(
        iata: (j['iata'] ?? '').toString(),
        name: (j['nombre'] ?? j['name'] ?? '').toString(),
        concatenacion: (j['concatenacion'] ??
                '${j['iata'] ?? ''} - ${j['city'] ?? ''}, ${j['country'] ?? ''} (${j['nombre'] ?? j['name'] ?? ''})')
            .toString(),
      );
}
