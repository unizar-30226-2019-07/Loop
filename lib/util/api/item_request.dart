import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/api_config.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/class/items/filter_list_class.dart';
import 'package:flutter/foundation.dart'; // uso de @required
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
import 'dart:io';

/// Interacciones con la API relacionadas con items (productos, objetos)
class ItemRequest {
  /// Obtener lista de items (para la pantalla principal)
  static Future<List<ItemClass>> getItems(
      {@required double lat,
      @required double lng,
      int size,
      int page,
      @required FilterListClass filters}) async {

    // Mapa empleado para generar los parámetros de la request
    // search, priceFrom/To, distance, category, types, sort
    Map<String, String> _params = filters.getFiltersMap();
    if (size != null) _params.putIfAbsent("size", () => size.toString());
    if (page != null) _params.putIfAbsent("page", () => page.toString());

    String _otherParameters = '';
    _params.forEach((key, value) => _otherParameters += '&$key=$value');
    // TODO $_otherParameters
    String _paramsString = '?lat=$lat&lng=$lng&distance=1000';

    // Esperar la respuesta de la petición
    print('ITEM API PLAY ▶');
    http.Response response = await http
        .get('${APIConfig.BASE_URL}/products$_paramsString', headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
    });
    print('ITEM API STOP ◼');

    // Crear la lista de items a partir de la respuesta y devovlerla
    if (response.statusCode == 200) {
      List<ItemClass> products = new List<ItemClass>();
      String token = await Storage.loadToken();
      (json.jsonDecode(response.body) as List<dynamic>).forEach((productJson) {
        products.add(ItemClass.fromJson(productJson, token));
      });
      return products;
    } else {
      throw(APIConfig.getErrorString(response));
    }
  }

  /// Obtener listado de objetos en venta/vendidos por un usuario
  /// Por ahora se piden todos los items del usuario a la vez,
  /// sin cargar por páginas
  static Future<List<ItemClass>> getItemsFromUser(
      {@required int userId, @required String status}) async {
    // TODO workaround para ignorar la distancia de los objetos
    String _paramsString = '?lat=0.0&lng=0.0&distance=99999999.9';
    // Si status no es ni "en venta" ni "vendido", default a "en venta"
    String _statusParam = status == "vendido" ? status : "en venta";
    _paramsString += "&owner=$userId&status=$_statusParam";

    // Esperar la respuesta de la petición
    print('ITEM USER PLAY ▶');
    http.Response response = await http
        .get('${APIConfig.BASE_URL}/products$_paramsString', headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
    });
    print('ITEM USER STOP ◼');

    if (response.statusCode == 200) {
      List<ItemClass> products = new List<ItemClass>();
      String token = await Storage.loadToken();
      (json.jsonDecode(response.body) as List<dynamic>).forEach((productJson) {
        products.add(ItemClass.fromJson(productJson, token));
      });
      return products;
    } else {
      throw(APIConfig.getErrorString(response));
    }
  }

  /// Subir producto
  static Future<void> create(ItemClass item) async {
    final response = await http.post(
      '${APIConfig.BASE_URL}/products',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body: json.jsonEncode(item.toJsonCreate()),
    );

    if (response.statusCode != 201) {
      throw(APIConfig.getErrorString(response));
    }
  }

  /// Actualizar producto
  static Future<void> edit(ItemClass item) async {
    int _productId = item.itemId;
    print('Id de producto en request: ' + item.itemId.toString());
    final response = await http.put(
      '${APIConfig.BASE_URL}/products/$_productId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body: json.jsonEncode(item.toJsonCreate()),
    );

    if (response.statusCode != 201) {
      print(response.statusCode);
      throw(APIConfig.getErrorString(response));
    }
  }

  /// Eliminar producto
  static Future<void> delete(ItemClass item) async {
    int _productId = item.itemId;
    print('Id de producto en request: ' + item.itemId.toString());
    final response = await http.delete(
      '${APIConfig.BASE_URL}/products/$_productId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
    );

    if (response.statusCode != 200) {
      print(response.statusCode);
      throw(APIConfig.getErrorString(response));
    }
  }
}
