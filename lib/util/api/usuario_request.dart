import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/token_class.dart';
import 'package:selit/util/api/api_config.dart';
import 'package:selit/util/api/http_request.dart';
import 'package:http/http.dart' as http;
import 'package:selit/util/perfil.dart';
import 'dart:convert' as json;
import 'dart:io';
import 'package:selit/util/seruser.dart';


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
    var response;
    if (userId == 0){
      response = await HttpRequest.apiGET("users/me");
    }
    else{
      response = await HttpRequest.apiGET("users/$userId");
    }
    
    print (response.body);
      return new UsuarioClass.fromJson(json.jsonDecode(response.body));
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

  Future <bool> legit() async {
    
    bool toLogin;
    //Primero se comprueba si la aplicación tiene un token almacenado y en caso contrario se redirige a login
    String token = await storage.read(key: 'token');
    if (token == null){
      print ("Usuario virgen");
      toLogin = true;
    }
    else{
      //Con el token se procede a recuperar el perfil del usuario
      UsuarioClass local= await UsuarioRequest.getUserById(0);
      if (local == null){
        //No  se ha devuelto ningún usuario por lo que se invalida el token y se redirige a login.
        print ("Token nulo");
        await storage.delete(key: 'token');
        toLogin=true;
      }
      else{
        //El perfil es válido por lo que se redirige al perfil.
        print ("Legítimo");
        toLogin=false;
      }
      
    }
  return toLogin;
  }
