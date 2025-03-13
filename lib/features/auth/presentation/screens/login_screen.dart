import 'dart:io';
import 'package:beepay/core/cores.dart';
import 'package:beepay/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../core/config/secure_storage_service.dart';
import '../../../../core/services/filesystem_manager.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/loginbackground.dart';

class LoginStructure extends StatefulWidget {
  const LoginStructure({super.key});

  @override
  State<LoginStructure> createState() => _LoginStructureState();
}

class _LoginStructureState extends State<LoginStructure> {
  @override
  Widget build(BuildContext context) {
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
                physics: BouncingScrollPhysics(),
                child: LoginWidgets(),
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

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  /// 📌 **Obtener el Device ID**
  Future<void> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String id = "";

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? "No disponible";
      }
    } catch (e) {
      id = "Error obteniendo Device ID: $e";
    }

    setState(() {
      _deviceId = id;
      print(_deviceId);
    });
  }

  /// 📌 **Autenticación Biométrica**
  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Escanea para ingresar a tu cuenta',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on Exception catch (e) {
      print(e);
    }
    print('authenticated: $authenticated');
    print(_deviceId);
    if (authenticated) {
      _loginWithBiometrics();
    }
  }

  /// 📌 **Login con Biometría**
  Future<void> _loginWithBiometrics() async {
    if (_deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: No se pudo obtener el Device ID")),
      );
      return;
    }

    BlocProvider.of<AuthBloc>(context).add(
      LoginBiometricEvent(_deviceId!), // ⬅ Login con Biometría
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
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
            Text(
              'INICIO DE SESIÓN',
              style: semibold(gris4, 15),
            ),
            addVerticalSpace(20),
            fileSystem.biometrico == true
                ? BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        cerrarDialogoCargando(context);

                        print('home biometrico');
                      } else if (state is AuthLoading) {
                        dialogCargando(context, true);
                      } else if (state is AuthError) {
                        cerrarDialogoCargando(context);
                        MensajeError(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<AuthBloc>(context).add(
                            LoginBiometricEvent(_deviceId!),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.amber.withOpacity(0.1),
                          padding: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset("assets/iconos/Face_ID_logo 1.png",
                              height: 70),
                        ),
                      );
                    },
                  )
                : Container(),
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
                    borderSide: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
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
                    borderSide: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: GestureDetector(
                      onTap: _toggle,
                      child: Icon(
                        _obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 24,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresá tu contraseña';
                  }
                  return null;
                },
                style: medium(blackBeePay, 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/recupera');
                },
                child: Text(
                  "¿Olvidaste tu contraseña o tu cuenta?",
                  style: medium(verde, 15),
                ),
              ),
            ),
            addVerticalSpace(20),
            BlocProvider(
              create: (context) => sl<AuthBloc>(),
              child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) async {
                if (state is AuthAuthenticated) {
                  cerrarDialogoCargando(context);
                  Navigator.pushNamed(context, '/home');
                } else if (state is AuthLoading) {
                  dialogCargando(context, true);
                } else if (state is AuthError) {
                  cerrarDialogoCargando(context);
                  MensajeError(context, state.message);
                }
              }, builder: (context, state) {
                return CustomButton(
                  text: 'Ingresar',
                  textColor: blanco,
                  height: 50,
                  width: double.infinity,
                  color: amber,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      BlocProvider.of<AuthBloc>(context).add(
                        LoginEvent(
                          celController.text,
                          passwordController.text,
                        ), // login con Celular
                      );
                    }
                  },
                );
              }),
            ),
            addVerticalSpace(16),
            CustomButton(
              height: 50,
              width: double.infinity,
              color: amberClaro,
              textColor: amber,
              onPressed: () {
                print('registrar');
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
