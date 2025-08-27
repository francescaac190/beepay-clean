import 'dart:io';

import 'package:beepay/core/config/app_config.dart';
import 'package:beepay/features/home/presentation/bloc/perfil_bloc.dart';
import 'package:beepay/features/resetpw/data/datasources/recupera_remote_data_source.dart';
import 'package:beepay/features/resetpw/data/repositories/recupera_repository_impl.dart';
import 'package:beepay/features/resetpw/domain/repositories/recupera_repository.dart';
import 'package:beepay/features/resetpw/domain/usecases/actualiza_pass_usecase.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/services/filesystem_manager.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/login_biometric_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/data/datasources/home_remote_datasources.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/banner_usecase.dart';
import 'features/home/domain/usecases/perfil_usecase.dart';
import 'features/home/domain/usecases/saldo_usecase.dart';
import 'features/home/presentation/bloc/banner_bloc.dart';
import 'features/home/presentation/bloc/saldo_bloc.dart';
import 'features/register/data/datasources/register_remote_data_source.dart';
import 'features/register/data/repositories/register_repository_impl.dart.dart';
import 'features/register/domain/repositories/register_repository.dart';
import 'features/register/domain/usecases/check_user_usecase.dart';
import 'features/register/domain/usecases/register_usecase.dart';
import 'features/register/domain/usecases/send_otp_usecase.dart';
import 'features/register/domain/usecases/verify_otp_usecase.dart';
import 'features/register/presentation/bloc/register_bloc.dart';
import 'features/resetpw/domain/usecases/cuenta_rec_usecase.dart';
import 'features/resetpw/domain/usecases/recupera_cuenta_usecase.dart';
import 'features/resetpw/domain/usecases/recupera_usecase.dart';
import 'features/resetpw/presentation/bloc/recupera_bloc.dart';

final sl = GetIt.instance;

void init() {
  // ✅ FileSystemManager
  sl.registerSingleton<FileSystemManager>(FileSystemManager.instance);

  // ✅ UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LoginBiometricUseCase(sl()));
  sl.registerLazySingleton(() => CheckUserUseCase(sl()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => RecuperaUsecase(sl()));
  sl.registerLazySingleton(() => RecuperaCuentaUsecase(sl()));
  sl.registerLazySingleton(() => CuentaRecUseCase(sl()));
  sl.registerLazySingleton(() => ActualizaPassUsecase(sl()));
  sl.registerLazySingleton(() => GetCompletoUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => GetSaldoUseCase(sl()));
  sl.registerLazySingleton(() => GetBannersUseCase(sl()));

  // ✅ DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<RegisterRemoteDataSource>(() => RegisterRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<RecuperaRemoteDataSource>(() => RecuperaRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(dio: sl()));

  // ✅ Repos
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), secureStorage: sl()));
  sl.registerLazySingleton<RegisterRepository>(() => RegisterRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<RecuperaRepository>(() => RecuperaRepositoryImpl(remoteDatasource: sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(remoteDataSource: sl()));

  // ✅ Blocs
  sl.registerFactory(() => AuthBloc(sl(), sl()));
  sl.registerFactory(() => RegisterBloc(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => RecuperaBloc(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => PerfilBloc(sl<GetCompletoUseCase>()));
  sl.registerFactory(() => SaldoBloc(sl()));
  sl.registerFactory(() => BannerBloc(sl()));

  // ✅ Librerías Externas
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // ⬇️ ⬇️ AQUÍ LA CONFIG DE DIO CON TIMEOUTS + LOGS ⬇️ ⬇️
  sl.registerLazySingleton<Dio>(() {
    final opts = BaseOptions(
      baseUrl: AppConfig.baseurl, // ej: https://stage.justbeesolutions.com/beeapi/api/
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.json,
      followRedirects: true,
      validateStatus: (code) => code != null && code >= 200 && code < 600,
    );

    final dio = Dio(opts);

    String _ts() => DateTime.now().toIso8601String();

    void _logReq(RequestOptions o) {
      print('[DIO][REQ][${_ts()}] ${o.method} ${o.uri}');
      print('[DIO][REQ][${_ts()}] baseUrl=${o.baseUrl} headers=${o.headers}');
      print('[DIO][REQ][${_ts()}] data=${o.data}');
    }

    void _logRes(Response r) {
      print('[DIO][RES][${_ts()}] status=${r.statusCode} url=${r.requestOptions.uri}');
      print('[DIO][RES][${_ts()}] data=${r.data}');
    }

    void _logErr(DioException e) {
      print('[DIO][ERR][${_ts()}] type=${e.type} message=${e.message}');
      print('[DIO][ERR][${_ts()}] url=${e.requestOptions.uri}');
      print('[DIO][ERR][${_ts()}] status=${e.response?.statusCode}');
      print('[DIO][ERR][${_ts()}] data=${e.response?.data}');
      print('[DIO][ERR][${_ts()}] error=${e.error}');
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (o, h) { _logReq(o); h.next(o); },
      onResponse: (r, h) { _logRes(r); h.next(r); },
      onError:   (e, h) { _logErr(e); h.next(e); },
    ));

    // Adapter nativo: afina HttpClient (timeouts de socket, TLS, etc)
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
    adapter.createHttpClient = () {
      final c = HttpClient();
      c.connectionTimeout = const Duration(seconds: 25);

      // ⚠️ SOLO PARA DIAGNÓSTICO EN STAGE CON CERT SELF-SIGNED:
      // c.badCertificateCallback = (X509Certificate cert, String host, int port) {
      //   print('[TLS][${_ts()}] host=$host port=$port subject=${cert.subject}');
      //   return true; // ← NO dejar activo en producción
      // };

      return c;
    };

    print('[DI][DIO] baseUrl=${opts.baseUrl} '
          'connectTO=${opts.connectTimeout} recvTO=${opts.receiveTimeout} sendTO=${opts.sendTimeout}');
    return dio;
  });
}