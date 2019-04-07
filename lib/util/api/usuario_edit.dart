import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/util/api/api_config.dart';


final storage = new FlutterSecureStorage();

String postToJson(UsuarioClass data) {
  final dyn = data.toJsonEdit();
  print(dyn);
  return json.encode(dyn);
}

 /// Actulizar los datos del usuario con ID [userId]
Future<http.Response> edit(UsuarioClass chain) async{
  final response = await http.put('${APIConfig.BASE_URL}/users/${chain.user_id}',
      headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: await APIConfig.getToken()
      },
      
      
      body: postToJson(chain)
  );
  return response;
}