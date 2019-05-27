import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/class/token_class.dart';
import 'package:selit/class/rating_class.dart';
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
      Storage.saveLocation(receivedUser.locationLat, receivedUser.locationLng);
      return receivedToken;
    } else {
      throw (APIConfig.getErrorString(response));
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
      throw (APIConfig.getErrorString(response));
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
      response =
          await http.get('${APIConfig.BASE_URL}/users/$userId', headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
    }

    if (response.statusCode == 200) {
      print('Recibido usuario: ${response.body}');
      String token = await Storage.loadToken();
      UsuarioClass perfil =
          UsuarioClass.fromJson(json.jsonDecode(response.body), token);
      return perfil;
    } else {
      throw (APIConfig.getErrorString(response));
    }
  }

  static Future<void> editUser(UsuarioClass usuario) async {
    if (usuario?.userId == null) {
      throw ("Unknown Error");
    }

    Map josn = usuario.toJsonEdit();
    print(josn.toString());
    print("Edición de usuario: ${json.jsonEncode(usuario.toJsonEdit())}");

    http.Response response =
        await http.put('${APIConfig.BASE_URL}/users/${usuario.userId}',
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.toString(),
              HttpHeaders.authorizationHeader: await Storage.loadToken(),
            },
            body: json.jsonEncode(usuario.toJsonEdit()));

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

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
      throw (APIConfig.getErrorString(response));
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
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Actulizar los datos del usuario con ID [userId]
  static Future<void> edit(UsuarioClass chain) async {
    final response =
        await http.put('${APIConfig.BASE_URL}/users/${chain.userId}',
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.toString(),
              HttpHeaders.authorizationHeader: await Storage.loadToken(),
            },
            body: json.jsonEncode(chain.toJsonEdit()));
    return response;
  }

  static Future<void> delete(int userId) async {
    http.Response response = await http.delete(
      '${APIConfig.BASE_URL}/users/$userId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
    );

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Obtener lista de deseados (productos o subastas)
  static Future<List<ItemClass>> getWishlist(
      {bool auctions, double lat, double lng}) async {
    String token = await Storage.loadToken();
    int idUsuario = await Storage.loadUserId();
    final response = await http.get(
      '${APIConfig.BASE_URL}/users/$idUsuario/wishes_${auctions ? 'auctions' : 'products'}?lat=$lat&lng=$lng',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: token,
      },
    );

    if (response.statusCode == 200) {
      List<ItemClass> wishlist = new List<ItemClass>();
      if (auctions) {
        (json.jsonDecode(response.body) as List<dynamic>).forEach((itemJson) {
          wishlist.add(ItemClass.fromJsonAuctions(itemJson, token));
        });
      } else {
        (json.jsonDecode(response.body) as List<dynamic>).forEach((itemJson) {
          wishlist.add(ItemClass.fromJsonProducts(itemJson, token));
        });
      }
      return wishlist;
    } else {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Añadir producto o subasta a la lista de deseados
  static Future<void> addToWishlist({int productId, bool auctions}) async {
    String token = await Storage.loadToken();
    int idUsuario = await Storage.loadUserId();
    final response = await http.put(
      '${APIConfig.BASE_URL}/users/$idUsuario/wishes_${auctions ? 'auctions' : 'products'}/$productId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: token,
      },
    );

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Quitar producto o subasta de la lista de deseados
  static Future<void> removeFromWishlist({int productId, bool auctions}) async {
    String token = await Storage.loadToken();
    int idUsuario = await Storage.loadUserId();
    final response = await http.delete(
      '${APIConfig.BASE_URL}/users/$idUsuario/wishes_${auctions ? 'auctions' : 'products'}/$productId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: token,
      },
    );

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Añadir informe acerca de un usuario (se supone que el que realiza el informe/reporte
  /// es el usuario que está logueado en curso [Storage.loadUserId()] y está reportando
  /// al usuario [reportedUserId])
  static Future<void> reportUser(
      {int reportedUserId, String asunto, String desc}) async {
    String token = await Storage.loadToken();
    int idUsuario = await Storage.loadUserId();

    // Json a enviar
    DateTime fechaActual = DateTime.now();
    Map<String, dynamic> reportData = {
      "id_evaluado": reportedUserId,
      "id_informador": idUsuario,
      "asunto": asunto,
      "descripcion": desc,
      "fecha_realizacion": '${fechaActual.year}-'
          '${fechaActual.month.toString().padLeft(2, '0')}-'
          '${fechaActual.day.toString().padLeft(2, '0')}'
    };

    final response =
        await http.post('${APIConfig.BASE_URL}/reports/$reportedUserId/report',
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.toString(),
              HttpHeaders.authorizationHeader: token,
            },
            body: json.jsonEncode(reportData));

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }


  static Future<void> requestData() async {
    String token = await Storage.loadToken();

    final response =
    await http.get('${APIConfig.BASE_URL}/users/request',
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: token,
        });

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Realizar una valoracion acerca del producto [producto], para el usuario
  /// que vende el producto [producto.owner] con un número de estrellas y comentario
  static Future<void> rateUser(
      {bool isBuyer, ItemClass producto, double estrellas, String comentario}) async {
    String token = await Storage.loadToken();


    int buyerId = producto.type == "sale" ? producto.buyer.userId : producto.lastBid.bidder.userId;
    int sellerId = producto.owner.userId;
    print('${APIConfig.BASE_URL}/users/${isBuyer ? sellerId : buyerId}/reviews');
    print(await Storage.loadToken());

    // Json a enviar
    Map<String, dynamic> rateData = {
      "id_comprador": buyerId,
      "id_anunciante": sellerId,
      "valor": estrellas,
      "comentario": comentario,
      (producto.isAuction() ? "id_subasta" : "id_producto"): producto.itemId,
    };
    print(json.jsonEncode(rateData));

    final response =
        await http.post('${APIConfig.BASE_URL}/users/${isBuyer ? sellerId : buyerId}/reviews',
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.toString(),
              HttpHeaders.authorizationHeader: token,
            },
            body: json.jsonEncode(rateData));

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Obtener los ratings de un usuario
  static Future<List<RatingClass>> getRatingsFromUser(
      {int userId}) async {

    int miId = await Storage.loadUserId();
    String token = await Storage.loadToken();

    final response =
        await http.get('${APIConfig.BASE_URL}/users/$userId/reviews',
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.toString(),
              HttpHeaders.authorizationHeader: token,
            });

    if (response.statusCode == 200) {
      List<RatingClass> ratings = new List<RatingClass>();
      (json.jsonDecode(response.body) as List<dynamic>).forEach((itemJson) {
        ratings.add(RatingClass.fromJson(itemJson, token, miId));
      });
      return ratings;
    } else {
      throw (APIConfig.getErrorString(response));
    }
  }

  static Future<void> forgotPassword({String email}) async {
    final response =
        await http.get('${APIConfig.BASE_URL}/users/forgot?email=$email',
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.toString(),
            }
          );
      
    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

}
