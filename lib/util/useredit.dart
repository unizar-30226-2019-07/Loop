import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:selit/class/usuario_class.dart';

final storage = new FlutterSecureStorage();
String url = "http://selit.naval.cat:8080";

/*
Map<String, String> getheaders() => {
  'Authorization': 'Bearer $apiToken',
  'Content-Type': 'application/json',
};
*/


String postToJson(UsuarioClass data) {
  final dyn = data.toJsonEdit();
  print(dyn);
  return json.encode(dyn);
}

var apiToken;
Future<http.Response> edit(UsuarioClass chain) async{
  int id=chain.user_id;
  final response = await http.post('$url/users/$id',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader : ''
      },
      
      body: postToJson(chain)
  );
  /*
   if(response.statusCode == 200)
      print(response.body);
    else{
      print(response.statusCode);
    }
    */
  return response;
}