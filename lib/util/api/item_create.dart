import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/api_config.dart';


final storage = new FlutterSecureStorage();

String postToJson(ItemClass data) {
  final dyn = data.toJsonCreate();
  print(dyn);
  return json.encode(dyn);
}

 /// Subir producto
Future<http.Response> create(ItemClass chain) async{
  final response = await http.post('${APIConfig.BASE_URL}/products',
      headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await APIConfig.getToken()
      },
      
      
      body: postToJson(chain)
  );
  return response;
}