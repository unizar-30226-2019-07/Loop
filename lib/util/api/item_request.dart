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
    if (size != null) _params.putIfAbsent("\$size", () => size.toString());
    if (page != null) _params.putIfAbsent("\$page", () => page.toString());

    String _otherParameters = '?lat=$lat&lng=$lng&token=yes&status=en venta';
    _params.forEach((key, value) => _otherParameters += '&$key=$value');

    print("Parametros: $_otherParameters");

    http.Response response;
    if (_params["type"] == "sale") {
      // productos
      // Esperar la respuesta de la petición
      print('ITEM API PLAY ▶');
      response = await http
          .get('${APIConfig.BASE_URL}/products$_otherParameters', headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
      print('ITEM API STOP ◼');
    } else {
      // subastas
      // Esperar la respuesta de la petición
      print('ITEM API PLAY ▶');
      response = await http
          .get('${APIConfig.BASE_URL}/auctions$_otherParameters', headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      });
      print('ITEM API STOP ◼');
    }

    print(response.body);
    // Crear la lista de items a partir de la respuesta y devovlerla
    if (response.statusCode == 200) {
      List<ItemClass> products = new List<ItemClass>();
      String token = await Storage.loadToken();
      if (_params["type"] == "sale") {
        // productos
        (json.jsonDecode(response.body) as List<dynamic>)
            .forEach((productJson) {
          products.add(ItemClass.fromJsonProducts(productJson, token));
        });
      } else {
        // subastas
        (json.jsonDecode(response.body) as List<dynamic>)
            .forEach((auctionJson) {
          ItemClass auction = ItemClass.fromJsonAuctions(auctionJson, token);
          bool _subastaEnFecha = auction.endDate.isAfter(DateTime.now());
          if (_subastaEnFecha) {
            products.add(auction);
          }
        });
      }
      return products;
    } else {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Obtener listado de objetos en venta/vendidos por un usuario
  /// Por ahora se piden todos los items del usuario a la vez,
  /// sin cargar por páginas
  static Future<List<ItemClass>> getItemsFromUser(
      {@required int userId,
      @required double userLat,
      @required double userLng,
      @required String status}) async {
    // Distancia alta para devolver todos los items
    String _paramsString = '?lat=$userLat&lng=$userLng&distance=9999999999.9';
    // Si status no es ni "en venta" ni "vendido", default a "en venta"
    String _statusParam = status == "vendido" ? status : "en venta";
    _paramsString += "&owner=$userId";

    // Esperar la respuesta de la petición
    print('ITEM USER PLAY ▶');
    http.Response responseProducts = await http.get(
        '${APIConfig.BASE_URL}/products$_paramsString&status=$_statusParam',
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: await Storage.loadToken(),
        });
    http.Response responseAuctions = await http
        .get('${APIConfig.BASE_URL}/auctions$_paramsString', headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
    });
    print('ITEM USER STOP ◼');

    if (responseProducts.statusCode == 200 &&
        responseAuctions.statusCode == 200) {
      List<ItemClass> products = new List<ItemClass>();
      String token = await Storage.loadToken();
      (json.jsonDecode(responseProducts.body) as List<dynamic>)
          .forEach((productJson) {
        products.add(ItemClass.fromJsonProducts(productJson, token));
      });
      (json.jsonDecode(responseAuctions.body) as List<dynamic>)
          .forEach((auctionJson) {
        ItemClass subasta = ItemClass.fromJsonAuctions(auctionJson, token);
        bool _subastaEnFecha = subasta.endDate.isAfter(DateTime.now());
        if ((_statusParam == "vendido" && !_subastaEnFecha) ||
            (_statusParam == "en venta" && _subastaEnFecha)) {
          products.add(subasta);
        }
      });
      return products;
    } else {
      throw (APIConfig.getErrorString(responseProducts.statusCode == 200
          ? responseProducts
          : responseAuctions));
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
      body: json.utf8.encode(json.jsonEncode(item.toJsonCreate())),
    );

    if (response.statusCode != 201) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Subir subasta
  static Future<void> createAuction(ItemClass item) async {
    print(json.jsonEncode(item.toJsonCreateAuction()));
    final response = await http.post(
      '${APIConfig.BASE_URL}/auctions',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body: json.utf8.encode(json.jsonEncode(item.toJsonCreateAuction())),
    );

    if (response.statusCode != 201) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Actualizar producto
  static Future<void> edit(ItemClass item) async {
    int _productId = item.itemId;
    print(json.jsonEncode(item.toJsonEdit()));
    final response = await http.put(
      '${APIConfig.BASE_URL}/products/$_productId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body: json.utf8.encode(json.jsonEncode(item.toJsonEdit())),
    );

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  ///Actualizar subasta
  static Future<void> editAuction(ItemClass item) async {
    int _auctionId = item.itemId;
    print(json.jsonEncode(item.toJsonEditAuction()));
    final response = await http.put(
      '${APIConfig.BASE_URL}/auctions/$_auctionId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body: json.utf8.encode(json.jsonEncode(item.toJsonEditAuction())),
    );

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Eliminar producto
  static Future<void> delete(ItemClass item) async {
    int _productId = item.itemId;
    final response = await http.delete(
      '${APIConfig.BASE_URL}/${item.type == "sale" ? "products" : "auctions"}/$_productId',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
    );

    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Pujar
  static Future<void> bidUp(ItemClass item, String amount, int bidderId) async {
    int _productId = item.itemId;
    print(json.jsonEncode(item.toJsonBidUp(amount, bidderId)));
    print(_productId);
    final response = await http.post(
      '${APIConfig.BASE_URL}/auctions/$_productId/bid',
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: await Storage.loadToken(),
      },
      body:
          json.utf8.encode(json.jsonEncode(item.toJsonBidUp(amount, bidderId))),
    );
    if (response.statusCode != 201) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Obtener un producto en base a su Id
  static Future<ItemClass> getItembyId(
      {@required int itemId, @required String type}) async {
    // Esperar la respuesta de la petición
    http.Response response = await http.get(
        '${APIConfig.BASE_URL}/${type == "sale" ? "products" : "auctions"}/$itemId',
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: await Storage.loadToken(),
        });

    if (response.statusCode == 200) {
      String token = await Storage.loadToken();
      ItemClass product;
      if (type == "sale") {
        // productos
        product =
            ItemClass.fromJsonProducts(json.jsonDecode(response.body), token);
      } else {
        // subastas
        product =
            ItemClass.fromJsonAuctions(json.jsonDecode(response.body), token);
      }

      return product;
    } else {
      print('Status code: ' + response.statusCode.toString());
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Sumar uno al número de visitas de un item
  static Future<void> viewItem(
      {@required int itemId, @required String type}) async {
    // Esperar la respuesta de la petición
    http.Response response = await http.head(
        '${APIConfig.BASE_URL}/${type == "sale" ? "products" : "auctions"}/$itemId',
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: await Storage.loadToken(),
        });
    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Marcar un producto como vendido
  static Future<void> markItemAsSold(
      {@required ItemClass item, @required int buyerId}) async {
    // Esperar la respuesta de la petición
    Map itemMap = item.toJsonEdit();
    itemMap['buyer_id'] = buyerId;

    http.Response response =
        await http.put('${APIConfig.BASE_URL}/products/${item.itemId}/sell',
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.toString(),
              HttpHeaders.authorizationHeader: await Storage.loadToken(),
            },
            body: json.jsonEncode(itemMap));
    if (response.statusCode != 200) {
      throw (APIConfig.getErrorString(response));
    }
  }

  /// Comprobar si subasta finalizada
  static Future<bool> checkAuctionFinished(
      {@required ItemClass item}) async {
    // Esperar la respuesta de la petición

    http.Response response = await http
        .put('${APIConfig.BASE_URL}/auctions/${item.itemId}/sell', headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await Storage.loadToken(),
    });

    if (response.statusCode == 200) {
      if (response.body != "") {
        return true;
      } else {
        return false;
      }
    } else {
      print('Status code: ' + response.statusCode.toString());
      throw (APIConfig.getErrorString(response));
    }
  }
}
