import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  BannerModel({
    required int id,
    required String titulo,
    required String descripcion,
    required String empresa,
    required String imagen,
  }) : super(
          id: id,
          titulo: titulo,
          descripcion: descripcion,
          empresa: empresa,
          imagen: imagen,
        );

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      empresa: json['empresa'],
      imagen: json['imagen'],
    );
  }

  static List<BannerModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => BannerModel.fromJson(json)).toList();
  }
}
