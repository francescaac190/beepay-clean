// lib/features/pasajeros/presentation/screens/agregar_pasajeros_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../core/cores.dart';
import '../../../../core/services/filesystem_manager.dart';

class AgregarPasajerosScreen extends StatefulWidget {
  const AgregarPasajerosScreen({super.key});

  @override
  State<AgregarPasajerosScreen> createState() => _AgregarPasajerosScreenState();
}

class _AgregarPasajerosScreenState extends State<AgregarPasajerosScreen> {
  final _formKey = GlobalKey<FormState>();

  String? nombre;
  String? apellido;
  String genero = 'F';
  String? fechaNac;                 // yyyy-MM-dd
  String? numeroDocumento;
  String tipoPersona = 'ADUT';      // ADUT | CHILD | INF (AUTO por DOB)
  int idDocumento = 1;              // 1 CI, 2 Pasaporte

  final _cNombre = TextEditingController();
  final _cApellido = TextEditingController();
  final _cDocumento = TextEditingController();

  DateTime _date = DateTime.now();
  final _storage = const FlutterSecureStorage();

  bool _loaderOpen = false;

  void _log(String tag, String msg) {
    final ts = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('[PASAJ-ADD][$tag][$ts] $msg');
  }

  @override
  void dispose() {
    _cNombre.dispose();
    _cApellido.dispose();
    _cDocumento.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: regular(blanco, 14)),
        backgroundColor: error ? rojo : blackBeePay,
      ),
    );
  }

  Future<void> _showErrorDialog(String title, String msg) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: blanco,
        title: Text(title, style: bold(blackBeePay, 16)),
        content: SingleChildScrollView(child: Text(msg, style: regular(gris7, 14))),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK', style: semibold(amber, 14)))],
      ),
    );
  }

  void _openLoader() {
    if (_loaderOpen) return;
    _loaderOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    ).then((_) => _loaderOpen = false);
  }

  void _closeLoader() {
    if (_loaderOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _pickDate() async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    initialDatePickerMode: DatePickerMode.year,
    initialDate: DateTime(now.year - 25, now.month, now.day),
    firstDate: DateTime(1900),
    lastDate: now,
    helpText: '',
    cancelText: 'Cancelar',
    confirmText: 'Aceptar',
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: amber,
          onPrimary: blanco,
          surface: blanco,
          onSurface: blackBeePay,
        ),
      ),
      child: child!,
    ),
  );
  if (picked == null) return;

  setState(() {
  _date = picked;

  // Edad exacta en años (con cumpleaños ya pasado o no)
  final today = DateTime.now();
  int years = today.year - picked.year;
  final hadBirthday = (today.month > picked.month) ||
      (today.month == picked.month && today.day >= picked.day);
  if (!hadBirthday) years--;

  // Log para verificar rápido
  _log('EDAD', 'DOB=$picked -> $years años');

  // Clasificación: INF <2, CHILD 2-11, ADUT ≥12
  if (years < 2) {
    tipoPersona = 'INF';
  } else if (years <= 11) {
    tipoPersona = 'CHILD';
  } else {
    tipoPersona = 'ADUT';
  }

  // Fecha para la API
  fechaNac = DateFormat('yyyy-MM-dd').format(picked);
});
}
  Map<String, dynamic> _compact(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    m.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      out[k] = v;
    });
    return out;
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    _log('ACTION',
        'Tap Continuar. formOk=$formOk fechaNac=$fechaNac genero=$genero tipo=$tipoPersona idDoc=$idDocumento');

    if (!formOk || fechaNac == null) {
      _showSnack('Ingresá todos los datos', error: true);
      return;
    }

    // email y teléfono del usuario logueado (perfil)
    final perfilEmail = FileSystemManager.instance.email?.trim() ?? '';
    final perfilCel   = FileSystemManager.instance.cel?.trim() ?? '';
    _log('PERFIL', 'email="$perfilEmail" cel="$perfilCel"');

    final base = (await _storage.read(key: 'api_base_url')) ?? '';
    final token = (await _storage.read(key: 'auth_token')) ?? '';

    final maskedToken = token.isEmpty
        ? '<empty>'
        : '${token.substring(0, token.length.clamp(0, 6))}...${token.substring(token.length - token.length.clamp(0, 4))}';
    _log('CRED', 'api_base_url="$base" | auth_token="$maskedToken"');

    if (base.isEmpty || token.isEmpty) {
      await _showErrorDialog('Error',
          'No se encontraron credenciales locales (api_base_url / auth_token). Iniciá sesión e intentá de nuevo.');
      return;
    }

    final baseNormalized = base.endsWith('/') ? base : '$base/';
    final url = Uri.parse('${baseNormalized}registrarPersona');
    _log('HTTP', 'POST $url');

    // Payload SOLO snake_case (como espera el backend)
    final persona = _compact({
      "nombre": (nombre ?? '').toUpperCase(),
      "apellido": (apellido ?? '').toUpperCase(),
      "genero": genero.toUpperCase(),
      "fecha_nacimiento": fechaNac,                         // yyyy-MM-dd
      "id_documento": idDocumento,                          // 1 CI, 2 Pasaporte
      "numero_documento": (numeroDocumento ?? '').toUpperCase(),
      "telefono": perfilCel,                                // del perfil
      "email": perfilEmail,                                 // del perfil
      "tipo_persona": tipoPersona,                          // ADUT | CHILD | INF (auto)
    });

    final payload = {"personas": [persona]};

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    _log('REQ', 'headers=${jsonEncode(headers)}');
    _log('REQ', 'payload=${jsonEncode(payload)}');

    _openLoader();
    final started = DateTime.now();

    try {
      final res = await http
          .post(url, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 25));

      final elapsedMs = DateTime.now().difference(started).inMilliseconds;
      _log('RESP', 'status=${res.statusCode} elapsed=${elapsedMs}ms');
      _log('RESP', 'body=${res.body}');

      _closeLoader();
      if (!mounted) return;

      if (res.statusCode == 401) {
        _showSnack('Usuario no autenticado (401). Volvé a iniciar sesión.',
            error: true);
        Future.delayed(const Duration(milliseconds: 400), () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/h', (route) => false);
        });
        return;
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        dynamic body;
        try { body = jsonDecode(res.body); } catch (_) {}

        final estado =
            body is Map ? (body['estado'] ?? body['status'] ?? res.statusCode) : res.statusCode;
        final message =
            body is Map ? (body['message'] ?? body['mensaje'] ?? 'Operación exitosa') : 'Operación exitosa';

        if (estado == 200) {
          _showSnack(message.toString());
          Navigator.pop(context, {'created': true}); // refresca lista
          return;
        }

        if (body is Map && body['errors'] != null) {
          await _showErrorDialog('Validación', jsonEncode(body['errors']));
          return;
        }

        await _showErrorDialog(
            'Aviso', 'Respuesta no esperada.\nestado=$estado\nmensaje=$message');
        return;
      }

      // No-2xx
      String detail = res.body;
      try {
        final j = jsonDecode(res.body);
        if (j is Map && (j['message'] != null || j['mensaje'] != null)) {
          detail = (j['message'] ?? j['mensaje']).toString();
        }
      } catch (_) {}
      await _showErrorDialog('Error', 'Fallo ${res.statusCode}:\n$detail');
    } on TimeoutException catch (e) {
      _closeLoader();
      _log('ERR', 'Timeout: $e');
      await _showErrorDialog('Tiempo de espera agotado',
          'La solicitud tardó demasiado. Revisá tu conexión e intentá nuevamente.');
    } catch (e) {
      _closeLoader();
      _log('ERR', 'Excepción: $e');
      await _showErrorDialog('Excepción', e.toString());
    }
  }

  String _tipoLegible(String code) {
    switch (code) {
      case 'INF':
        return 'Bebé';
      case 'CHILD':
        return 'Niño';
      default:
        return 'Adulto';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background2,
      appBar: AppBar(
        backgroundColor: blanco,
        surfaceTintColor: blanco,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: amber),
        ),
        centerTitle: true,
        title: Text('Agregar Pasajero', style: bold(blackBeePay, 18)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: blanco,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 7,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Text('Información de Pasajero', style: bold(blackBeePay, 16)),
                      const Divider(thickness: 1, height: 20, color: Colors.black),

                      // Nombre
                      Text('ingresá tu nombre de pila:', style: regular(gris7, 14)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cNombre,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          filled: true,
                          hintText: 'ingresá tu nombre',
                          hintStyle: regular(gris6, 14),
                          fillColor: Colors.grey.shade100,
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'POR FAVOR INGRESÁ TU NOMBRE' : null,
                        onChanged: (v) => nombre = v,
                      ),
                      const SizedBox(height: 10),

                      // Apellido
                      Text('Ingresá tus apellidos:', style: regular(gris7, 14)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cApellido,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          filled: true,
                          hintText: 'Ingresá tu apellido',
                          hintStyle: regular(gris6, 14),
                          fillColor: Colors.grey.shade100,
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'POR FAVOR INGRESA TU APELLIDO' : null,
                        onChanged: (v) => apellido = v,
                      ),
                      const SizedBox(height: 10),

                      // Género
                      Text('Género', style: regular(gris7, 14)),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                color: Colors.grey.shade100,
                              ),
                              child: GestureDetector(
                                onTap: () => setState(() => genero = 'F'),
                                child: Row(
                                  children: <Widget>[
                                    const SizedBox(width: 10),
                                    Icon(Icons.female, color: genero == 'F' ? amber : gris6),
                                    const SizedBox(width: 8),
                                    Text('Femenino', style: genero == 'F' ? semibold(amber, 15) : regular(gris6, 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 52,
                              color: Colors.grey.shade100,
                              child: GestureDetector(
                                onTap: () => setState(() => genero = 'M'),
                                child: Row(
                                  children: <Widget>[
                                    const SizedBox(width: 10),
                                    Icon(Icons.male, color: genero == 'M' ? amber : gris6),
                                    const SizedBox(width: 8),
                                    Text('Masculino', style: genero == 'M' ? semibold(amber, 15) : regular(gris6, 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Fecha de nacimiento
                      Text('Fecha de Nacimiento', style: regular(gris7, 14)),
                      const SizedBox(height: 10),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: _pickDate,
                          child: Center(
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_date),
                              style: regular(gris6, 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tipo de pasajero (auto, solo lectura)
                      Row(
                        children: [
                          Text('Tipo de Pasajero: ', style: regular(gris7, 14)),
                          Text(_tipoLegible(tipoPersona), style: semibold(blackBeePay, 14)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tipo de Documento
                      Text('Tipo de Documento:', style: regular(gris7, 14)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: blanco,
                          value: idDocumento == 1 ? 'Carnet de identidad' : 'Pasaporte',
                          items: const [
                            DropdownMenuItem(value: 'Carnet de identidad', child: Text('Carnet de identidad')),
                            DropdownMenuItem(value: 'Pasaporte', child: Text('Pasaporte')),
                          ],
                          style: regular(gris6, 14),
                          onChanged: (v) => setState(() => idDocumento = (v == 'Carnet de identidad') ? 1 : 2),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Número de documento
                      Text('Número de Documento:', style: regular(gris7, 14)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cDocumento,
                        keyboardType: TextInputType.text, // algunos pasaportes tienen letras
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          filled: true,
                          hintText: 'Ingresá tu cédula',
                          hintStyle: regular(gris6, 14),
                          fillColor: Colors.grey.shade100,
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'POR FAVOR INGRESA TU DOCUMENTO' : null,
                        onChanged: (v) => numeroDocumento = v,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      fixedSize: Size(MediaQuery.of(context).size.width, 50),
                      backgroundColor: amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _submit,
                    child: Text('Continuar', style: semibold(blanco, 20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
