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
    final j = json;

    final tarjetasJson = (j['tarjetas'] as List? ?? []);
    final facturacionJson = (j['facturacion'] as List? ?? []);

    return PerfilModel(
      id: j['id'] ?? 0,
      name: (j['name'] ?? '').toString(),
      apellido: (j['apellido'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      ci: (j['ci'] ?? '').toString(),
      cel: (j['cel'] ?? '').toString(),

      // Estos vienen null en tu log → convertir a ''
      fechaNacimiento: (j['fecha_nacimiento'] ?? '').toString(),
      sexo: (j['sexo'] ?? '').toString(),
      pais: (j['pais'] ?? '').toString(),
      ciudad: (j['ciudad'] ?? '').toString(),
      direccion: (j['direccion'] ?? '').toString(),

      categoria: (j['categoria'] ?? '').toString(),
      logoCategoria: (j['logo_categoria'] ?? '').toString(),

      // En muchas respuestas no vienen; normalizamos a ''
      fotoPerfil: (j['foto_perfil'] ?? '').toString(),
      codigo: (j['codigo'] ?? '').toString(),

      tarjetas: tarjetasJson.map((t) {
        final tt = t as Map<String, dynamic>? ?? {};
        return Tarjeta(
          nombre: (tt['nombre'] ?? '').toString(),
          token: (tt['token'] ?? '').toString(),
          tarjeta: (tt['tarjeta'] ?? '').toString(),
          marca: (tt['marca'] ?? '').toString(),
          expiracion: (tt['expiracion'] ?? '').toString(),
        );
      }).toList(),

      facturacion: facturacionJson.map((f) {
        final ff = f as Map<String, dynamic>? ?? {};
        return Facturacion(
          id: (ff['id'] is int) ? (ff['id'] ?? 0) : int.tryParse('${ff['id']}') ?? 0,
          nit: (ff['nit'] ?? '').toString(),
          razonSocial: (ff['razon_social'] ?? '').toString(),
        );
      }).toList(),
    );
  }

  static PerfilModel fromRawJson(String str) =>
      PerfilModel.fromJson(json.decode(str));
}
