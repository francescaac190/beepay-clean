// lib/features/travel/presentation/screens/info_reserva.dart
import 'dart:math';
import 'package:beepay/features/home/presentation/bloc/perfil_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../../core/cores.dart';
import '../../domain/entities/flight.dart';
import '../bloc/travel_bloc.dart';
import '../bloc/travel_state.dart';

/// ======== NEW: Cubit para pasajeros seleccionados ========
class SelectedPassengersCubit extends Cubit<List<Map<String, dynamic>>> {
  SelectedPassengersCubit() : super(const []);

  void addPassenger(Map<String, dynamic> p) {
    final id = p['id'] ?? p['persona_id'];
    final exists = state.any((e) => (e['id'] ?? e['persona_id']) == id);
    if (exists) return;
    emit([...state, p]);
  }

  void removePassengerById(dynamic id) {
    emit(state.where((e) => (e['id'] ?? e['persona_id']) != id).toList());
  }

  void clear() => emit(const []);
}

/// ------------ CUBIT PARA EL FORM -------------
class InfoReservaState {
  final String? razonSocial;
  final String? nit;
  final String? email;

  /// Teléfono
  final String countryIso2; // ej. 'BO'
  final String dialCode; // ej. '+591'
  final String nationalNumber; // lo que el usuario escribe (sin prefijo)
  final String? e164; // +59170000000 si es válido

  InfoReservaState({
    this.razonSocial,
    this.nit,
    this.email,
    this.countryIso2 = 'BO',
    this.dialCode = '+591',
    this.nationalNumber = '',
    this.e164,
  });

  InfoReservaState copyWith({
    String? razonSocial,
    String? nit,
    String? email,
    String? countryIso2,
    String? dialCode,
    String? nationalNumber,
    String? e164,
  }) {
    return InfoReservaState(
      razonSocial: razonSocial ?? this.razonSocial,
      nit: nit ?? this.nit,
      email: email ?? this.email,
      countryIso2: countryIso2 ?? this.countryIso2,
      dialCode: dialCode ?? this.dialCode,
      nationalNumber: nationalNumber ?? this.nationalNumber,
      e164: e164 ?? this.e164,
    );
  }
}

class InfoReservaCubit extends Cubit<InfoReservaState> {
  InfoReservaCubit() : super(InfoReservaState());

  void setRazon(String v) => emit(state.copyWith(razonSocial: v));
  void setNit(String v) => emit(state.copyWith(nit: v));
  void setEmail(String v) => emit(state.copyWith(email: v));

  void setCountry({required String iso2, required String dial}) {
    emit(state.copyWith(countryIso2: iso2, dialCode: dial));
    _revalidatePhone();
  }

  void setNationalNumber(String v) {
    emit(state.copyWith(nationalNumber: v));
    _revalidatePhone();
  }

  void _revalidatePhone() {
    try {
      final iso = IsoCode.fromJson(state.countryIso2); // 'BO', 'AR', etc.
      final raw = '${state.dialCode}${state.nationalNumber}';
      final parsed = PhoneNumber.parse(
        raw,
        destinationCountry: iso,
      );
      final isValid = parsed.isValid();
      final e164 = isValid ? '+${parsed.countryCode}${parsed.nsn}' : null;
      emit(state.copyWith(e164: e164));
    } catch (_) {
      emit(state.copyWith(e164: null));
    }
  }
}

