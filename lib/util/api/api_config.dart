import 'package:selit/util/seruser.dart';

/// Configuración de conexión con la API
class APIConfig {

  /// URL base a conectar (con puerto)
  static const BASE_URL = "http://selit.naval.cat:8080";
  /// Token de acceso para poder realizar peticiones (incluirlo en header)
  /// para obtener el token emplear [getToken()]
  static String _token;

  // TODO mover a otro sitio
  static Future<String> getToken() async {
    if (_token == null) {
      _token = await storage.read(key: 'token');
    }
    return _token;
  }

}