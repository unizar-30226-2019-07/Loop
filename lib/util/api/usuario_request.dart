import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/token_class.dart';
import 'package:selit/util/api/api_config.dart';
import 'package:selit/util/storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
import 'dart:io';

/// Interacciones con la API relacionadas con usuarios
class UsuarioRequest {

  /// Login de usuario por [email] y [password], devuelve un token si ha ido bien
  static Future<TokenClass> login(String email, String password) async {
    http.Response response =
        await http.post('${APIConfig.BASE_URL}/login', headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
    }, body: json.jsonEncode({
      "email": email,
      "password": password,
    }));
    print("Resultado del login: Codigo ${response.statusCode}, body ${response.headers[HttpHeaders.authorizationHeader]}");
    switch (response.statusCode) {
      case 200: // Login OK
        TokenClass receivedToken =
            TokenClass(response.headers[HttpHeaders.authorizationHeader]);
        Storage.saveToken(receivedToken.token);
        return receivedToken;
        break;
      default: // Ha ocurrido un problema - TODO dividir casos?
        return null;
    }
  }

  /// Registro de usuario con ciertos campos de [UsuarioClass] con contraseña [password]
  static Future<bool> signUp(UsuarioClass newUser, String password) async {
    http.Response response =
        await http.post('${APIConfig.BASE_URL}/users', headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
    }, body: json.jsonEncode(newUser.toJsonForSignUp()..addAll({"password": password})));
    switch (response.statusCode) {
      case 201: // Registro OK, recurso creado (201)
        return true;
        break;
      default: // Ha ocurrido un problema - TODO dividir casos?
        return false;
    }
  }

  /// Obtener los datos del usuario con ID [userId]
  static Future<UsuarioClass> getUserById(int userId) async {
    http.Response response;
    if (userId == 0) {
      print('GET /users/me');
      response = await http.get('${APIConfig.BASE_URL}/users/me', headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
    } else {
      print('GET /users/$userId');
      response = await http.get('${APIConfig.BASE_URL}/users/$userId', headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
    }
    switch (response.statusCode) {
      case 200: // El usuario se ha devuelto bien
        return UsuarioClass.fromJson(json.jsonDecode(response.body));
      default: // Problema - TODO dividir casos?
        return null;
    }
  }

  /// Obtención de lista de usuarios
  static Future<List<UsuarioClass>> getUsers() async {
    http.Response response =
        await http.get('${APIConfig.BASE_URL}/users', headers: {
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
    });
    switch (response.statusCode) {
      case 200:
        List<UsuarioClass> users = new List<UsuarioClass>();
        (json.jsonDecode(response.body) as List<dynamic>).forEach((userJson) {
          users.add(UsuarioClass.fromJson(userJson));
        });
        return users;
        break;
      default:
        throw ("Error al obtener la lista de usuarios, obtenido el código ${response?.statusCode}");
    }
  }
}