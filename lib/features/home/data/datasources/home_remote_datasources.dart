import 'package:beepay/core/cores.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/secure_storage_service.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/saldo_entity.dart';
import '../models/banner_model.dart';
import '../models/perfil_model.dart';
import '../models/saldo_model.dart';

abstract class HomeRemoteDataSource {
  Future<PerfilModel> getCompleto();
  Future<SaldoEntity> getSaldo();
  Future<List<BannerEntity>> getBanners();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<PerfilModel> getCompleto() async {
    final token =
        await SecureStorageService.instance.getToken(); // Obtener token

    try {
      final response = await dio.get(
        '${AppConfig.baseurl}get_perfil',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print(response.data);
      if (response.statusCode == 200) {
        final data = response.data["data"];
        return PerfilModel.fromJson(data);
      } else {
        throw Exception("Error al obtener perfil");
      }
    } catch (e) {
      throw Exception("Error al conectar con la API");
    }
  }

  Future<SaldoEntity> getSaldo() async {
    final token =
        await SecureStorageService.instance.getToken(); // Obtener token

    try {
      final response = await dio.get(
        '${AppConfig.baseurl}get_saldo',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print(response.data);

      if (response.statusCode == 200) {
        return SaldoModel.fromJson(response.data);
      } else {
        throw Exception("Error al obtener saldo");
      }
    } catch (e) {
      throw Exception("Error en la conexión");
    }
  }

  @override
  Future<List<BannerEntity>> getBanners() async {
    final token = await SecureStorageService.instance.getToken();
    try {
      final response = await dio.get('${AppConfig.baseurl}get-promo',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          }));

      if (response.statusCode == 200 && response.data['estado'] == 200) {
        return BannerModel.fromJsonList(response.data['datos']);
      } else {
        throw Exception("Error al obtener banners");
      }
    } catch (e) {
      throw Exception("Error en la conexión");
    }
  }
}
