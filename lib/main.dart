// lib/main.dart
import 'package:beepay/core/config/app_config.dart';
import 'package:beepay/features/home/presentation/bloc/perfil_bloc.dart';
import 'package:beepay/features/resetpw/presentation/bloc/recupera_bloc.dart';
import 'package:beepay/features/resultados/presentation/screens/resultados_screen.dart' show ResultadosScreen;
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

// ======= IMPORTS TRAVEL =======
import 'package:http/http.dart' as http;
import 'features/travel/presentation/screens/travel_screen.dart';
import 'features/travel/presentation/bloc/travel_bloc.dart';
import 'features/travel/presentation/bloc/travel_event.dart';
import 'features/travel/data/datasources/travel_remote_datasource.dart';
import 'features/travel/data/repositories/travel_repository_impl.dart';
// ==============================

// ======= TOKEN (Secure Storage) =======
import 'core/config/secure_storage_service.dart';
// ======================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env"); // Cargar variables de entorno
  init();
  await checkBiometricSupport();

  // ignore: avoid_print
  print("Base URL: ${AppConfig.baseurl}");
  // ignore: avoid_print
  print("Usuario: ${AppConfig.user}");
  // ignore: avoid_print
  print("Contraseña: ${AppConfig.pass}");

  runApp(const MyApp());
}

Future<void> checkBiometricSupport() async {
  final LocalAuthentication auth = LocalAuthentication();
  final bool canCheckBiometrics = await auth.canCheckBiometrics;
  final bool isDeviceSupported = await auth.isDeviceSupported();

  final bool hasBiometric = canCheckBiometrics && isDeviceSupported;

  FileSystemManager.instance.biometrico = hasBiometric;

  // ignore: avoid_print
  print("Biometría disponible: $hasBiometric");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<RegisterBloc>()),
        BlocProvider(create: (_) => sl<RecuperaBloc>()),
        BlocProvider(create: (context) => sl<PerfilBloc>()..add(GetPerfilEvent())),
        BlocProvider(create: (context) => sl<SaldoBloc>()..add(GetSaldoEvent())),
        BlocProvider(create: (context) => sl<BannerBloc>()),
      ],
      child: MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
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
          Locale('en', 'US'),
          Locale('es', 'ES'),
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
          // /travel la dejamos como antes, usando un loader que arma el Bloc
          '/travel': (context) => const TravelRoute(),
          // 👇 OJO: NO declaramos '/resultados' aquí para poder inyectar el bloc por onGenerateRoute
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
          } else if (settings.name == '/resultados') {
            // ⬅️ Recuperamos el bloc desde los argumentos y lo reutilizamos
            final argBloc = settings.arguments as TravelBloc?;
            return MaterialPageRoute(
              builder: (context) {
                if (argBloc == null) {
                  // Si no vino el bloc, mostramos un mensaje claro
                  return const Scaffold(
                    body: Center(
                      child: Text('Falta TravelBloc al navegar a /resultados'),
                    ),
                  );
                }
                return BlocProvider.value(
                  value: argBloc,
                  child: const ResultadosScreen(),
                );
              },
            );
          }
          return null;
        },
      ),
    );
  }
}

/// Loader para /travel que obtiene el token desde SecureStorage y crea el Bloc
class TravelRoute extends StatelessWidget {
  const TravelRoute({super.key});

  Future<String> _loadToken() async {
    final secureToken = await SecureStorageService.instance.getToken();
    return secureToken ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = AppConfig.baseurl;
    return FutureBuilder<String>(
      future: _loadToken(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: blanco,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snap.data ?? '';

        // DataSource + Repo
        final ds = TravelRemoteDataSourceImpl(http.Client());
        final repo = TravelRepositoryImpl(ds);

        return BlocProvider(
          create: (_) => TravelBloc(
            repo: repo,
            baseUrl: baseUrl,
            token: token,
          )..add(TravelLoadAirports()),
          child: const TravelScreen(),
        );
      },
    );
  }
}
