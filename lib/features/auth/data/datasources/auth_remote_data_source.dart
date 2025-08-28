import 'dart:io';
import 'package:beepay/core/config/app_config.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/secure_storage_service.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String cel, String password);
  Future<AuthModel> loginBiometric(String deviceId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl({required this.dio});

  // ---- Diag helpers ---------------------------------------------------------
  String _ts() => DateTime.now().toIso8601String();

  Future<void> _netDiag(String baseUrl) async {
    final uri = Uri.parse(baseUrl);
    final host = uri.host.isEmpty ? baseUrl.replaceAll(RegExp(r'^https?://'), '') : uri.host;

    print('[NET-DIAG][${_ts()}] baseUrl=$baseUrl host=$host');

    try {
      final ips = await InternetAddress.lookup(host);
      print('[NET-DIAG][${_ts()}] DNS A/AAAA => ${ips.map((e)=>'${e.address}(${e.type.name})').join(', ')}');
    } catch (e) {
      print('[NET-DIAG][${_ts()}] DNS lookup FAILED: $e');
    }

    try {
      final s = await Socket.connect(host, 443, timeout: const Duration(seconds: 5));
      print('[NET-DIAG][${_ts()}] TCP 443 OK local=${s.address.address}:${s.port} remote=${s.remoteAddress.address}:${s.remotePort}');
      s.destroy();
    } catch (e) {
      print('[NET-DIAG][${_ts()}] TCP 443 FAIL: $e');
    }

    try {
      // Prueba HTTPS rápida (puede devolver 404/405, igual sirve para medir llegada)
      final _probe = await dio.get(
        baseUrl, // ej: https://stage.../beeapi/api/
        options: Options(
          method: 'GET',
          followRedirects: true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 8),
          validateStatus: (_) => true, // no tirar error por 404
        ),
      );
      print('[NET-DIAG][${_ts()}] HTTPS probe status=${_probe.statusCode} len=${_probe.data?.toString().length}');
    } catch (e) {
      print('[NET-DIAG][${_ts()}] HTTPS probe ERROR: $e');
    }
  }
  // ---------------------------------------------------------------------------

  @override
  Future<AuthModel> login(String cel, String password) async {
    final env = AppConfig.environment;
    final base = AppConfig.baseurl;
    final url = '${AppConfig.baseurl}login';

    print('[AUTH-DS][LOGIN][${_ts()}] ENV=$env | baseUrl=$base');
    print('[AUTH-DS][LOGIN][${_ts()}] POST $url');
    print('[AUTH-DS][LOGIN][${_ts()}] payload={cel:$cel, password:${password.isEmpty ? "<empty>" : "${password.substring(0, 2)}***${password.substring(password.length - 2)}"}}');

    // Preflight de red (logs extra antes del POST real)
    await _netDiag(base);

    try {
      print('[AUTH-DS][REQ][${_ts()}] → Enviando request login...');
      final response = await dio.post(
        url,
        data: {
          'cel': cel,
          'password': password,
        },
        options: Options(
          // timeouts a nivel request (además de los globales del Dio del contenedor)
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('[AUTH-DS][RES][${_ts()}] status=${response.statusCode} url=${response.realUri}');
      print('[AUTH-DS][RES][${_ts()}] headers=${response.headers.map}');
      print('[AUTH-DS][RES][${_ts()}] data=${response.data}');

      if (response.statusCode == 200) {
        final AuthModel auth = AuthModel.fromJson(response.data);

        // ✅ Guardar nuevo token
        await SecureStorageService.instance.saveToken(auth.token);
        print('[AUTH-DS][LOGIN][${_ts()}] ✅ Token actualizado: ${auth.token}');

        return auth;
      } else {
        // servidor respondió pero no 200
        final msg = (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'Error ${response.statusCode} en login';
        print('[AUTH-DS][LOGIN][${_ts()}] ❌ $msg');
        throw Exception(msg);
      }
    } on DioException catch (e) {
      print('[AUTH-DS][ERR][${_ts()}] DioException type=${e.type}');
      print('  message=${e.message}');
      print('  url=${e.requestOptions.uri}');
      print('  status=${e.response?.statusCode}');
      print('  responseData=${e.response?.data}');
      print('  error=${e.error}');

      if (e.response != null) {
        throw Exception(e.response!.data is Map
            ? (e.response!.data['message'] ?? 'Error en login')
            : 'Error en login (${e.response!.statusCode})');
      } else {
        throw Exception("Error de conexión con el servidor");
      }
    } catch (e) {
      print('[AUTH-DS][ERR][${_ts()}] EXCEPTION: $e');
      rethrow;
    }
  }

  @override
  Future<AuthModel> loginBiometric(String deviceId) async {
    final url = '${AppConfig.baseurl}loginBiometrico';
    print('[AUTH-DS][BIO][${_ts()}] POST $url device_id=$deviceId');

    // Preflight rápido
    await _netDiag(AppConfig.baseurl);

    try {
      final response = await dio.post(
        url,
        data: {'device_id': deviceId},
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('[AUTH-DS][BIO][${_ts()}] status=${response.statusCode} data=${response.data}');

      if (response.statusCode == 200) {
        return AuthModel.fromJson(response.data);
      } else {
        throw Exception('Error en login biométrico (${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[AUTH-DS][BIO][${_ts()}] DioException type=${e.type} msg=${e.message} status=${e.response?.statusCode}');
      if (e.response != null) {
        throw Exception(e.response!.data is Map
            ? (e.response!.data['message'] ?? 'Error en login biométrico')
            : 'Error en login biométrico (${e.response!.statusCode})');
      } else {
        throw Exception("Error de conexión con el servidor");
      }
    } catch (e) {
      print('[AUTH-DS][BIO][${_ts()}] EXCEPTION: $e');
      rethrow;
    }
  }
}
