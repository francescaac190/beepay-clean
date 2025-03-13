class Perfil {
  final int id;
  final String name;
  final String apellido;
  final String email;
  final String ci;
  final String cel;
  final String fechaNacimiento;
  final String sexo;
  final String categoria;
  final String logoCategoria;
  final String pais;
  final String ciudad;
  final String direccion;
  final String fotoPerfil;
  final String codigo;

  final List<Tarjeta> tarjetas;
  final List<Facturacion> facturacion;

  Perfil({
    required this.id,
    required this.name,
    required this.apellido,
    required this.email,
    required this.ci,
    required this.cel,
    required this.fechaNacimiento,
    required this.sexo,
    required this.categoria,
    required this.logoCategoria,
    required this.pais,
    required this.ciudad,
    required this.direccion,
    required this.fotoPerfil,
    required this.codigo,
    required this.tarjetas,
    required this.facturacion,
  });
}

class Tarjeta {
  final String nombre;
  final String token;
  final String tarjeta;
  final String marca;
  final String expiracion;

  Tarjeta({
    required this.nombre,
    required this.token,
    required this.tarjeta,
    required this.marca,
    required this.expiracion,
  });
}

class Facturacion {
  final int id;
  final String nit;
  final String razonSocial;

  Facturacion({
    required this.id,
    required this.nit,
    required this.razonSocial,
  });
}
