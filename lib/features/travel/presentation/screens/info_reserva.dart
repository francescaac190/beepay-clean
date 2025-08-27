// lib/features/travel/presentation/screens/info_reserva.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../core/cores.dart';
import '../../domain/entities/flight.dart';
import '../bloc/travel_bloc.dart';
import '../bloc/travel_state.dart';

/// ------------ STATE del formulario + pasajeros -------------
class InfoReservaState {
  final String? razonSocial;
  final String? nit;
  final String? email;
  final PhoneNumber phone;
  final List<Map<String, dynamic>> pasajeros; // ← seleccionados

  InfoReservaState({
    this.razonSocial,
    this.nit,
    this.email,
    PhoneNumber? phone,
    List<Map<String, dynamic>>? pasajeros,
  })  : phone = phone ?? PhoneNumber(isoCode: 'BO'), // +591 por defecto
        pasajeros = pasajeros ?? const [];

  InfoReservaState copyWith({
    String? razonSocial,
    String? nit,
    String? email,
    PhoneNumber? phone,
    List<Map<String, dynamic>>? pasajeros,
  }) {
    return InfoReservaState(
      razonSocial: razonSocial ?? this.razonSocial,
      nit: nit ?? this.nit,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      pasajeros: pasajeros ?? this.pasajeros,
    );
  }
}

class InfoReservaCubit extends Cubit<InfoReservaState> {
  InfoReservaCubit() : super(InfoReservaState());

  void setRazon(String v) => emit(state.copyWith(razonSocial: v));
  void setNit(String v) => emit(state.copyWith(nit: v));
  void setEmail(String v) => emit(state.copyWith(email: v));
  void setPhone(PhoneNumber v) => emit(state.copyWith(phone: v));

  void addPassenger(Map<String, dynamic> p) {
    final updated = List<Map<String, dynamic>>.from(state.pasajeros)..add(p);
    emit(state.copyWith(pasajeros: updated));
  }

  void removePassengerAt(int i) {
    final updated = List<Map<String, dynamic>>.from(state.pasajeros)..removeAt(i);
    emit(state.copyWith(pasajeros: updated));
  }
}

/// ------------ PANTALLA -------------
class InfoReservaScreen extends StatelessWidget {
  const InfoReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InfoReservaCubit(),
      child: Scaffold(
        backgroundColor: background2,
        appBar: AppBar(
          backgroundColor: blanco,
          surfaceTintColor: blanco,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: amber),
          ),
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Reserva', style: bold(blackBeePay, 18)),
          ),
        ),
        bottomNavigationBar: const _BottomBar(),
        body: BlocBuilder<TravelBloc, TravelState>(
          builder: (context, s) {
            final f = s.selectedFlight;
            if (f == null) {
              return Center(
                child: Text('No hay vuelo seleccionado', style: semibold(gris7, 14)),
              );
            }

            final resumenFecha = s.tripType == 'OW'
                ? 'Ida: ${_fmt(s.oneWayDate)}'
                : 'Ida: ${_fmt(s.rangeStart)}  •  Vuelta: ${_fmt(s.rangeEnd)}';

            return ListView(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 24),
              children: [
                // Título principal
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 8, 5, 10),
                  child: Text('Reserva', style: bold(blackBeePay, 20)),
                ),

                // Resumen búsqueda
                _ReCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(resumenFecha, style: extraBold(blackBeePay, 16)),
                        const SizedBox(height: 8),
                        Text(
                          'De: ${s.origin?.concatenacion ?? '-'}\nA: ${s.destination?.concatenacion ?? '-'}',
                          textAlign: TextAlign.center,
                          style: semibold(gris7, 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pasajeros: ${s.adults} adultos • ${s.kids} niños • ${s.babies} bebés',
                          style: semibold(gris6, 13),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // VUELO DE IDA
                _ReCard(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VUELO DE IDA', style: regular(gris6, 14)),
                        const SizedBox(height: 8),
                        _LegsHeader(legs: f.ida),
                        const SizedBox(height: 10),
                        _LegsExpansions(legs: f.ida),
                      ],
                    ),
                  ),
                ),

                if (f.vuelta != null && f.vuelta!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _ReCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('VUELO DE RETORNO', style: regular(gris6, 14)),
                          const SizedBox(height: 8),
                          _LegsHeader(legs: f.vuelta!),
                          const SizedBox(height: 10),
                          _LegsExpansions(legs: f.vuelta!),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ---------- PASAJEROS ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Pasajeros', style: bold(blackBeePay, 16)),
                ),
                const SizedBox(height: 8),
                const _PassengersSection(),

                const SizedBox(height: 10),

                // ---------- DATOS DE FACTURACIÓN ----------
                const _BillingCard(),

                const SizedBox(height: 10),

                // ---------- DETALLES DE CONTACTO ----------
                const _ContactCard(),

                const SizedBox(height: 90), // espacio para el bottom bar
              ],
            );
          },
        ),
      ),
    );
  }

  static String _fmt(DateTime? d) {
    if (d == null) return '-';
    return '${d.day}/${d.month}/${d.year}';
  }
}

