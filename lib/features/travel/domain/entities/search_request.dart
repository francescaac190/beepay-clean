// lib/features/travel/domain/entities/search_request.dart
class SearchRequest {
  final String originIata;
  final String destinationIata;
  final String tripType;          // 'OW' | 'RT'
  final DateTime? oneWayDate;     // si OW
  final DateTime? rangeStart;     // si RT
  final DateTime? rangeEnd;       // si RT
  final int adults;
  final int kids;                 // "menor" en tu API
  final int babies;               // "infante" en tu API

  const SearchRequest({
    required this.originIata,
    required this.destinationIata,
    required this.tripType,
    required this.oneWayDate,
    required this.rangeStart,
    required this.rangeEnd,
    required this.adults,
    required this.kids,
    required this.babies,
  });
}
