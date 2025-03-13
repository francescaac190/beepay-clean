import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get environment => dotenv.env['ENVIRONMENT'] ?? "test";

  // Base y protocolo
  static String get base => environment == "prod"
      ? dotenv.env['BASE_PROD'] ?? "admin"
      : dotenv.env['BASE_TEST'] ?? "stage";

  // Base URL dinámica
  static String get baseurl => "https://$base.justbeesolutions.com/beeapi/api/";

  // URLs específicas
  static String get url => environment == "prod"
      ? dotenv.env['URL_COM_PROD'] ?? ""
      : dotenv.env['URL_COM_TEST'] ?? "";

  static String get urlConsul => environment == "prod"
      ? dotenv.env['URL_CONSUL_PROD'] ?? ""
      : dotenv.env['URL_CONSUL_TEST'] ?? "";

  // Credenciales
  static String get user => environment == "prod"
      ? dotenv.env['USER_PROD'] ?? ""
      : dotenv.env['USER_TEST'] ?? "";

  static String get pass => environment == "prod"
      ? dotenv.env['PASS_PROD'] ?? ""
      : dotenv.env['PASS_TEST'] ?? "";

  // Identificadores de Comercio
  static String get idCom => environment == "prod"
      ? dotenv.env['ID_COM_PROD'] ?? ""
      : dotenv.env['ID_COM_TEST'] ?? "";

  static String get idRec => environment == "prod"
      ? dotenv.env['ID_REC_PROD'] ?? ""
      : dotenv.env['ID_REC_TEST'] ?? "";
}
