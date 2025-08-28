// lib/features/travel/presentation/screens/travel_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cores.dart';
import '../../domain/entities/airport.dart';
import '../bloc/travel_bloc.dart';
import '../bloc/travel_event.dart';
import '../bloc/travel_state.dart';
import '../widgets/passengers_bottom_sheet.dart';
import '../../../resultados/presentation/screens/resultados_screen.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});
  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen>
    with TickerProviderStateMixin {
  late final AnimationController _swapCtrl;
  late final Animation<double> _swapAnim;

  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _originFocus = FocusNode();
  final _destFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _swapCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _swapAnim = Tween(begin: 0.0, end: pi).animate(_swapCtrl);

    // Defaults de fechas al entrar si están vacías
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<TravelBloc>();
      final s = bloc.state;
      final now = DateTime.now();

      if (s.tripType == 'OW') {
        if (s.oneWayDate == null) {
          bloc.add(TravelPickOneDate(now));
        }
      } else {
        final start = s.rangeStart ?? now;
        final end = s.rangeEnd ?? start.add(const Duration(days: 3));
        if (s.rangeStart == null || s.rangeEnd == null) {
          bloc.add(TravelPickRange(start, end));
        }
      }
    });
  }

  @override
  void dispose() {
    _swapCtrl.dispose();
    _originCtrl.dispose();
    _destCtrl.dispose();
    _originFocus.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  void _swap() {
    if (_swapCtrl.isCompleted) {
      _swapCtrl.reverse();
    } else {
      _swapCtrl.forward();
    }
    context.read<TravelBloc>().add(TravelSwapAirports());
  }

  @override
  Widget build(BuildContext context) {
    Widget body(Widget child) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: child,
        );

    return Scaffold(
      backgroundColor: background2,
      appBar: AppBar(
        backgroundColor: blanco,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: blackBeePay),
        ),
        centerTitle: true,
        title: Image.asset('assets/iconos/Bee-pay-big.png',
            height: 28, fit: BoxFit.contain),
      ),
      body: body(
        BlocConsumer<TravelBloc, TravelState>(
          listenWhen: (p, c) =>
              p.origin != c.origin ||
              p.destination != c.destination ||
              p.error != c.error,
          listener: (context, s) {
            _originCtrl.text = s.origin?.concatenacion ?? '';
            _destCtrl.text = s.destination?.concatenacion ?? '';
            if (s.error != null) {
              Mensaje(context, s.error!);
              // ScaffoldMessenger.of(context)
              //     .showSnackBar(SnackBar(content: Text(s.error!)));
            }
          },
          builder: (context, s) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      Text('¿A DÓNDE QUERÉS VIAJAR?',
                          textAlign: TextAlign.center, style: black(gris7, 22)),
                      const SizedBox(height: 6),
                      Text('Seleccioná los detalles de tu vuelo',
                          style: semibold(gris6, 14)),
                      const SizedBox(height: 8),
                      Container(
                          height: 3,
                          width: 120,
                          decoration: BoxDecoration(
                              color: amber,
                              borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Card Origen/Destino
                Card(
                  color: blanco,
                  surfaceTintColor: blanco,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        // Origen
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const _RailCell(icon: Icons.flight_takeoff),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _AirportAutocomplete(
                                label: 'Origen',
                                controller: _originCtrl,
                                focusNode: _originFocus,
                                options: s.airports,
                                onSelected: (ap) {
                                  FocusScope.of(context).unfocus();
                                  context
                                      .read<TravelBloc>()
                                      .add(TravelSelectOrigin(ap));
                                },
                                onClear: () {
                                  context
                                      .read<TravelBloc>()
                                      .add(TravelSelectOrigin(null));
                                  _originCtrl.value =
                                      _originCtrl.value.copyWith(text: '');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Swap
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const _RailDash(height: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Center(
                                child: InkWell(
                                  onTap: _swap,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: AnimatedBuilder(
                                      animation: _swapAnim,
                                      builder: (_, __) => Transform.rotate(
                                        angle: _swapAnim.value,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.arrow_downward_outlined,
                                                color: amber, size: 18),
                                            Icon(Icons.arrow_upward_outlined,
                                                color: amber, size: 18),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Destino
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const _RailCell(icon: Icons.flight_land),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _AirportAutocomplete(
                                label: 'Destino',
                                controller: _destCtrl,
                                focusNode: _destFocus,
                                options: s.airports,
                                onSelected: (ap) {
                                  FocusScope.of(context).unfocus();
                                  context
                                      .read<TravelBloc>()
                                      .add(TravelSelectDestination(ap));
                                },
                                onClear: () {
                                  context
                                      .read<TravelBloc>()
                                      .add(TravelSelectDestination(null));
                                  _destCtrl.value =
                                      _destCtrl.value.copyWith(text: '');
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Chips: tipo de viaje / pasajeros
                        Row(
                          children: [
                            Expanded(
                              child: _TripTypeDropdown(
                                value:
                                    s.tripType == 'OW' ? 'Ida' : 'Ida y vuelta',
                                onChanged: (v) {
                                  final bloc = context.read<TravelBloc>();
                                  final now = DateTime.now();
                                  final isOW = v == 'Ida';

                                  // Cambiar tipo
                                  bloc.add(
                                      TravelSelectTripType(isOW ? 'OW' : 'RT'));

                                  // Setear defaults según tipo si faltan
                                  if (isOW) {
                                    final d = bloc.state.oneWayDate ?? now;
                                    bloc.add(TravelPickOneDate(d));
                                  } else {
                                    final start = bloc.state.rangeStart ?? now;
                                    final end = bloc.state.rangeEnd ??
                                        start.add(const Duration(days: 3));
                                    bloc.add(TravelPickRange(start, end));
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PassengersButton(
                                adults: s.adults,
                                kids: s.kids,
                                babies: s.babies,
                                onConfirm: (a, k, b) => context
                                    .read<TravelBloc>()
                                    .add(TravelSetPassengers(a, k, b)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                    child: Text('Seleccioná tus fechas:',
                        style: extraBold(blackBeePay, 16))),
                const SizedBox(height: 12),

                Card(
                  color: blanco,
                  surfaceTintColor: blanco,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: s.tripType == 'OW'
                        ? _OneDate(
                            date: s.oneWayDate,
                            onPick: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                initialDate: s.oneWayDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme:
                                        Theme.of(context).colorScheme.copyWith(
                                              primary: amber,
                                              onPrimary: blanco,
                                              surface: blanco,
                                              onSurface: blackBeePay,
                                            ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                context
                                    .read<TravelBloc>()
                                    .add(TravelPickOneDate(picked));
                              }
                            },
                          )
                        : _RangeDate(
                            start: s.rangeStart,
                            end: s.rangeEnd,
                            onPick: () async {
                              final now = DateTime.now();
                              final range = await showDateRangePicker(
                                context: context,
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                firstDate: now,
                                lastDate: DateTime(2100),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme:
                                        Theme.of(context).colorScheme.copyWith(
                                              primary: amber,
                                              onPrimary: blanco,
                                              surface: blanco,
                                              onSurface: blackBeePay,
                                            ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (range != null) {
                                context.read<TravelBloc>().add(
                                    TravelPickRange(range.start, range.end));
                              }
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: amber,
                      foregroundColor: blanco,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final bloc = context.read<TravelBloc>();
                      final s = bloc.state;
                      final now = DateTime.now();

                      // Origen/Destino obligatorios
                      if (s.origin == null || s.destination == null) {
                        MensajeError(context, 'Seleccioná origen y destino');
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //       content: Text('Seleccioná origen y destino')),
                        // );
                        return;
                      }

                      // Inyectar fechas por defecto si faltan
                      if (s.tripType == 'OW') {
                        final d = s.oneWayDate ?? now;
                        if (s.oneWayDate == null)
                          bloc.add(TravelPickOneDate(d));
                      } else {
                        final start = s.rangeStart ?? now;
                        final end =
                            s.rangeEnd ?? start.add(const Duration(days: 3));
                        if (s.rangeStart == null || s.rangeEnd == null) {
                          bloc.add(TravelPickRange(start, end));
                        }
                      }

                      // Enviar eventos y navegar con el mismo bloc
                      bloc
                        ..add(TravelSubmit())
                        ..add(TravelSearchFlights());

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: bloc,
                            child: const ResultadosScreen(),
                          ),
                        ),
                      );
                    },
                    child: Text('Buscar vuelos', style: semibold(blanco, 18)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Celda lateral con el avión
class _RailCell extends StatelessWidget {
  final IconData icon;
  const _RailCell({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Center(
        child: Icon(icon, color: amber, size: 24),
      ),
    );
  }
}

/// Línea punteada vertical
class _RailDash extends StatelessWidget {
  final double height;
  const _RailDash({this.height = 30});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: height,
      child: LayoutBuilder(
        builder: (context, c) {
          const dashH = 8.0;
          const gap = 6.0;
          final n = (c.maxHeight / (dashH + gap)).floor().clamp(1, 10);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(n, (_) {
              return Container(
                width: 4,
                height: dashH,
                decoration: BoxDecoration(
                  color: amber,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _TripTypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _TripTypeDropdown({required this.value, required this.onChanged});
  static const opciones = ['Ida y vuelta', 'Ida'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: gris6),
        items: opciones
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(v, style: semibold(gris7, 14)),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _OneDate extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onPick;
  const _OneDate({required this.date, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final label = date == null
        ? 'Fecha de Ida'
        : '${date!.day}/${date!.month}/${date!.year}';
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: semibold(blackBeePay, 15)),
      ),
    );
  }
}

class _RangeDate extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final VoidCallback onPick;
  const _RangeDate(
      {required this.start, required this.end, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final ida = start == null
        ? 'Fecha de Ida'
        : '${start!.day}/${start!.month}/${start!.year}';
    final vuelta = end == null
        ? 'Fecha de Vuelta'
        : '${end!.day}/${end!.month}/${end!.year}';
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(ida, style: semibold(blackBeePay, 15)),
            Text('-', style: semibold(blackBeePay, 15)),
            Text(vuelta, style: semibold(blackBeePay, 15)),
          ],
        ),
      ),
    );
  }
}

/// Autocomplete (lista completa de aeropuertos y ABRE AL INSTANTE)
class _AirportAutocomplete extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<Airport> options;
  final void Function(Airport) onSelected;
  final VoidCallback onClear;

  const _AirportAutocomplete({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.options,
    required this.onSelected,
    required this.onClear,
  });

  Iterable<Airport> _filter(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return options; // TODOS
    return options.where((a) => a.concatenacion.toLowerCase().contains(query));
  }

  // Fuerza a que RawAutocomplete “abra” de inmediato
  void _forceOpenNow(TextEditingController c) {
    final txt = c.text;
    c.text = '$txt ';
    c.selection = TextSelection.collapsed(offset: c.text.length);
    Future.microtask(() {
      c.text = txt;
      c.selection = TextSelection.collapsed(offset: c.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Airport>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (value) => _filter(value.text),
      displayStringForOption: (a) => a.concatenacion,
      onSelected: (ap) => onSelected(ap),
      fieldViewBuilder: (context, textController, fn, onSubmit) {
        return Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              _forceOpenNow(textController);
            }
          },
          child: TextField(
            controller: textController,
            focusNode: fn,
            onTap: () {
              _forceOpenNow(textController);
            },
            decoration: InputDecoration(
              hintText: label,
              hintStyle: medium(gris6, 14),
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(Icons.close, size: 18, color: gris5),
                onPressed: () {
                  controller.clear();
                  onClear();
                  _forceOpenNow(textController);
                },
              ),
            ),
            style: medium(blackBeePay, 15),
          ),
        );
      },
      optionsViewBuilder: (context, onSelectedOpt, opts) {
        final screenW = MediaQuery.of(context).size.width;
        final maxH = MediaQuery.of(context).size.height * .55;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxH,
                minWidth: min(screenW * .72, 360.0),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: opts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final ap = opts.elementAt(i);
                  return ListTile(
                    leading: const Icon(Icons.flight, color: blackBeePay),
                    title: Text(
                      '${ap.iata.toUpperCase()}, ${ap.name}',
                      style: medium(blackBeePay, 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      ap.concatenacion,
                      style: regular(gris6, 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSelectedOpt(ap),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
