import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/api_config.dart';
import 'package:selit/class/items/filter_list_class.dart';
import 'package:flutter/foundation.dart'; // uso de @required
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
import 'dart:io';

/// Interacciones con la API relacionadas con items (productos, objetos)
class ItemRequest {
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
      HttpHeaders.authorizationHeader: await APIConfig.getToken()
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
        return List<
            ItemClass>(); // TODO solo existe el codigo 200, no hay casos de error?
    }
  }
}
