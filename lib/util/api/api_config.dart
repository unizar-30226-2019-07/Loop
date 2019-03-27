import 'package:flutter/services.dart' show rootBundle;

/// Configuración de conexión con la API
class APIConfig {

  /// URL base a conectar (con puerto)
  static const BASE_URL = "http://35.234.77.87:8080";
  /// Token de acceso para poder realizar peticiones (incluirlo en header)
  /// para obtener el token emplear [getToken()]
  static String _token;

  static Future<String> getToken() async {
    if (_token == null) {
      _token = await rootBundle.loadString('assets/api_token');
    }
    return _token;
  }

}