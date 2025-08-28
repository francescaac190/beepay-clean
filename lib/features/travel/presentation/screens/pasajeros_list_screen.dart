// lib/features/travel/presentation/screens/pasajeros_list_screen.dart
import 'dart:convert';
import 'package:beepay/core/config/app_config.dart';
import 'package:beepay/core/config/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/cores.dart';

/// --------- STATES ----------
abstract class PasajerosState {
  const PasajerosState();
}
class PasajerosLoading extends PasajerosState {}

class PasajerosSuccess extends PasajerosState {
  final List<Map<String, dynamic>> items;
  const PasajerosSuccess(this.items);
}

class PasajerosError extends PasajerosState {
  final String message;
  final int? statusCode; // para detectar 401
  const PasajerosError(this.message, {this.statusCode});
}

/// --------- CUBIT ----------
class PasajerosCubit extends Cubit<PasajerosState> {
  PasajerosCubit() : super(PasajerosLoading());

  final _storage = const FlutterSecureStorage();

  Future<void> fetch() async {
    emit(PasajerosLoading());

    try {
      // Lee base desde storage; si falta, usa AppConfig.baseurl
      final storedBase = await _storage.read(key: 'api_base_url');
      final base = (storedBase != null && storedBase.isNotEmpty)
          ? storedBase
          : AppConfig.baseurl;

      // Lee token desde 'auth_token'; si falta, usa SecureStorageService
      String? token = await _storage.read(key: 'auth_token');
      token ??= await SecureStorageService.instance.getToken();

      // Logs de diagnóstico
      print('[PASAJEROS][FETCH] base(fromStorage="${storedBase ?? '-'}") -> using="$base"');
      print('[PASAJEROS][FETCH] token len=${(token ?? '').length} '
            '(null? ${token == null})');

      if ((token ?? '').isEmpty) {
        emit(const PasajerosError('No hay token (iniciá sesión)', statusCode: 401));
        return;
      }

      final baseNorm = base.endsWith('/') ? base : '$base/';
      final url = Uri.parse('${baseNorm}buscarPersona');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final payload = {"busqueda": ""};
      print('[PASAJEROS][REQ] POST $url');
      print('[PASAJEROS][REQ] headers=$headers');
      print('[PASAJEROS][REQ] body=$payload');

      final res = await http.post(url, headers: headers, body: jsonEncode(payload));

      print('[PASAJEROS][RES] status=${res.statusCode}');
      if (res.statusCode == 401) {
        print('[PASAJEROS][RES] 401 -> sesión expirada');
        emit(const PasajerosError('No autenticado', statusCode: 401));
        return;
      }
      if (res.statusCode != 200) {
        print('[PASAJEROS][RES] body=${res.body}');
        emit(PasajerosError('Error ${res.statusCode}: ${res.body}'));
        return;
      }

      final data = jsonDecode(res.body);
      final raw = (data['datos'] ?? data['data'] ?? []) as List;

      print('[PASAJEROS][PARSE] items=${raw.length}');

      final items = raw.map<Map<String, dynamic>>((e) {
        final m = Map<String, dynamic>.from(e as Map);

        final tipoRaw = (m['tipo_persona'] ?? m['tipoPersona'])?.toString() ?? '';
        String tipoLegible;
        switch (tipoRaw) {
          case 'ADUT':
            tipoLegible = 'Adulto';
            break;
          case 'CHILD':
            tipoLegible = 'Niño';
            break;
          case 'INF':
            tipoLegible = 'Bebé';
            break;
          default:
            tipoLegible = tipoRaw;
        }

        return {
          'id'               : m['id'] ?? m['persona_id'],
          'nombre'           : m['nombre'] ?? '',
          'apellido'         : m['apellido'] ?? '',
          'genero'           : m['genero'] ?? '',
          'fecha_nacimiento' : m['fecha_nacimiento'] ?? m['fechaNacimiento'] ?? '',
          'id_documento'     : m['id_documento'] ?? 1,
          'numero_documento' : m['numero_documento'] ?? m['documento'] ?? '',
          'telefono'         : m['telefono'] ?? '',
          'email'            : m['email'] ?? '',
          'tipo_persona'     : tipoRaw,
          'tipo_persona_legible': tipoLegible,
        };
      }).toList();

      emit(PasajerosSuccess(items));
    } catch (e) {
      print('[PASAJEROS][ERR] $e');
      emit(PasajerosError('Error de red: $e'));
    }
  }
}

/// --------- UI ----------
class PasajerosListScreen extends StatelessWidget {
  const PasajerosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasajerosCubit()..fetch(),
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
            child: Text('Pasajeros', style: bold(blackBeePay, 18)),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<PasajerosCubit, PasajerosState>(
            listenWhen: (p, c) => c is PasajerosError,
            listener: (context, state) {
              if (state is PasajerosError && state.statusCode == 401) {
                Mensaje(context, 'Sesión expirada. Iniciá sesión nuevamente.');
                Future.delayed(const Duration(milliseconds: 600), () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/h', (route) => false);
                });
              }
            },
            builder: (context, state) {
              if (state is PasajerosLoading) {
                return LoadingWidget();
              }

              if (state is PasajerosError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message, style: regular(gris7, 14), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.read<PasajerosCubit>().fetch(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blanco,
                            surfaceTintColor: blanco,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Reintentar', style: semibold(blackBeePay, 14)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final items = (state as PasajerosSuccess).items;

              return Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Botón "Agregar pasajero"
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(5),
                          backgroundColor: blanco,
                          surfaceTintColor: blanco,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final res = await Navigator.pushNamed(context, '/pasajeros/agregar');
                          if (res is Map && res['created'] == true) {
                            context.read<PasajerosCubit>().fetch(); // refresca
                          }
                        },
                        child: Row(
                          children: <Widget>[
                            const SizedBox(width: 10),
                            const Icon(Icons.group_add, color: blackBeePay, size: 30),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: Text('Agregar nuevo pasajero', style: semibold(blackBeePay, 14)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.all(8),
                      child: Text('Lista de Pasajeros Registrados', style: semibold(blackBeePay, 16)),
                    ),

                    if (items.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text('No hay pasajeros registrados', style: regular(gris6, 14)),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final p = items[index];
                            final nombre = '${p['nombre']} ${p['apellido']}'.trim();
                            final tipo = p['tipo_persona'] ?? '';
                            final tipoLabel = p['tipo_persona_legible'] ?? tipo;
                            final doc = p['numero_documento'] ?? '';
                            final fnac = p['fecha_nacimiento'] ?? '';

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: blanco,
                                surfaceTintColor: blanco,
                                child: ListTile(
                                  leading: Icon(
                                    tipo == 'ADUT'
                                        ? Icons.person
                                        : (tipo == 'CHILD' ? Icons.child_care : Icons.child_friendly_sharp),
                                    color: blackBeePay,
                                  ),
                                  title: Text(nombre, style: semibold(blackBeePay, 14)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (fnac.toString().isNotEmpty)
                                        Text('Fecha nacimiento: $fnac', style: regular(gris6, 12)),
                                      if (doc.toString().isNotEmpty)
                                        Text('Documento: $doc', style: regular(gris6, 12)),
                                      if (tipoLabel.toString().isNotEmpty)
                                        Text('Tipo de pasajero: $tipoLabel', style: regular(gris6, 12)),
                                    ],
                                  ),
                                  onTap: () => Navigator.pop(context, p), // ← devolver seleccionado
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add, color: amber),
                                    onPressed: () => Navigator.pop(context, p),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
