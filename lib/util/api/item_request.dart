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
    Map<String, String> _params = filters
        .getFiltersMap(); // search, priceFrom/To, distance, category, types, sort
    if (size != null) _params.putIfAbsent("size", () => size.toString());
    if (page != null) _params.putIfAbsent("page", () => page.toString());

    String _otherParameters = '';
    _params.forEach((key, value) => _otherParameters += '&$key=$value');
    String _paramsString = '?lat=$lat&lng=$lng$_otherParameters';

    // Esperar la respuesta de la petición
    http.Response response = await http
        .get('${APIConfig.BASE_URL}/products$_paramsString', headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
    });

    // Crear la lista de items a partir de la respuesta y devovlerla
    switch (response.statusCode) {
      case 200:
        List<ItemClass> products = new List<ItemClass>();
        (json.jsonDecode(response.body) as List<dynamic>).forEach((userJson) {
          products.add(ItemClass.fromJson(userJson));
        });
        return products;
        break;
      default:
        return List<ItemClass>(); // TODO solo existe el codigo 200, no hay casos de error?
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
    http.Response response = await http
        .get('${APIConfig.BASE_URL}/products$_paramsString', headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
    });

    // Crear la lista de items a partir de la respuesta y devovlerla
    switch (response.statusCode) {
      case 200:
        List<ItemClass> products = new List<ItemClass>();
        (json.jsonDecode(response.body) as List<dynamic>).forEach((userJson) {
          products.add(ItemClass.fromJson(userJson));
        });
        return products;
        break;
      default:
        return List<ItemClass>(); // TODO solo existe el codigo 200, no hay casos de error?
    }
  }

  /// Subir producto
  static Future<void> create(ItemClass item) async {
    final response = await http.post('${APIConfig.BASE_URL}/products',
        headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
        },
        body: json.jsonEncode(item.toJsonCreate()),
    );

    // Crear la lista de items a partir de la respuesta y devovlerla
    switch (response.statusCode) {
      case 201: // Item creado, todo OK
        break;
      case 401:
        throw("No autorizado");
      case 402:
        throw("Prohibido");
    }
  }
  
}
