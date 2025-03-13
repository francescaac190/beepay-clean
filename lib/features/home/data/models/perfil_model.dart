import 'dart:convert';
import '../../domain/entities/perfil_entity.dart';

class PerfilModel extends Perfil {
  PerfilModel({
    required int id,
    required String name,
    required String apellido,
    required String email,
    required String ci,
    required String cel,
    required String fechaNacimiento,
    required String sexo,
    required String categoria,
    required String logoCategoria,
    required String pais,
    required String ciudad,
    required String direccion,
    required String fotoPerfil,
    required String codigo,
    required List<Tarjeta> tarjetas,
    required List<Facturacion> facturacion,
  }) : super(
          id: id,
          name: name,
          apellido: apellido,
          email: email,
          ci: ci,
          cel: cel,
          fechaNacimiento: fechaNacimiento,
          sexo: sexo,
          categoria: categoria,
          logoCategoria: logoCategoria,
          pais: pais,
          ciudad: ciudad,
          direccion: direccion,
          fotoPerfil: fotoPerfil,
          codigo: codigo,
          tarjetas: tarjetas,
          facturacion: facturacion,
        );

  factory PerfilModel.fromJson(Map<String, dynamic> json) {
    return PerfilModel(
      id: json["id"],
      name: json["name"],
      apellido: json["apellido"],
      email: json["email"],
      ci: json["ci"],
      cel: json["cel"],
      fechaNacimiento: json["fecha_nacimiento"],
      sexo: json["sexo"],
      categoria: json["categoria"],
      logoCategoria: json["logo_categoria"],
      pais: json["pais"],
      ciudad: json["ciudad"],
      direccion: json["direccion"],
      fotoPerfil: json["foto_perfil"],
      codigo: json["codigo"],
      tarjetas: (json["tarjetas"] as List)
          .map((tarjeta) => Tarjeta(
                nombre: tarjeta["nombre"],
                token: tarjeta["token"],
                tarjeta: tarjeta["tarjeta"],
                marca: tarjeta["marca"],
                expiracion: tarjeta["expiracion"],
              ))
          .toList(),
      facturacion: (json["facturacion"] as List)
          .map((fact) => Facturacion(
                id: fact["id"],
                nit: fact["nit"],
                razonSocial: fact["razon_social"],
              ))
          .toList(),
    );
  }

  static PerfilModel fromRawJson(String str) =>
      PerfilModel.fromJson(json.decode(str));
}
