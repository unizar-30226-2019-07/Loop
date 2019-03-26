import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:selit/class/item_class.dart';

/// Interacciones con la API relacionadas con items (productos, objetos)
class ItemRequest {

  static Future<Stream<ItemClass>> getItems() async {
    // TODO la URL no deberia ir aquí, pero se deja por motivos de test
    final String url = 'https://api.punkapi.com/v2/beers';

    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .expand((data) => (data as List))
        .map((data) => ItemClass.fromJSON(data));
  }
  
}
