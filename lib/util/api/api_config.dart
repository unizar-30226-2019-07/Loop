import 'package:http/http.dart' as http;
import 'dart:convert' as json;

/// Configuración de conexión con la API
class APIConfig {

  /// URL base a conectar (con puerto)
  static const BASE_URL = 'https://selit.naval.cat:8443';

  static Map _errorCodes = {
    400: "Bad Request",
    401: "Unauthorized",
    403: "Forbidden",
    404: "Not Found",
    405: "Method Not Allowed",
    409: "Conflict",
    412: "Precondition Failed",
    415: "Unsupported Media",
    500: "Internal Server Error"
  };

  static String getErrorString(http.Response response) {
    String error;
    if (response?.statusCode != null) {
      error = _errorCodes[response.statusCode];
      if (error == null) {
        print("Error desconocido: ${json.jsonDecode(response?.body)['message']}");
      }
    }
    return error ?? "Unknown Error";
  }

}