import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:selit/util/user.dart';
import 'dart:io';

String url = 'https://reqres.in/api/login';

Future<List<Token>> getAllPosts() async {
  final response = await http.get(url);
  print(response.body);
  return allPostsFromJson(response.body);
}

Future<Token> getPost() async{
  final response = await http.get('$url/1');
  return postFromJson(response.body);
}

Future<http.Response> auth(User chain) async{
  final response = await http.post('$url',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader : ''
      },
      
      body: postToJson(chain)
  );/*
   if(response.statusCode == 200)
      print(response.body);
    else{
      print(response.statusCode);
    }
    */
  return response;
}