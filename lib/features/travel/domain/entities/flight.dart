// lib/features/travel/domain/entities/flight.dart
class Flight {
  final List<Leg> ida;
  final List<Leg>? vuelta;
  final String totalAmount;      // monto base (string para evitar errores de parse)
  final String totalAmountFee;   // monto con fees ya formateado si viene así
  final String totalCurrency;    // 'BOB' | 'USD' etc.
  final int fee;                 // fee numérico si lo necesitás
  final String identificador;
  final String gds;
  final String puntos;           // cashback/puntos
  final num factor;
  final int estado;
  final dynamic idUsuarioInterno;
  final int? sucursal;
  final dynamic fm;

  const Flight({
    required this.ida,
    required this.vuelta,
    required this.totalAmount,
    required this.totalAmountFee,
    required this.totalCurrency,
    required this.fee,
    required this.identificador,
    required this.gds,
    required this.puntos,
    required this.factor,
    required this.estado,
    required this.idUsuarioInterno,
    required this.sucursal,
    required this.fm,
  });
}

class Leg {
  final int segment;
  final int leg;
  final String arrivalAirport;
  final String arrivalCiudad;
  final String arrivalAeropuerto;
  final String arrivalChangeDayIndicator;
  final String arrivalDate;              // yyyy-MM-dd
  final String arrivalTime;              // HH:mm
  final String mesArrival;
  final String arrivalDateOfWeekName;
  final String carrierReferenceId;
  final String logoCarrier;
  final String nameCarrier;
  final String departureAirport;
  final String departureCiudad;
  final String? departureAeropuerto;
  final String departureDate;            // yyyy-MM-dd
  final String mesDeparture;
  final String departureDateOfWeekName;
  final String departureTime;            // HH:mm
  final String flightNumber;
  final String flightStops;
  final String flightTime;               // HH:mm (duración del tramo)
  final String flightType;
  final int order;
  final String equipment;
  final String vuelosClass;
  final dynamic lugresDisponibles;
  final String equipaje;
  final String? aeropuertoOrigenAeropuertoV;

  const Leg({
    required this.segment,
    required this.leg,
    required this.arrivalAirport,
    required this.arrivalCiudad,
    required this.arrivalAeropuerto,
    required this.arrivalChangeDayIndicator,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.mesArrival,
    required this.arrivalDateOfWeekName,
    required this.carrierReferenceId,
    required this.logoCarrier,
    required this.nameCarrier,
    required this.departureAirport,
    required this.departureCiudad,
    this.departureAeropuerto,
    required this.departureDate,
    required this.mesDeparture,
    required this.departureDateOfWeekName,
    required this.departureTime,
    required this.flightNumber,
    required this.flightStops,
    required this.flightTime,
    required this.flightType,
    required this.order,
    required this.equipment,
    required this.vuelosClass,
    this.lugresDisponibles,
    required this.equipaje,
    this.aeropuertoOrigenAeropuertoV,
  });
}
