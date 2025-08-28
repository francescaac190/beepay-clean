// lib/features/resultados/presentation/screens/resultados_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/cores.dart';
import '../../../travel/presentation/bloc/travel_bloc.dart';
import '../../../travel/presentation/bloc/travel_event.dart';
import '../../../travel/presentation/bloc/travel_state.dart';
import '../../../travel/domain/entities/flight.dart';

class ResultadosScreen extends StatelessWidget {
  const ResultadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background2,
      appBar: AppBar(
        backgroundColor: blanco,
        surfaceTintColor: blanco,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: blackBeePay),
        ),
        centerTitle: true,
        title: Text('Resultados', style: semibold(blackBeePay, 18)),
      ),
      body: BlocBuilder<TravelBloc, TravelState>(
        builder: (context, s) {
          final titulo = s.tripType == 'OW'
              ? 'Ida: ${_fmt(s.oneWayDate)}'
              : 'Ida: ${_fmt(s.rangeStart)}  •  Vuelta: ${_fmt(s.rangeEnd)}';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // Resumen
              Card(
                color: blanco,
                surfaceTintColor: blanco,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: extraBold(blackBeePay, 16)),
                      const SizedBox(height: 8),
                      Text(
                        'De: ${s.origin?.concatenacion ?? '-'}\nA: ${s.destination?.concatenacion ?? '-'}',
                        textAlign: TextAlign.left,
                        style: semibold(gris7, 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pasajeros: ${s.adults} adultos • ${s.kids} niños • ${s.babies} bebés',
                        style: semibold(gris6, 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Orden
              Row(
                children: [
                  Text('Ordenar por:', style: semibold(blackBeePay, 14)),
                  const SizedBox(width: 10),
                  _SortDropdown(
                    value: s.sort,
                    onChanged: (sort) =>
                        context.read<TravelBloc>().add(TravelChangeSort(sort)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (s.resultsLoading) ...[
                Card(
                  color: blanco,
                  surfaceTintColor: blanco,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: const SizedBox(
                    height: 140,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: amber,
                      ),
                    ),
                  ),
                ),
              ] else if (s.resultsError != null) ...[
                Card(
                  color: blanco,
                  surfaceTintColor: blanco,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: SizedBox(
                    height: 140,
                    child: Center(
                      child: Text(s.resultsError!, style: semibold(rojo, 14)),
                    ),
                  ),
                ),
              ] else if (s.flights.isEmpty) ...[
                Card(
                  color: blanco,
                  surfaceTintColor: blanco,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: const SizedBox(
                    height: 140,
                    child: Center(
                      child: Text('No se encontraron vuelos'),
                    ),
                  ),
                ),
              ] else ...[
                // LISTA DE VUELOS (tap -> navega a InfoReserva)
                ...s.flights.map((f) => _FlightCard(f)).toList(),
              ],
            ],
          );
        },
      ),
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _SortDropdown extends StatelessWidget {
  final TravelSort value;
  final ValueChanged<TravelSort> onChanged;
  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: blanco,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: gris1, width: 1),
      ),
      child: DropdownButton<TravelSort>(
        value: value,
        isDense: true,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: gris6),
        items: [
          DropdownMenuItem(
            value: TravelSort.priceAsc,
            child: Text(
              'Más económico',
              style: regular(blackBeePay, 15),
            ),
          ),
          DropdownMenuItem(
            value: TravelSort.cashbackDesc,
            child: Text(
              'Más cashback',
              style: regular(blackBeePay, 15),
            ),
          ),
          DropdownMenuItem(
            value: TravelSort.departureEarly,
            child: Text(
              'Más temprano',
              style: regular(blackBeePay, 15),
            ),
          ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final Flight f;
  const _FlightCard(this.f);

  @override
  Widget build(BuildContext context) {
    final ida = f.ida;
    final vuelta = f.vuelta;

    final vueltaTitle = vuelta == null
        ? null
        : 'Vuelta: ${vuelta.first.departureDateOfWeekName}, '
            '${_dd(vuelta.first.departureDate)} de ${vuelta.first.mesDeparture} de ${vuelta.first.departureDate.substring(0, 4)}';

    final idaTitle = 'Ida: ${ida.first.departureDateOfWeekName}, '
        '${_dd(ida.first.departureDate)} de ${ida.first.mesDeparture} de ${ida.first.departureDate.substring(0, 4)}';

    return InkWell(
      onTap: () {
        // guardamos el vuelo seleccionado en el bloc
        context.read<TravelBloc>().add(TravelSelectFlight(f));

        // pasamos el bloc explícitamente como argumento
        Navigator.pushNamed(
          context,
          '/info_reserva',
          arguments: context.read<TravelBloc>(),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: blanco,
        surfaceTintColor: blanco,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          child: Column(
            children: [
              _legHeader(ida.first.logoCarrier, idaTitle),
              _legRow(
                horaSalida: ida.first.departureTime,
                aeSalida: ida.first.departureAirport,
                ciudadSalida: ida.first.departureCiudad,
                conexiones: max(ida.last.leg - 1, 0),
                vuelo: 'Vuelo ${ida.first.flightNumber}',
                horaLlegada: ida.last.arrivalTime,
                aeLlegada: ida.last.arrivalAirport,
                ciudadLlegada: ida.last.arrivalCiudad,
              ),
              _equipajeNote(ida.last.equipaje),
              if (vuelta != null) ...[
                const SizedBox(height: 12),
                _legHeader(vuelta.first.logoCarrier, vueltaTitle!),
                _legRow(
                  horaSalida: vuelta.first.departureTime,
                  aeSalida: vuelta.first.departureAirport,
                  ciudadSalida: vuelta.first.departureCiudad,
                  conexiones: max(vuelta.last.leg - 1, 0),
                  vuelo: 'Vuelo ${vuelta.first.flightNumber}',
                  horaLlegada: vuelta.last.arrivalTime,
                  aeLlegada: vuelta.last.arrivalAirport,
                  ciudadLlegada: vuelta.last.arrivalCiudad,
                ),
                _equipajeNote(vuelta.last.equipaje),
              ],
              const Divider(height: 18, color: gris1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL', style: black(gris7, 18)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${f.totalCurrency}. ${f.totalAmountFee}',
                          style: extraBold(blackBeePay, 18),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1.2, color: amber),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department,
                                  size: 16, color: amber),
                              const SizedBox(width: 6),
                              Text('Desde ${f.puntos} BeePuntos',
                                  style: semibold(amber, 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legHeader(String logoUrl, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 6),
          logoUrl.trim().isEmpty
              ? const Icon(Icons.flight, color: amber)
              : Image.network(
                  logoUrl,
                  height: 28,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.flight, color: amber),
                ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: semibold(gris7, 13))),
        ],
      ),
    );
  }

  Widget _legRow({
    required String horaSalida,
    required String aeSalida,
    required String ciudadSalida,
    required int conexiones,
    required String vuelo,
    required String horaLlegada,
    required String aeLlegada,
    required String ciudadLlegada,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.flight_takeoff, color: blackBeePay),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(horaSalida, style: extraBold(blackBeePay, 14)),
                Text(aeSalida, style: semibold(gris7, 13)),
                Text(ciudadSalida, style: regular(gris6, 12)),
              ],
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                conexiones >= 1 ? 'Conexiones: $conexiones' : 'Directo',
                style: semibold(gris6, 12),
              ),
              Text(vuelo, style: semibold(blackBeePay, 13)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(horaLlegada, style: extraBold(blackBeePay, 14)),
                Text(aeLlegada,
                    textAlign: TextAlign.end, style: semibold(gris7, 13)),
                Text(ciudadLlegada,
                    textAlign: TextAlign.end, style: regular(gris6, 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _equipajeNote(String equipaje) {
    final incluye = equipaje.trim().isNotEmpty && equipaje.trim() != '0';
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          incluye ? '* Incluye equipaje' : '* No incluye equipaje',
          style: semibold(incluye ? cupertinoGreen : rojo, 12),
        ),
      ),
    );
  }

  String _dd(String ymd) {
    try {
      final d = DateTime.parse(ymd);
      final f = DateFormat('dd');
      return f.format(d);
    } catch (_) {
      return ymd.substring(8, 10);
    }
  }
}
