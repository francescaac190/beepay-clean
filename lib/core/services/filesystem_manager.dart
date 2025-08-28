import '../../features/home/domain/entities/perfil_entity.dart';

/// ✅ **Clase para Almacenamiento Temporal en Memoria**
class FileSystemManager {
  // LOGIN
  bool? biometrico = false;

  //OTP
  String? otp;

  String? idUsuario;
  String? nombre;
  String? email;
   String? cel;  
  String? categoria;
  String? fotoPerfil;

  void setPerfil(Perfil perfil) {
    idUsuario = perfil.id.toString();
    nombre = perfil.name;
    email = perfil.email;
    cel        = perfil.cel; 
    categoria = perfil.categoria;
    fotoPerfil = perfil.fotoPerfil;
  }

  static final FileSystemManager _instance = FileSystemManager._internal();

  FileSystemManager._internal();

  static FileSystemManager get instance => _instance;
}
