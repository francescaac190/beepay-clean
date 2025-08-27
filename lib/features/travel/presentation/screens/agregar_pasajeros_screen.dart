// lib/features/pasajeros/presentation/screens/agregar_pasajeros_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../core/cores.dart';

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
  String? fechaNac; // yyyy-MM-dd
  String? numeroDocumento;
  String tipoPersona = 'ADUT'; // ADUT | CHILD | INF
  int idDocumento = 1; // 1 CI, 2 Pasaporte

  final _cNombre = TextEditingController();
  final _cApellido = TextEditingController();
  final _cDocumento = TextEditingController();

  DateTime _date = DateTime.now();
  final _storage = const FlutterSecureStorage();

  bool _loaderOpen = false;

  @override
  void dispose() {
    _cNombre.dispose();
    _cApellido.dispose();
    _cDocumento.dispose();
    super.dispose();
  }

  // ------- Helpers locales -------
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
        content: Text(msg, style: regular(gris7, 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: semibold(amber, 14)),
          ),
        ],
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
    ).then((_) {
      _loaderOpen = false;
    });
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

      // cálculo rápido por año (suficiente para clasificación ADUT/CHILD/INF)
      final years = DateTime.now().year - picked.year;
      if (years < 2) {
        tipoPersona = 'INF';
      } else if (years <= 11) {
        tipoPersona = 'CHILD';
      } else {
        tipoPersona = 'ADUT';
      }
      fechaNac = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || fechaNac == null) {
      _showSnack('Ingresá todos los datos', error: true);
      return;
    }

    final base = (await _storage.read(key: 'api_base_url')) ?? '';
    final token = (await _storage.read(key: 'auth_token')) ?? '';

    if (base.isEmpty || token.isEmpty) {
      await _showErrorDialog('Error', 'No se encontraron credenciales locales');
      return;
    }

    final url = Uri.parse('${base.endsWith('/') ? base : '$base/'}registrarPersona');
    final payload = {
      "personas": [
        {
          "nombre": (nombre ?? '').toUpperCase(),
          "apellido": (apellido ?? '').toUpperCase(),
          "genero": genero.toUpperCase(),
          "fecha_nacimiento": fechaNac!,
          "id_documento": idDocumento,
          "numero_documento": (numeroDocumento ?? '').toUpperCase(),
          "telefono": "",
          "email": "",
          "tipo_persona": tipoPersona, // ADUT | CHILD | INF
        }
      ]
    };

    _openLoader();

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      _closeLoader();

      if (!mounted) return;

      if (res.statusCode == 401) {
        _showSnack('Usuario no autenticado', error: true);
        Future.delayed(const Duration(milliseconds: 400), () {
          Navigator.of(context).pushNamedAndRemoveUntil('/h', (route) => false);
        });
        return;
      }

      if (res.statusCode != 200) {
        await _showErrorDialog('Error', 'Fallo ${res.statusCode}: ${res.body}');
        return;
      }

      final body = jsonDecode(res.body);
      if (body['estado'] == 200) {
        _showSnack(body['message'] ?? 'Pasajero creado');
        Navigator.pop(context, {'created': true}); // señal para refrescar lista
      } else {
        await _showErrorDialog('Error', body['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      _closeLoader();
      await _showErrorDialog('Excepción', e.toString());
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

                      Row(
                        children: [
                          Text('Tipo de Pasajero: ', style: regular(gris7, 14)),
                          Text(
                            tipoPersona == 'ADUT'
                                ? 'Adulto'
                                : tipoPersona == 'CHILD'
                                    ? 'Niño'
                                    : 'Bebé',
                            style: semibold(blackBeePay, 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

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
                          onChanged: (v) {
                            setState(() {
                              idDocumento = (v == 'Carnet de identidad') ? 1 : 2;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text('Número de Documento:', style: regular(gris7, 14)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cDocumento,
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
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
