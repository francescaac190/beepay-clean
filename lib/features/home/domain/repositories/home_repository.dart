import 'package:beepay/features/home/domain/entities/saldo_entity.dart';

import '../entities/banner_entity.dart';
import '../entities/perfil_entity.dart';

abstract class HomeRepository {
  Future<Perfil?> getCompleto();
  Future<SaldoEntity?> getSaldo();
  Future<List<BannerEntity>> getBanners();
}