/// ------------ PANTALLA -------------
class InfoReservaScreen extends StatelessWidget {
  const InfoReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => InfoReservaCubit()),
        BlocProvider(create: (_) => SelectedPassengersCubit()),
      ],
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
                child: Text('No hay vuelo seleccionado',
                    style: semibold(gris7, 14)),
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
                const _AddPassengerButton(),

                const SizedBox(height: 8),
                const _SelectedPassengersCard(),

                const SizedBox(height: 10),

                // ---------- DATOS DE FACTURACIÓN ----------
                const _BillingCard(),

                const SizedBox(height: 10),

                // ---------- DETALLES DE CONTACTO ----------
                const _ContactCard(),
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
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(legs.first.departureTime,
                        style: extraBold(blackBeePay, 14)),
                    Text(legs.first.departureAirport,
                        style: semibold(gris7, 13)),
                    Text(legs.first.departureCiudad, style: regular(gris6, 12)),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  Text(
                    totalConex > 0 ? 'Conexiones: $totalConex' : 'Directo',
                    style: semibold(gris6, 12),
                  ),
                  Text('Vuelo ${legs.first.flightNumber}',
                      style: semibold(blackBeePay, 13)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(legs.last.arrivalTime,
                        style: extraBold(blackBeePay, 14)),
                    Text(legs.last.arrivalAirport, style: semibold(gris7, 13)),
                    Text(legs.last.arrivalCiudad,
                        textAlign: TextAlign.end, style: regular(gris6, 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          (legs.last.equipaje.trim().isNotEmpty &&
                  legs.last.equipaje.trim() != '0')
              ? '* Incluye equipaje'
              : '* No incluye equipaje',
          style: semibold(
            (legs.last.equipaje.trim().isNotEmpty &&
                    legs.last.equipaje.trim() != '0')
                ? cupertinoGreen
                : rojo,
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
          child: Text(
            '${leg.nameCarrier} • Vuelo ${leg.flightNumber}',
            style: regular(gris6, 12),
          ),
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
            right: (leg.equipaje.trim().isEmpty || leg.equipaje.trim() == '0')
                ? '0'
                : leg.equipaje,
          ),
        ],
      ),
    );
  }

  Widget _rowIconLine(
      {required IconData icon, required String left, required String right}) {
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

/// ======== Helpers de conteo por tipo de pasajero ========
Map<String, int> _countByType(List<Map<String, dynamic>> list) {
  int adut = 0, child = 0, inf = 0;
  for (final p in list) {
    final t = (p['tipo_persona'] ?? p['tipoPersona'] ?? '').toString();
    if (t == 'ADUT') {
      adut++;
    } else if (t == 'CHILD') {
      child++;
    } else if (t == 'INF') {
      inf++;
    }
  }
  return {'ADUT': adut, 'CHILD': child, 'INF': inf};
}

String _tipoLabelCorto(String code) {
  switch (code) {
    case 'ADUT':
      return 'Adultos';
    case 'CHILD':
      return 'Niños';
    case 'INF':
      return 'Bebés';
    default:
      return code;
  }
}

/// ------------ PASAJEROS: BOTÓN AGREGAR -------------
class _AddPassengerButton extends StatelessWidget {
  const _AddPassengerButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          final res = await Navigator.pushNamed(context, '/listapasajeros');
          if (res is Map<String, dynamic>) {
            final tipo =
                (res['tipo_persona'] ?? res['tipoPersona'] ?? '').toString();

            // Estado actual
            final selected = context.read<SelectedPassengersCubit>().state;
            final counts = _countByType(selected);

            // Requeridos desde la búsqueda (TravelBloc)
            final ts = context.read<TravelBloc>().state;
            final needA = ts.adults ?? 0;
            final needK = ts.kids ?? 0;
            final needB = ts.babies ?? 0;

            bool canAdd = true;
            String? bloqueLabel;

            if (tipo == 'ADUT' && counts['ADUT']! >= needA) {
              canAdd = false;
              bloqueLabel = _tipoLabelCorto('ADUT');
            } else if (tipo == 'CHILD' && counts['CHILD']! >= needK) {
              canAdd = false;
              bloqueLabel = _tipoLabelCorto('CHILD');
            } else if (tipo == 'INF' && counts['INF']! >= needB) {
              canAdd = false;
              bloqueLabel = _tipoLabelCorto('INF');
            }

            if (!canAdd) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Ya alcanzaste el máximo de $bloqueLabel')),
              );
              return;
            }

            context.read<SelectedPassengersCubit>().addPassenger(res);

            final nombre =
                '${res['nombre'] ?? ''} ${res['apellido'] ?? ''}'.trim();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pasajero agregado: $nombre')),
            );
          }
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Pantalla de pasajeros no configurada')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: blanco,
        surfaceTintColor: blanco,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
    );
  }
}

/// ======== Tarjeta que muestra los pasajeros seleccionados ========
class _SelectedPassengersCard extends StatelessWidget {
  const _SelectedPassengersCard();

