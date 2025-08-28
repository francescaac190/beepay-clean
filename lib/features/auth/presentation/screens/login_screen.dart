// lib/features/auth/presentation/screens/login_screen.dart
import 'dart:io';
import 'package:beepay/core/cores.dart';
import 'package:beepay/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:beepay/core/config/app_config.dart'; // <- para imprimir env/baseUrl
import '../../../../core/config/secure_storage_service.dart';
import '../../../../core/services/filesystem_manager.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/loginbackground.dart';

/// ---- Helper de logs ----
void _dlog(String tag, String msg) {
  final ts = DateTime.now().toIso8601String();
  // Usa print en vez de debugPrint para no truncar logs largos
  print('[LOGIN][$tag][$ts] $msg');
}

String _maskToken(String? t) {
  if (t == null || t.isEmpty) return 'null';
  if (t.length <= 10) return '${t.substring(0, t.length ~/ 2)}...';
  return '${t.substring(0, 6)}...${t.substring(t.length - 4)}';
}

class LoginStructure extends StatefulWidget {
  const LoginStructure({super.key});

  @override
  State<LoginStructure> createState() => _LoginStructureState();
}

class _LoginStructureState extends State<LoginStructure> {
  @override
  Widget build(BuildContext context) {
    _dlog('STRUCT', 'Build LoginStructure');
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          LoginBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: const LoginWidgets(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginWidgets extends StatelessWidget {
  const LoginWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    _dlog('WIDGETS', 'Render LoginWidgets');
    return Column(
      children: [
        addVerticalSpace(250),
        LoginScreen(),
      ],
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  final TextEditingController celController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();
  final fileSystem = sl<FileSystemManager>();

  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _bootDiagnostics();
  }

  Future<void> _bootDiagnostics() async {
    _dlog('BOOT', 'Iniciando diagnósticos de login...');
    _dlog('BOOT', 'Env: ${AppConfig.environment}');
    _dlog('BOOT', 'BaseURL: ${AppConfig.baseurl}');
    _dlog('BOOT', 'Biometrico flag (FileSystemManager): ${fileSystem.biometrico}');
    try {
      final saved = await SecureStorageService.instance.getToken();
      _dlog('BOOT', 'Token guardado: ${_maskToken(saved)} (existe=${saved != null && saved.isNotEmpty})');
    } catch (e) {
      _dlog('BOOT', 'Error leyendo token de SecureStorage: $e');
    }
    await _getDeviceId(); // solo diagnósticos, no cambia lógica de login
    _dlog('BOOT', 'DeviceId detectado: ${_deviceId ?? 'null'}');
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
    _dlog('UI', 'Toggle password. obscure=$_obscureText');
  }

  /// 📌 **Obtener el Device ID**
  Future<void> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String id = "";

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.id;
        _dlog('DEVICE', 'Android ID: $id');
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? "No disponible";
        _dlog('DEVICE', 'iOS ID: $id');
      } else {
        _dlog('DEVICE', 'Plataforma no soportada para deviceId');
      }
    } catch (e) {
      id = "Error obteniendo Device ID: $e";
      _dlog('DEVICE', id);
    }

    setState(() {
      _deviceId = id;
    });
  }

