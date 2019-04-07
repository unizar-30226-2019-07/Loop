import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'package:selit/util/seruser.dart';

/// Abstracción para realizar peticiones con la API
/// Dispone de los diferentes metodos HTTP (GET, POST, PUT, etc.)
/// Su uso principal es abstraer la [_ip] del request a realizar.
/// 
/// TODO mover [HttpRequest] a [APIConfig] ya que hacer las peticiones GET
/// desde esta clase limita mucho las posibilidades
/// Propongo hacer las peticiones como en [ItemRequest], solamente usando
/// [APIConfig] para la IP base
class HttpRequest {

  static final _ip = "http://selit.naval.cat:8080/";
  /// Petición GET
  /// Concatena la [url] con la IP del servidor, asi que debe
  /// tener formato '/users' para obtener la lista de usuarios, por ejemplo
  static Future<Response> apiGET(String url) async {
    return get('$_ip$url',
      headers: {
      HttpHeaders.authorizationHeader : await storage.read(key: 'token')
    }
      );
  }


}