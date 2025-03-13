import 'package:beepay/features/home/domain/repositories/home_repository.dart';
import 'package:beepay/features/home/domain/entities/perfil_entity.dart';

import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/saldo_entity.dart';
import '../datasources/home_remote_datasources.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Perfil> getCompleto() async {
    return await remoteDataSource.getCompleto();
  }

  @override
  Future<SaldoEntity> getSaldo() async {
    final saldo = await remoteDataSource.getSaldo();
    if (saldo == null) {
      throw Exception("Error: El API devolvió un saldo nulo");
    }
    return saldo;
  }

  @override
  Future<List<BannerEntity>> getBanners() async {
    return await remoteDataSource.getBanners();
  }
}
