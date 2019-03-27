import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/token_class.dart';
import 'package:selit/util/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
import 'dart:io';

/// Interacciones con la API relacionadas con usuarios
class UsuarioRequest {

  // TODO todavia no esta funcional
  /// Login de usuario por [username] y [password], devuelve un token si ha ido bien
  static Future<TokenClass> login(String username, String password) async {
    http.Response response =
        await http.post('${APIConfig.BASE_URL}/login', headers: {
      HttpHeaders.authorizationHeader: await APIConfig.getToken()
    }, body: {
      "username": username,
      "password": password,
    });
    switch (response.statusCode) {
      case 200:
        return TokenClass.fromJson(json.jsonDecode(response.body));
        break;
      default:
        throw ("Error al autenticar");
    }
  }

  /// Obtener los datos del usuario con ID [userId]
  static Future<UsuarioClass> getUserById(int userId) async {
    // TODO hacer una petición en lugar de simular una carga de 1 segundo
    // y usar el constructor de JSON
    return Future.delayed(Duration(seconds: 3), () {
      print('cargando el perfil con id ' + userId.toString());
      return new UsuarioClass(
          nombre: 'Nombre',
          apellidos: 'Apellidos',
          sexo: 'Hombre',
          edad: 21,
          ubicacionCiudad: 'Zaragoza',
          ubicacionResto: 'Aragon, España',
          numeroEstrellas: 2.5,
          reviews: 30,
          urlPerfil: 'https://avatars0.githubusercontent.com/u/17049331');
    });
  }

  /// Obtención de lista de usuarios
  static Future<List<UsuarioClass>> getUsers() async {
    http.Response response =
        await http.get('${APIConfig.BASE_URL}/users', headers: {
      HttpHeaders.authorizationHeader: await APIConfig.getToken(),
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
