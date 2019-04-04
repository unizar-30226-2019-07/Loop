import 'dart:async';
import 'package:http/http.dart';

/// Abstracción para realizar peticiones con la API
/// Dispone de los diferentes metodos HTTP (GET, POST, PUT, etc.)
/// Su uso principal es abstraer la [_ip] del request a realizar.
class HttpRequest {

  static final _ip = "http://selit.naval.cat:8080/";
  /// Petición GET
  /// Concatena la [url] con la IP del servidor, asi que debe
  /// tener formato '/users' para obtener la lista de usuarios, por ejemplo
  static Future<Response> apiGET(String url) async {
    return get('$_ip$url');
  }


}