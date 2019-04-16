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
    http.Response response = await http.post('${APIConfig.BASE_URL}/login',
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        },
        body: json.jsonEncode({
          "email": email,
          "password": password,
        }));

    print("Resultado del login: Codigo ${response.statusCode},"
        "body ${response.headers[HttpHeaders.authorizationHeader]}");

    if (response.statusCode == 200) {
      TokenClass receivedToken =
          TokenClass(response.headers[HttpHeaders.authorizationHeader]);
      Storage.saveToken(receivedToken.token);
      UsuarioClass receivedUser = await UsuarioRequest.getUserById(0);
      Storage.saveUserId(receivedUser.userId);
      return receivedToken;
    } else {
      throw(APIConfig.getErrorString(response));
    }
  }

  /// Registro de usuario con ciertos campos de [UsuarioClass] con contraseña [password]
  static Future<void> signUp(UsuarioClass newUser, String password) async {
    http.Response response = await http.post('${APIConfig.BASE_URL}/users',
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        },
        body: json.jsonEncode(
            newUser.toJsonForSignUp()..addAll({"password": password})));

    if (response.statusCode != 201) {
      throw(APIConfig.getErrorString(response));
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

    if (response.statusCode == 200) {
      String token = await Storage.loadToken();
      UsuarioClass perfil =
          UsuarioClass.fromJson(json.jsonDecode(response.body), token);
      return perfil;
    } else {
      throw(APIConfig.getErrorString(response));
    }
  }
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

  /// Obtención de lista de usuarios
  static Future<List<UsuarioClass>> getUsers() async {
    http.Response response =
        await http.get('${APIConfig.BASE_URL}/users', headers: {
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
    });

    if (response.statusCode == 200) {
      String token = await Storage.loadToken();
      List<UsuarioClass> users = new List<UsuarioClass>();
      (json.jsonDecode(response.body) as List<dynamic>).forEach((userJson) {
        users.add(UsuarioClass.fromJson(userJson, token));
      });
      return users;
    } else {
      throw(APIConfig.getErrorString(response));
    }
  }

  /// Cambio de contraseña
  static Future<void> password(
      String oldPassword, String newPassword, int userId) async {
    String _paramsString = '?old=$oldPassword&new=$newPassword';

    http.Response response = await http.post(
      '${APIConfig.BASE_URL}/users/$userId/change_password$_paramsString',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
    );

    if (response.statusCode != 200) {
      throw(APIConfig.getErrorString(response));
    }
  }

   /// Actulizar los datos del usuario con ID [userId]
static Future<void> edit(UsuarioClass chain) async{
  final response = await http.put('${APIConfig.BASE_URL}/users/${chain.userId}',
      headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },

      body: json.jsonEncode(chain.toJsonEdit())
  );
  return response;
}

  static Future<void> delete( int userId) async {
    http.Response response = await http.delete(
      '${APIConfig.BASE_URL}/users/$userId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
    );

    if (response.statusCode != 200) {
      throw(APIConfig.getErrorString(response));
    }
  }

}
