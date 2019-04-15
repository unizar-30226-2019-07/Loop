import 'package:http/http.dart' as http;
import 'dart:convert' as json;

/// Configuración de conexión con la API
class APIConfig {

  /// URL base a conectar (con puerto)
  static const BASE_URL = 'http://selit.naval.cat:8080';

  static String getErrorString(http.Response response) {
    Map<String, dynamic> body = json.jsonDecode(response.body);
    return body['error'] == null ? "Unknown Error" : body['error'];
  }

}