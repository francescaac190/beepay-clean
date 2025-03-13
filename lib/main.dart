import 'package:beepay/core/config/app_config.dart';
import 'package:beepay/features/home/presentation/bloc/perfil_bloc.dart';
import 'package:beepay/features/resetpw/presentation/bloc/recupera_bloc.dart';
import 'package:beepay/injection_container.dart';
import 'package:beepay/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/filesystem_manager.dart';
import 'features/features.dart';
import 'features/home/presentation/bloc/banner_bloc.dart';
import 'features/home/presentation/bloc/saldo_bloc.dart';
import 'features/register/presentation/bloc/register_bloc.dart';
import 'injection_container.dart' as di;

import 'core/cores.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env"); // Cargar variables de entorno
  init();
  await checkBiometricSupport();

  print("Base URL: ${AppConfig.baseurl}");
  print("Usuario: ${AppConfig.user}");
  print("Contraseña: ${AppConfig.pass}");
  runApp(const MyApp());
}

Future<void> checkBiometricSupport() async {
  final LocalAuthentication auth = LocalAuthentication();
  bool canCheckBiometrics = await auth.canCheckBiometrics;
  bool isDeviceSupported = await auth.isDeviceSupported();

  bool hasBiometric = canCheckBiometrics && isDeviceSupported;

  FileSystemManager.instance.biometrico = hasBiometric;

  print("Biometría disponible: $hasBiometric");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<RegisterBloc>()),
        BlocProvider(create: (_) => sl<RecuperaBloc>()),
        BlocProvider(
            create: (context) => sl<PerfilBloc>()..add(GetPerfilEvent())),
        BlocProvider(
          create: (context) => sl<SaldoBloc>()
            ..add(GetSaldoEvent()), // Inicia la carga del saldo
        ),
        BlocProvider(
          create: (context) => sl<BannerBloc>(),
        ),
      ],
      child: MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        theme: ThemeData(
          colorScheme: const ColorScheme(
            primary: amber,
            primaryContainer: amberOscuro,
            secondary: amberClaro,
            secondaryContainer: amber,
            surface: blanco,
            background: blanco,
            error: rojo,
            onPrimary: blanco,
            onSecondary: blanco,
            onSurface: blackBeePay,
            onBackground: blackBeePay,
            onError: blanco,
            brightness: Brightness.light,
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('es', 'ES'), // Spanish
          // Add more locales if needed
        ],
        title: 'BeePay',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginStructure(),
          '/register': (context) => RegisterScreen(),
          '/recupera': (context) => RecuperaScreen(),
          '/ver_cuenta': (context) => VerCuentaScreen(),
          '/home': (context) => HomeMain(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/otp') {
            final args = settings.arguments as Map<String, String>?;

            return MaterialPageRoute(
              builder: (context) => OtpScreen(
                name: args!['name']!,
                apellido: args['apellido']!,
                cel: args['cel']!,
                ci: args['ci']!,
                email: args['email']!,
                password: args['password']!,
                password_confirmation: args['password_confirmation']!,
                codigo: args['codigo']!,
              ),
            );
          } else if (settings.name == '/reset_password') {
            final args = settings.arguments as Map<String, String>?;

            return MaterialPageRoute(
              builder: (context) => NewPass(
                email: args!['email']!,
                verificacion: args['verificacion']!,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
