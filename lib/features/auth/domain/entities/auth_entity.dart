class AuthEntity {
  final int estado;
  final String mensaje;
  final String? token;

  const AuthEntity({
    required this.estado,
    required this.mensaje,
    this.token,
  });
}