  String _tipoLegible(String? code) {
    switch (code) {
      case 'INF':
        return 'Bebé';
      case 'CHILD':
        return 'Niño';
      case 'ADUT':
        return 'Adulto';
      default:
        return (code ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedPassengersCubit, List<Map<String, dynamic>>>(
      builder: (context, list) {
        return _ReCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Seleccionados', style: bold(blackBeePay, 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: background2,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${list.length}',
                          style: semibold(gris7, 12)),
                    ),
                    const Spacer(),
                    if (list.isNotEmpty)
                      TextButton.icon(
                        onPressed: () =>
                            context.read<SelectedPassengersCubit>().clear(),
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: Text('Limpiar', style: semibold(gris7, 13)),
                      ),
                  ],
                ),
                 _DividerThin(),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text('Aún no seleccionaste pasajeros.',
                        style: regular(gris6, 13)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0.5, color: gris1),
                    itemBuilder: (_, i) {
                      final p = list[i];
                      final nombre =
                          '${p['nombre'] ?? ''} ${p['apellido'] ?? ''}'.trim();
                      final tipo = _tipoLegible(
                          (p['tipo_persona'] ?? p['tipoPersona'])?.toString());
                      final doc = (p['numero_documento'] ?? p['documento'] ?? '')
                          .toString();
                      final id = p['id'] ?? p['persona_id'];

                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.person, color: blackBeePay),
                        title:
                            Text(nombre, style: semibold(blackBeePay, 14)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tipo.isNotEmpty)
                              Text('Tipo: $tipo', style: regular(gris6, 12)),
                            if (doc.isNotEmpty)
                              Text('Doc.: $doc', style: regular(gris6, 12)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: gris5),
                          onPressed: () => context
                              .read<SelectedPassengersCubit>()
                              .removePassengerById(id),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ------------ CARD: DATOS DE FACTURACIÓN -------------
class _BillingCard extends StatefulWidget {
  const _BillingCard();

  @override
  State<_BillingCard> createState() => _BillingCardState();
}

class _BillingCardState extends State<_BillingCard> {
  late TextEditingController _razonCtrl;
  late TextEditingController _nitCtrl;
  final FocusNode _nitFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<InfoReservaCubit>();
    _razonCtrl = TextEditingController(text: cubit.state.razonSocial ?? '');
    _nitCtrl = TextEditingController(text: cubit.state.nit ?? '');
  }

  @override
  void dispose() {
    _razonCtrl.dispose();
    _nitCtrl.dispose();
    _nitFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InfoReservaCubit>();

    final facturas = context.select<PerfilBloc, List<_Factura>>((bloc) {
      final st = bloc.state;
      if (st is PerfilLoaded) {
        final items = st.perfil.facturacion ?? <dynamic>[];
        return items
            .map<_Factura>((e) {
              final razon =
                  (e.razonSocial ?? e.razon ?? e.nombre ?? '').toString();
              final nit = (e.nit ?? '').toString();
              return _Factura(razon: razon, nit: nit);
            })
            .where((f) => f.razon.isNotEmpty)
            .toList();
      }
      return const <_Factura>[];
    });

    return _ReCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos de facturación', style: bold(blackBeePay, 16)),
            _DividerThin(),
            const SizedBox(height: 4),

            // Razón Social con sugerencias
            Text('Razón Social', style: regular(gris6, 13)),
            RawAutocomplete<_Factura>(
              optionsBuilder: (value) {
                final q = value.text.trim().toLowerCase();
                if (q.isEmpty) return facturas;
                return facturas.where((f) =>
                    f.razon.toLowerCase().contains(q) || f.nit.contains(q));
              },
              displayStringForOption: (f) => f.razon,
              onSelected: (f) => _selectFactura(f, cubit),
              fieldViewBuilder:
                  (context, textCtrl, focusNode, onFieldSubmitted) {
                textCtrl.value = _razonCtrl.value;
                _razonCtrl = textCtrl;

                return TextField(
                  controller: _razonCtrl,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: ' ',
                    hintStyle: regular(gris6, 14),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: gris3),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (facturas.isNotEmpty)
                          IconButton(
                            tooltip: 'Elegir de mis facturas',
                            icon: const Icon(Icons.expand_more, color: gris6),
                            onPressed: () => _openSheet(facturas, cubit),
                          ),
                        if (_razonCtrl.text.isNotEmpty)
                          IconButton(
                            icon:
                                const Icon(Icons.clear, color: gris5, size: 20),
                            onPressed: () {
                              _razonCtrl.clear();
                              cubit.setRazon('');
                            },
                          ),
                      ],
                    ),
                  ),
                  style: regular(blackBeePay, 16),
                  onChanged: cubit.setRazon,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 0.5, color: gris1),
                      itemBuilder: (_, i) {
                        final f = options.elementAt(i);
                        return ListTile(
                          leading: const Icon(Icons.receipt_long_outlined,
                              color: blackBeePay),
                          title: Text(f.razon,
                              style: semibold(blackBeePay, 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          subtitle:
                              Text('NIT: ${f.nit}', style: regular(gris6, 12)),
                          onTap: () => onSelected(f),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // NIT
            Text('Número de Identificación Tributaria',
                style: regular(gris6, 13)),
            TextField(
              controller: _nitCtrl,
              focusNode: _nitFocus,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              decoration: const InputDecoration(
                hintText: ' ',
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: gris3),
                ),
              ),
              style: regular(blackBeePay, 16),
              onChanged: cubit.setNit,
            ),
          ],
        ),
      ),
    );
  }

  void _selectFactura(_Factura f, InfoReservaCubit cubit) {
    _razonCtrl.text = f.razon;
    _nitCtrl.text = f.nit;
    cubit.setRazon(f.razon);
    cubit.setNit(f.nit);
    _nitFocus.requestFocus();
  }

  void _openSheet(List<_Factura> facturas, InfoReservaCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: facturas.length,
          separatorBuilder: (_, __) => const Divider(height: 0.5, color: gris1),
          itemBuilder: (_, i) {
            final f = facturas[i];
            return ListTile(
              leading:
                  const Icon(Icons.receipt_long_outlined, color: blackBeePay),
              title: Text(f.razon, style: semibold(blackBeePay, 14)),
              subtitle: Text('NIT: ${f.nit}', style: regular(gris6, 12)),
              onTap: () {
                Navigator.pop(context);
                _selectFactura(f, cubit);
              },
            );
          },
        ),
      ),
    );
  }
}

