import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/token_class.dart';
import 'package:selit/util/api/api_config.dart';
import 'package:geocoder/geocoder.dart';
import 'package:selit/util/storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
import 'dart:io';

/// Interacciones con la API relacionadas con usuarios
class UsuarioRequest {
  /// Login de usuario por [email] y [password], devuelve un token si ha ido bien
  static Future<TokenClass> login(String email, String password) async {
    http.Response response = await http.post('${APIConfig.BASE_URL}/login',
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        },
        body: json.jsonEncode({
          "email": email,
          "password": password,
        }));
    print(
        "Resultado del login: Codigo ${response.statusCode}, body ${response.headers[HttpHeaders.authorizationHeader]}");
    switch (response.statusCode) {
      case 200: // Login OK
        TokenClass receivedToken =
            TokenClass(response.headers[HttpHeaders.authorizationHeader]);
        Storage.saveToken(receivedToken.token);
        UsuarioClass receivedUser = await UsuarioRequest.getUserById(0);
        Storage.saveUserId(receivedUser.user_id);
        return receivedToken;
        break;
      case 401: //Usuario rechazado
        throw ("Unauthorized");
      case 403:
        throw ("Forbidden");
      default:
        throw ("Unknown");
    }
  }

  /// Registro de usuario con ciertos campos de [UsuarioClass] con contraseña [password]
  static Future<bool> signUp(UsuarioClass newUser, String password) async {
    http.Response response = await http.post('${APIConfig.BASE_URL}/users',
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        },
        body: json.jsonEncode(
            newUser.toJsonForSignUp()..addAll({"password": password})));
    switch (response.statusCode) {
      case 201: // Registro OK, recurso creado (201)
        return true;
        break;
      default: // TODO casos de error
        return false;
    }
  }

  /// Obtener los datos del usuario con ID [userId]
  static Future<UsuarioClass> getUserById(int userId) async {
    print(userId);
    http.Response response;
    if (userId == 0) {
      print('GET /users/me');
      response = await http.get('${APIConfig.BASE_URL}/users/me', headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
    } else {
      print('GET /users/$userId');
      response =
          await http.get('${APIConfig.BASE_URL}/users/$userId', headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
    }
    switch (response.statusCode) {
      case 200: // El usuario se ha devuelto bien
        UsuarioClass perfil = UsuarioClass.fromJson(json.jsonDecode(response.body));
        //Se obtienen sus valores de ubicación y se incorporan al usuario
        final coordinates = new Coordinates(perfil.locationLat, perfil.locationLng);
        var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
        perfil.ubicacionCiudad = addresses.first.locality;
        perfil.ubicacionResto = addresses.first.subLocality;
        //TODO: Los signos aparecen bien pero luego al envíar a la base no se reconocen.
        /*
        if (perfil.sexo == null || perfil.sexo == 'otro'){
          perfil.sexo = '⚲';
        }
        else if (perfil.sexo == 'mujer'){
          perfil.sexo = '♀'; 
        }
        else{
          perfil.sexo = '♂'; 
        }
      */
        return perfil;
      default: // TODO casos de error
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

  static Future<TokenClass> password(String oldPassword, String newPassword,int user_id ) async {
    
    String _paramsString = '?old=$oldPassword&new=$newPassword';

    http.Response response = await http.post('${APIConfig.BASE_URL}/users/${user_id}/change_password$_paramsString',
         headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
        );
            
    switch (response.statusCode) {
      case 200: // todo OK
        break;
      case 401:
        throw("No autorizado");
      case 402:
        throw("Prohibido");
      case 404:
        throw("No encontrado");
      case 412:
        throw("Precondición fallida (contraseña actual incorrecta)");
      default:
        throw ("Unknown");
    }
  }

}
