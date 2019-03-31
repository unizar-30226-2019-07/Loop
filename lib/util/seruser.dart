import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:selit/util/user.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();
String url = "http://35.234.77.87:8080";

Future<List<Token>> getAllUsers(String token) async {
  final response = await http.get('$url/users',
          headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader : token
          }
          
        );
  print(response.body);
  //return allPostsFromJson(response.body);
}

Future<Token> getPost() async{
  final response = await http.get('$url/1');
  return postFromJson(response.body);
}



/*
Map<String, String> getheaders() => {
  'Authorization': 'Bearer $apiToken',
  'Content-Type': 'application/json',
};
*/
var apiToken;
Future<http.Response> auth(User chain) async{
  final response = await http.post('$url/login',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader : ''
      },
      
      body: postToJson(chain)
  );
  apiToken = response.headers[HttpHeaders.authorizationHeader];
  //print(apiToken);
  await storage.write(key: "token", value: apiToken);
  /*
   if(response.statusCode == 200)
      print(response.body);
    else{
      print(response.statusCode);
    }
    */
  return response;
}


Future<http.Response> sign(User chain) async{
  final response = await http.post('$url/users',
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