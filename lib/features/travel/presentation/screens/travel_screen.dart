// lib/features/travel/presentation/screens/travel_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/airport.dart';
import '../bloc/travel_bloc.dart';
import '../widgets/passengers_bottom_sheet.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});
  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> with TickerProviderStateMixin {
  late final AnimationController _swapCtrl;
  late final Animation<double> _swapAnim;

  final _originCtrl = TextEditingController();
  final _destCtrl   = TextEditingController();
  final _originFocus = FocusNode();
  final _destFocus   = FocusNode();

  @override
  void initState() {
    super.initState();
    _swapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _swapAnim = Tween(begin: 0.0, end: pi).animate(_swapCtrl);
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
    const bg = Color(0xFFF6F7FB);

    Widget body(Widget child) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
        ),
        centerTitle: true,
        title: Image.asset('assets/iconos/Bee-pay-big.png', height: 28, fit: BoxFit.contain),
      ),
      body: body(
        BlocConsumer<TravelBloc, TravelState>(
          listenWhen: (p, c) => p.origin != c.origin || p.destination != c.destination || p.error != c.error,
          listener: (context, s) {
            _originCtrl.text = s.origin?.concatenacion ?? '';
            _destCtrl.text   = s.destination?.concatenacion ?? '';
            if (s.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.error!)));
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
                      Text(
                        '¿A DÓNDE QUERÉS VIAJAR?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Seleccioná los detalles de tu vuelo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 3,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Card Origen/Destino con alineación exacta
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        // Fila 1: Avión despegue + Origen
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
                                  context.read<TravelBloc>().add(TravelSelectOrigin(ap));
                                },
                                onClear: () {
                                  context.read<TravelBloc>().add(TravelSelectOrigin(null));
                                  _originCtrl.value = _originCtrl.value.copyWith(text: '');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Fila 2: Línea punteada + flechas swap
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
                                            Icon(Icons.arrow_downward_outlined, color: Colors.amber, size: 18),
                                            Icon(Icons.arrow_upward_outlined,  color: Colors.amber, size: 18),
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
                        // Fila 3: Avión aterrizaje + Destino
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
                                  context.read<TravelBloc>().add(TravelSelectDestination(ap));
                                },
                                onClear: () {
                                  context.read<TravelBloc>().add(TravelSelectDestination(null));
                                  _destCtrl.value = _destCtrl.value.copyWith(text: '');
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Fila chips: Ida y vuelta / Pasajeros
                        Row(
                          children: [
                            Expanded(
                              child: _TripTypeDropdown(
                                value: s.tripType == 'OW' ? 'Ida' : 'Ida y vuelta',
                                onChanged: (v) => context
                                    .read<TravelBloc>()
                                    .add(TravelSelectTripType(v == 'Ida' ? 'OW' : 'RT')),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PassengersButton(
                                adults: s.adults,
                                kids: s.kids,
                                babies: s.babies,
                                onConfirm: (a, k, b) =>
                                    context.read<TravelBloc>().add(TravelSetPassengers(a, k, b)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Center(
                  child: Text(
                    'Seleccioná tus fechas:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: s.tripType == 'OW'
                        ? _OneDate(
                            date: s.oneWayDate,
                            onPick: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialEntryMode: DatePickerEntryMode.calendarOnly,
                                initialDate: s.oneWayDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(context).colorScheme.copyWith(
                                      primary: Colors.amber,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: Colors.black87,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                context.read<TravelBloc>().add(TravelPickOneDate(picked));
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
                                initialEntryMode: DatePickerEntryMode.calendarOnly,
                                firstDate: now,
                                lastDate: DateTime(2100),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(context).colorScheme.copyWith(
                                      primary: Colors.amber,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: Colors.black87,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (range != null) {
                                context.read<TravelBloc>().add(TravelPickRange(range.start, range.end));
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
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      context.read<TravelBloc>().add(TravelSubmit());
                      if (context.read<TravelBloc>().state.isValid) {
                        Navigator.pushNamed(context, '/resultados');
                      }
                    },
                    child: const Text('Buscar vuelos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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

/// Celda lateral con el avión centrado verticalmente en cada fila
class _RailCell extends StatelessWidget {
  final IconData icon;
  const _RailCell({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Center(
        child: Icon(
          icon,                 // ← usa el ícono recibido
          color: Colors.amber,
          size: 24,
        ),
      ),
    );
  }
}

/// Línea punteada vertical con altura controlada para quedar entre los campos
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
          final dashH = 8.0;
          final gap = 6.0;
          final n = (c.maxHeight / (dashH + gap)).floor().clamp(1, 10);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(n, (_) {
              return Container(
                width: 4,
                height: dashH,
                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(2)),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF0F2F7), borderRadius: BorderRadius.circular(30)),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
        items: opciones.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
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
    final label = date == null ? 'Fecha de Ida' : '${date!.day}/${date!.month}/${date!.year}';
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xFFF0F2F7), borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _RangeDate extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final VoidCallback onPick;
  const _RangeDate({required this.start, required this.end, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final ida    = start == null ? 'Fecha de Ida'    : '${start!.day}/${start!.month}/${start!.year}';
    final vuelta = end   == null ? 'Fecha de Vuelta' : '${end!.day}/${end!.month}/${end!.year}';
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xFFF0F2F7), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(ida, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Text('-', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(vuelta, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Autocomplete (campos transparentes, lista completa de aeropuertos)
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
              textController.value = textController.value.copyWith(text: textController.text);
            }
          },
          child: TextField(
            controller: textController,
            focusNode: fn,
            onTap: () {
              textController.value = textController.value.copyWith(text: textController.text);
            },
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700),
              filled: false, // transparente
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.black38),
                onPressed: () {
                  controller.clear();
                  onClear();
                  textController.value = textController.value.copyWith(text: '');
                },
              ),
            ),
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
                minWidth: min(screenW * .72, 360),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: opts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final ap = opts.elementAt(i);
                  return ListTile(
                    leading: const Icon(Icons.flight, color: Colors.black87),
                    title: Text(
                      '${ap.iata.toUpperCase()}, ${ap.name}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      ap.concatenacion,
                      style: const TextStyle(color: Colors.black54),
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