  /// 📌 **Autenticación Biométrica**
  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    _dlog('BIO', 'Iniciando authenticate()...');
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Escanea para ingresar a tu cuenta',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on Exception catch (e) {
      _dlog('BIO', 'Excepción en authenticate(): $e');
    }
    _dlog('BIO', 'Resultado authenticate(): $authenticated');
    _dlog('BIO', 'DeviceId actual: ${_deviceId ?? 'null'}');
    if (authenticated) {
      _loginWithBiometrics();
    }
  }

  /// 📌 **Login con Biometría**
  Future<void> _loginWithBiometrics() async {
    if (_deviceId == null) {
      _dlog('BIO', 'DeviceId es null. Mostrando snackbar.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No se pudo obtener el Device ID")),
      );
      return;
    }
    _dlog('BIO', 'Dispatch LoginBiometricEvent(deviceId=$_deviceId)');
    try {
      BlocProvider.of<AuthBloc>(context).add(LoginBiometricEvent(_deviceId!));
    } catch (e) {
      _dlog('BIO', 'Error al enviar LoginBiometricEvent: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    _dlog('SCREEN', 'Build LoginScreen');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('INICIO DE SESIÓN', style: semibold(gris4, 15)),
            addVerticalSpace(20),

            // ====== BOTÓN BIOMÉTRICO ======
            fileSystem.biometrico == true
                ? BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      _dlog('BLOC', 'Listener biometría -> ${state.runtimeType}');
                      if (state is AuthAuthenticated) {
                        cerrarDialogoCargando(context);
                        _dlog('BLOC', 'AuthAuthenticated (biométrico). Mensaje OK. Navegación no automática aquí.');
                      } else if (state is AuthLoading) {
                        _dlog('BLOC', 'AuthLoading (biométrico). Mostrando loader.');
                        dialogCargando(context, true);
                      } else if (state is AuthError) {
                        _dlog('BLOC', 'AuthError (biométrico): ${state.message}');
                        cerrarDialogoCargando(context);
                        MensajeError(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          if (_deviceId == null || _deviceId!.isEmpty) {
                            _dlog('BIO', 'Tap FaceID: deviceId null/empty. Intentando obtener...');
                            _getDeviceId();
                          }
                          _dlog('BIO', 'Tap FaceID -> LoginBiometricEvent con deviceId=${_deviceId ?? 'null'}');
                          BlocProvider.of<AuthBloc>(context).add(
                            LoginBiometricEvent(_deviceId ?? ''),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.amber.withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            "assets/iconos/Face_ID_logo 1.png",
                            height: 70,
                          ),
                        ),
                      );
                    },
                  )
                : Container(),

            // ====== CAMPOS LOGIN NORMAL ======
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 25, 8),
              child: TextFormField(
                controller: celController,
                cursorColor: gris4,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.phone, color: Colors.grey.shade800),
                  labelText: 'Número de celular',
                  labelStyle: medium(gris4, 15),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
                  ),
                ),
                validator: (value) {
                  final valid = value != null && value.isNotEmpty;
                  if (!valid) {
                    _dlog('VALID', 'Cel inválido (vacío).');
                    return 'Por favor ingresá tu número';
                  }
                  return null;
                },
                style: medium(blackBeePay, 16),
              ),
            ),
            addVerticalSpace(8),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 25, 8),
              child: TextFormField(
                obscureText: _obscureText,
                controller: passwordController,
                cursorColor: gris4,
                decoration: InputDecoration(
                  focusColor: amber,
                  icon: Icon(Icons.key, color: Colors.grey.shade800),
                  labelText: 'Contraseña',
                  labelStyle: medium(gris4, 15),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: GestureDetector(
                      onTap: _toggle,
                      child: Icon(
                        _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 24,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  final valid = value != null && value.isNotEmpty;
                  if (!valid) {
                    _dlog('VALID', 'Password inválida (vacía).');
                    return 'Por favor ingresá tu contraseña';
                  }
                  return null;
                },
                style: medium(blackBeePay, 16),
              ),
            ),

            // ====== ENLACE RECUPERAR ======
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
              child: InkWell(
                onTap: () {
                  _dlog('NAV', 'Tap recuperar password -> /recupera');
                  Navigator.pushNamed(context, '/recupera');
                },
                child: Text("¿Olvidaste tu contraseña o tu cuenta?", style: medium(verde, 15)),
              ),
            ),
            addVerticalSpace(20),

            // ====== LOGIN NORMAL (con Bloc propio interno, como el original) ======
            BlocProvider(
              create: (context) => sl<AuthBloc>(),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) async {
                  _dlog('BLOC', 'Listener normal -> ${state.runtimeType}');
                  if (state is AuthAuthenticated) {
                    cerrarDialogoCargando(context);
                    _dlog('BLOC', 'AuthAuthenticated. Navegando a /home');
                    Navigator.pushNamed(context, '/home');
                  } else if (state is AuthLoading) {
                    _dlog('BLOC', 'AuthLoading. Mostrando loader');
                    dialogCargando(context, true);
                  } else if (state is AuthError) {
                    _dlog('BLOC', 'AuthError: ${state.message}');
                    cerrarDialogoCargando(context);
                    MensajeError(context, state.message);
                  }
                },
                builder: (context, state) {
                  return CustomButton(
                    text: 'Ingresar',
                    textColor: blanco,
                    height: 50,
                    width: double.infinity,
                    color: amber,
                    onPressed: () {
                      final valid = _formKey.currentState!.validate();
                      _dlog('ACTION', 'Tap Ingresar. valid=$valid cel=${celController.text} passLen=${passwordController.text.length}');
                      if (valid) {
                        try {
                          _dlog('BLOC', 'Dispatch LoginEvent(cel="${celController.text}", passLen=${passwordController.text.length})');
                          BlocProvider.of<AuthBloc>(context).add(
                            LoginEvent(
                              celController.text,
                              passwordController.text,
                            ),
                          );
                        } catch (e) {
                          _dlog('BLOC', 'Error al enviar LoginEvent: $e');
                          MensajeError(context, 'Error interno enviando LoginEvent');
                        }
                      }
                    },
                  );
                },
              ),
            ),

            addVerticalSpace(16),

            // ====== REGISTRO ======
            CustomButton(
              height: 50,
              width: double.infinity,
              color: amberClaro,
              textColor: amber,
              onPressed: () {
                _dlog('NAV', 'Tap registrate -> /register');
                Navigator.pushNamed(context, '/register');
              },
              text: "Registrate",
            ),
            addVerticalSpace(20),
          ],
        ),
      ),
    );
  }
}
