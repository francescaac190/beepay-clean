// lib/features/travel/data/models/flight_model.dart
import 'package:intl/intl.dart';
import '../../domain/entities/flight.dart';

class FlightModel extends Flight {
  FlightModel({
    required super.ida,
    required super.vuelta,
    required super.totalAmount,
    required super.totalAmountFee,
    required super.totalCurrency,
    required super.fee,
    required super.identificador,
    required super.gds,
    required super.puntos,
    required super.factor,
    required super.estado,
    required super.idUsuarioInterno,
    required super.sucursal,
    required super.fm,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    final List<Leg> idaList = (json['vuelos_ida'] as List<dynamic>? ?? [])
        .map((e) => LegModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<Leg> vueltaList = (json['vuelos_vuelta'] as List<dynamic>? ?? [])
        .map((e) => LegModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final totalAmountStr = (json['total_amount'] ?? '').toString();
    final totalAmountFee = json['total_amount_fee'];
    final totalAmountFeeStr = totalAmountFee == null
        ? ''
        : NumberFormat("#.00").format(totalAmountFee);

    return FlightModel(
      ida: idaList,
      vuelta: vueltaList.isEmpty ? null : vueltaList,
      totalAmount: totalAmountStr,
      totalAmountFee: totalAmountFeeStr,
      totalCurrency: (json['total_currency'] ?? '').toString(),
      fee: (json['fee'] ?? 0) is int ? json['fee'] as int : int.tryParse('${json['fee'] ?? 0}') ?? 0,
      identificador: (json['identificador'] ?? '').toString(),
      gds: (json['gds'] ?? '').toString(),
      puntos: (json['puntos'] ?? '').toString(),
      factor: json['factor'] ?? 0,
      estado: (json['estado'] ?? 0) is int ? json['estado'] as int : int.tryParse('${json['estado'] ?? 0}') ?? 0,
      idUsuarioInterno: json['id_usuario_interno'],
      sucursal: (json['sucursal'] is int) ? json['sucursal'] as int : int.tryParse('${json['sucursal'] ?? ''}'),
      fm: json['fm'],
    );
  }
}

class LegModel extends Leg {
  LegModel({
    required super.segment,
    required super.leg,
    required super.arrivalAirport,
    required super.arrivalCiudad,
    required super.arrivalAeropuerto,
    required super.arrivalChangeDayIndicator,
    required super.arrivalDate,
    required super.arrivalTime,
    required super.mesArrival,
    required super.arrivalDateOfWeekName,
    required super.carrierReferenceId,
    required super.logoCarrier,
    required super.nameCarrier,
    required super.departureAirport,
    required super.departureCiudad,
    super.departureAeropuerto,
    required super.departureDate,
    required super.mesDeparture,
    required super.departureDateOfWeekName,
    required super.departureTime,
    required super.flightNumber,
    required super.flightStops,
    required super.flightTime,
    required super.flightType,
    required super.order,
    required super.equipment,
    required super.vuelosClass,
    super.lugresDisponibles,
    required super.equipaje,
    super.aeropuertoOrigenAeropuertoV,
  });

  factory LegModel.fromJson(Map<String, dynamic> json) {
    return LegModel(
      segment: json['segment'] ?? 0,
      leg: json['leg'] ?? 0,
      arrivalAirport: (json['arrival_airport'] ?? '').toString(),
      arrivalCiudad: (json['arrival_ciudad'] ?? '').toString(),
      arrivalAeropuerto: (json['arrival_aeropuerto'] ?? '').toString(),
      arrivalChangeDayIndicator: (json['arrival_change_day_indicator'] ?? '').toString(),
      arrivalDate: (json['arrival_date'] ?? '').toString(),
      arrivalTime: (json['arrival_time'] ?? '').toString(),
      mesArrival: (json['mes_arrival'] ?? '').toString(),
      arrivalDateOfWeekName: (json['arrival_date_of_week_name'] ?? '').toString(),
      carrierReferenceId: (json['carrier_reference_id'] ?? '').toString(),
      logoCarrier: (json['logo_carrier'] ?? ' ').toString(),
      nameCarrier: (json['name_carrier'] ?? ' ').toString(),
      departureAirport: (json['departure_airport'] ?? '').toString(),
      departureCiudad: (json['departure_ciudad'] ?? '').toString(),
      departureAeropuerto: (json['departure_aeropuerto'])?.toString(),
      departureDate: (json['departure_date'] ?? '').toString(),
      mesDeparture: (json['mes_departure'] ?? '').toString(),
      departureDateOfWeekName: (json['departure_date_of_week_name'] ?? '').toString(),
      departureTime: (json['departure_time'] ?? '').toString(),
      flightNumber: (json['flight_number'] ?? '').toString(),
      flightStops: (json['flight_stops'] ?? '').toString(),
      flightTime: (json['flight_time'] ?? '').toString(),
      flightType: (json['flight_type'] ?? '').toString(),
      order: json['order'] ?? 0,
      equipment: (json['equipment'] ?? '').toString(),
      vuelosClass: (json['class'] ?? '').toString(),
      lugresDisponibles: json['lugres_disponibles'],
      equipaje: (json['equipaje'] ?? '').toString(),
      aeropuertoOrigenAeropuertoV: (json['aeropuerto_origen_aeropuerto_v'])?.toString(),
    );
  }
}
