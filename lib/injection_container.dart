import 'package:beepay/features/home/presentation/bloc/perfil_bloc.dart';
import 'package:beepay/features/resetpw/data/datasources/recupera_remote_data_source.dart';
import 'package:beepay/features/resetpw/data/repositories/recupera_repository_impl.dart';
import 'package:beepay/features/resetpw/domain/repositories/recupera_repository.dart';
import 'package:beepay/features/resetpw/domain/usecases/actualiza_pass_usecase.dart';
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
  // ✅ Registrar FileSystemManager como Singleton
  sl.registerSingleton<FileSystemManager>(FileSystemManager.instance);

  // 📌 Registro de AuthBloc con los dos casos de uso
  sl.registerFactory(() => AuthBloc(sl(), sl()));

  // 📌 Registro de UseCases
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

  // 📌 Registro de Repositorios
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<RegisterRepository>(
    () => RegisterRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RecuperaRepository>(
    () => RecuperaRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: sl()));

  // 📌 Registro de DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RegisterRemoteDataSource>(
    () => RegisterRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RecuperaRemoteDataSource>(
    () => RecuperaRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(dio: sl()));

  // 📌 Registro de RegisterBloc
  sl.registerFactory(() => RegisterBloc(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => RecuperaBloc(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => PerfilBloc(sl<GetCompletoUseCase>()));
  sl.registerFactory(() => SaldoBloc(sl()));
  sl.registerFactory(() => BannerBloc(sl()));

  // 📌 Registro de Librerías Externas
  sl.registerLazySingleton(() => Dio()); // Cliente HTTP
  sl.registerLazySingleton(
      () => FlutterSecureStorage()); // Almacenamiento Seguro
}
