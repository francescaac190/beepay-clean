import '../entities/banner_entity.dart';
import '../repositories/home_repository.dart';

class GetBannersUseCase {
  final HomeRepository repository;

  GetBannersUseCase(this.repository);

  Future<List<BannerEntity>> call() async {
    final banner = await repository.getBanners();

    if (banner != null) {
      return banner;
    } else {
      throw Exception("Error: No se pudo obtener los banners.");
    }
  }
}
