/* TODO borrar si va bien el login
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:selit/util/user.dart';
import 'dart:io';
String url = "http://selit.naval.cat:8080";

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
      
      body: postToJsonL(chain)
  );
  print(response.body);
  print(response.statusCode);
  apiToken = response.headers[HttpHeaders.authorizationHeader];
  print(apiToken);
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
*/