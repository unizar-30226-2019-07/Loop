import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:selit/util/perfil.dart';
import 'dart:io';

String url = "http://selit.naval.cat:8080";

Future<List<Perfil>> getAllPerfiles(String token) async {
  final response = await http.get('$url/users',
          headers: {
          HttpHeaders.authorizationHeader : token
          }
  );

  return allPerfilesFromJson(response.body);
}

Future<Perfil> getPerfil(String token, String email) async{
  final response = await http.get('$url/users?email=$email');
  return perfilFromJson(response.body);
}