/// ------------ CARD CON SOMBRA SUAVE -------------
class _ReCard extends StatelessWidget {
  final Widget child;
  const _ReCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: blanco,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ------------ CABECERA LEGS -------------
class _LegsHeader extends StatelessWidget {
  final List<Leg> legs;
  const _LegsHeader({required this.legs});

  @override
  Widget build(BuildContext context) {
    final totalConex = max(legs.last.leg - 1, 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Logo(legs.first.logoCarrier),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${legs.first.departureDateOfWeekName}, '
                '${_dd(legs.first.departureDate)} de ${legs.first.mesDeparture} de ${legs.first.departureDate.substring(0, 4)}',
                style: regular(gris7, 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: background2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(legs.first.departureTime, style: extraBold(blackBeePay, 14)),
                  Text(legs.first.departureAirport, style: semibold(gris7, 13)),
                  Text(legs.first.departureCiudad, style: regular(gris6, 12)),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Text(totalConex > 0 ? 'Conexiones: $totalConex' : 'Directo', style: semibold(gris6, 12)),
                  Text('Vuelo ${legs.first.flightNumber}', style: semibold(blackBeePay, 13)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(legs.last.arrivalTime, style: extraBold(blackBeePay, 14)),
                  Text(legs.last.arrivalAirport, style: semibold(gris7, 13)),
                  Text(legs.last.arrivalCiudad, style: regular(gris6, 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          (legs.last.equipaje.trim().isNotEmpty && legs.last.equipaje.trim() != '0')
              ? '* Incluye equipaje'
              : '* No incluye equipaje',
          style: semibold(
            (legs.last.equipaje.trim().isNotEmpty && legs.last.equipaje.trim() != '0') ? cupertinoGreen : rojo,
            12,
          ),
        ),
      ],
    );
  }

  static String _dd(String ymd) {
    try {
      final d = DateTime.parse(ymd);
      return d.day.toString().padLeft(2, '0');
    } catch (_) {
      return ymd.substring(8, 10);
    }
  }
}

/// ------------ LISTA EXPANDIBLE DE LEGS -------------
class _LegsExpansions extends StatelessWidget {
  final List<Leg> legs;
  const _LegsExpansions({required this.legs});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (_, __) => const Divider(height: 1, color: gris1),
      itemCount: legs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) => _LegExpansion(leg: legs[i]),
    );
  }
}

class _LegExpansion extends StatelessWidget {
  final Leg leg;
  const _LegExpansion({required this.leg});

  @override
  Widget build(BuildContext context) {
    final durationText = _durationPretty(leg.flightTime);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        title: Row(
          children: [
            const Icon(Icons.flight, size: 18, color: blackBeePay),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${leg.departureAirport} → ${leg.arrivalAirport}',
                style: extraBold(blackBeePay, 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(durationText, style: semibold(gris6, 12)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${leg.nameCarrier} • Vuelo ${leg.flightNumber}', style: regular(gris6, 12)),
        ),
        children: [
          _rowIconLine(
            icon: Icons.place_outlined,
            left: '${leg.departureCiudad} • ${leg.departureAirport}',
            right:
                '${leg.departureDate.substring(8, 10)}/${leg.departureDate.substring(5, 7)}/${leg.departureDate.substring(0, 4)} • ${leg.departureTime} hrs',
          ),
          const SizedBox(height: 6),
          _rowIconLine(
            icon: Icons.flag_outlined,
            left: '${leg.arrivalCiudad} • ${leg.arrivalAirport}',
            right:
                '${leg.arrivalDate.substring(8, 10)}/${leg.arrivalDate.substring(5, 7)}/${leg.arrivalDate.substring(0, 4)} • ${leg.arrivalTime} hrs',
          ),
          const SizedBox(height: 6),
          _rowIconLine(
            icon: Icons.luggage_rounded,
            left: 'Equipaje',
            right: (leg.equipaje.trim().isEmpty || leg.equipaje.trim() == '0') ? '0' : leg.equipaje,
          ),
        ],
      ),
    );
  }

  Widget _rowIconLine({required IconData icon, required String left, required String right}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: blackBeePay),
        const SizedBox(width: 8),
        Expanded(child: Text(left, style: regular(gris7, 13))),
        const SizedBox(width: 8),
        Text(right, style: semibold(gris6, 12)),
      ],
    );
  }

  static String _durationPretty(String rawHHmm) {
    try {
      final parts = rawHHmm.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return '${h} hr ${m} min';
    } catch (_) {
      return rawHHmm;
    }
  }
}

class _Logo extends StatelessWidget {
  final String url;
  const _Logo(this.url);

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return const Icon(Icons.flight, color: amber);
    return Image.network(
      url,
      height: 24,
      errorBuilder: (_, __, ___) => const Icon(Icons.flight, color: amber),
    );
  }
}

/// ------------ PASAJEROS: Sección completa -------------
class _PassengersSection extends StatelessWidget {
  const _PassengersSection();