class _Factura {
  final String razon;
  final String nit;
  const _Factura({required this.razon, required this.nit});
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
  String? _phoneError;

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
    final st = cubit.state;

    return _ReCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles de Contacto', style: bold(blackBeePay, 16)),
            _DividerThin(),
            const SizedBox(height: 4),

            // Email
            Text('Correo electrónico', style: regular(gris6, 13)),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: ' ',
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: gris3),
                ),
              ),
              style: regular(blackBeePay, 16),
              onChanged: cubit.setEmail,
            ),
            const SizedBox(height: 14),

            // Teléfono
            Text('Número de teléfono', style: regular(gris6, 13)),
            Row(
              children: [
                CountryCodePicker(
                  onChanged: (cc) {
                    final iso2 = (cc.code ?? 'BO');
                    final dial = (cc.dialCode ?? st.dialCode);
                    context.read<InfoReservaCubit>().setCountry(
                          iso2: iso2,
                          dial: dial,
                        );
                    _validateAndUpdate(context, st.nationalNumber);
                  },
                  initialSelection: st.countryIso2,
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  favorite: const ['BO', 'AR', 'CL', 'PE', 'BR', 'US', 'ES'],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: ' ',
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gris3),
                      ),
                      prefixText: '${st.dialCode} ',
                      errorText: _phoneError,
                    ),
                    style: regular(blackBeePay, 16),
                    onChanged: (v) => _validateAndUpdate(context, v),
                  ),
                ),
              ],
            ),
            if (st.e164 != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Teléfono (E.164): ${st.e164}',
                    style: regular(gris6, 12)),
              ),
          ],
        ),
      ),
    );
  }

  void _validateAndUpdate(BuildContext context, String v) {
    final cubit = context.read<InfoReservaCubit>();
    cubit.setNationalNumber(v);
    final e164 = cubit.state.e164;
    setState(() {
      _phoneError = (v.isEmpty || e164 != null) ? null : 'Número inválido';
    });
  }
}

class _DividerThin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      height: 1,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
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
              // monto + puntos
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${f.totalCurrency}. ${f.totalAmountFee}',
                        style: semibold(blackBeePay, 20)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            size: 16, color: amber),
                        const SizedBox(width: 6),
                        Text('Desde ${f.puntos} BeePuntos',
                            style: medium(amber, 16)),
                      ],
                    ),
                  ],
                ),
              ),
              // botón pagar
              ElevatedButton(
                onPressed: () {
                  final form = context.read<InfoReservaCubit>().state;
                  if ((form.email ?? '').isEmpty ||
                      (form.razonSocial ?? '').isEmpty ||
                      (form.nit ?? '').isEmpty ||
                      (form.e164 ?? '').isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Completá email, razón social, NIT y teléfono válido')),
                    );
                    return;
                  }

                  // ===== Validación de cantidades requeridas vs seleccionadas =====
                  final seleccionados =
                      context.read<SelectedPassengersCubit>().state;
                  final c = _countByType(seleccionados);

                  // Requeridos
                  final needA = s.adults ?? 0;
                  final needK = s.kids ?? 0;
                  final needB = s.babies ?? 0;

                  // Chequear igualdad exacta
                  final mismatches = <String>[];
                  if (c['ADUT'] != needA) {
                    mismatches.add('Adultos: ${c['ADUT']} de $needA');
                  }
                  if (c['CHILD'] != needK) {
                    mismatches.add('Niños: ${c['CHILD']} de $needK');
                  }
                  if (c['INF'] != needB) {
                    mismatches.add('Bebés: ${c['INF']} de $needB');
                  }

                  if (mismatches.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Seleccioná la cantidad correcta de pasajeros.\n${mismatches.join(' • ')}',
                        ),
                      ),
                    );
                    return;
                  }

                  // OK: continuar flujo (aquí va tu navegación real a pago)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'OK. Teléfono: ${form.e164} • Pasajeros: ${seleccionados.length}')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: amber,
                  foregroundColor: blanco,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