  Future<void> _add(BuildContext context) async {
    try {
      final selected = await Navigator.pushNamed(context, '/pasajeros');
      if (selected != null && selected is Map) {
        context.read<InfoReservaCubit>().addPassenger(Map<String, dynamic>.from(selected));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pantalla de pasajeros no configurada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoReservaCubit, InfoReservaState>(
      builder: (context, st) {
        return Column(
          children: [
            // Botón agregar
            ElevatedButton(
              onPressed: () => _add(context),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: blanco,
                surfaceTintColor: blanco,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  const Icon(Icons.group_add, color: gris6, size: 28),
                  const SizedBox(width: 10),
                  Text('Agregar Pasajero', style: semibold(gris7, 14)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Lista seleccionados (si hay)
            if (st.pasajeros.isNotEmpty)
              _ReCard(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: st.pasajeros.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: gris1),
                  itemBuilder: (_, i) {
                    final p = st.pasajeros[i];
                    final nombre = '${p['nombre'] ?? ''} ${p['apellido'] ?? ''}'.trim();
                    final doc = p['numero_documento'] ?? p['documento'] ?? '';
                    final tipo = (p['tipo_persona_legible'] ??
                            (p['tipo_persona'] == 'ADUT'
                                ? 'Adulto'
                                : p['tipo_persona'] == 'CHILD'
                                    ? 'Niño'
                                    : p['tipo_persona'] == 'INF'
                                        ? 'Bebé'
                                        : ''))
                        .toString();

                    return ListTile(
                      leading: const Icon(Icons.person, color: blackBeePay),
                      title: Text(nombre.isEmpty ? 'Pasajero' : nombre, style: semibold(blackBeePay, 14)),
                      subtitle: Text(
                        [if (doc.toString().isNotEmpty) 'Doc: $doc', if (tipo.isNotEmpty) 'Tipo: $tipo'].join('  •  '),
                        style: regular(gris6, 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: gris6),
                        onPressed: () => context.read<InfoReservaCubit>().removePassengerAt(i),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

/// ------------ CARD: DATOS DE FACTURACIÓN -------------
class _BillingCard extends StatelessWidget {
  const _BillingCard();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InfoReservaCubit>();
    final razonCtrl = TextEditingController(text: cubit.state.razonSocial ?? '');
    final nitCtrl = TextEditingController(text: cubit.state.nit ?? '');

    return _ReCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos de facturación', style: bold(blackBeePay, 16)),
            _DividerThin(),
            const SizedBox(height: 4),

            Text('Razón Social', style: regular(gris6, 13)),
            TextField(
              controller: razonCtrl,
              decoration: const InputDecoration(
                hintText: ' ',
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: gris3)),
              ),
              style: regular(blackBeePay, 16),
              onChanged: cubit.setRazon,
            ),
            const SizedBox(height: 14),

            Text('Número de Identificación Tributaria', style: regular(gris6, 13)),
            TextField(
              controller: nitCtrl,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              decoration: const InputDecoration(
                hintText: ' ',
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: gris3)),
              ),
              style: regular(blackBeePay, 16),
              onChanged: cubit.setNit,
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------ CARD: DETALLES DE CONTACTO -------------
class _ContactCard extends StatefulWidget {
  const _ContactCard();

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<InfoReservaCubit>();

    return _ReCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles de Contacto', style: bold(blackBeePay, 16)),
            _DividerThin(),
            const SizedBox(height: 4),

            Text('Correo electrónico', style: regular(gris6, 13)),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: ' ',
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: gris3)),
              ),
              style: regular(blackBeePay, 16),
              onChanged: cubit.setEmail,
            ),
            const SizedBox(height: 14),

            Text('Número de teléfono', style: regular(gris6, 13)),
            InternationalPhoneNumberInput(
              onInputChanged: (p) => cubit.setPhone(p),
              initialValue: cubit.state.phone,
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                useBottomSheetSafeArea: true,
                showFlags: true,
              ),
              autoValidateMode: AutovalidateMode.disabled,
              ignoreBlank: false,
              textFieldController: _phoneCtrl,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
              inputDecoration: const InputDecoration(
                hintText: ' ',
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: gris3)),
              ),
              inputBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: gris3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerThin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      height: 1,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
      ),
    );
  }
}

/// ------------ BOTTOM BAR -------------
class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TravelBloc, TravelState>(
      builder: (context, s) {
        final f = s.selectedFlight;
        if (f == null) return const SizedBox.shrink();

        return BottomAppBar(
          color: blanco,
          surfaceTintColor: blanco,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${f.totalCurrency}. ${f.totalAmountFee}', style: semibold(blackBeePay, 20)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, size: 16, color: amber),
                        const SizedBox(width: 6),
                        Text('Desde ${f.puntos} BeePuntos', style: medium(amber, 16)),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final form = context.read<InfoReservaCubit>().state;
                  if ((form.email ?? '').isEmpty || (form.razonSocial ?? '').isEmpty || (form.nit ?? '').isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Completá email, razón social y NIT')),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Flujo de pago pendiente de integrar')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: amber,
                  foregroundColor: blanco,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                child: Text('Ir a pagar', style: semibold(blanco, 18)),
              ),
            ],
          ),
        );
      },
    );
  }
}
