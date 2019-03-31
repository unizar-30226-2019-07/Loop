import 'package:selit/util/seruser.dart';
import 'routes.dart';

String token;
Future<bool> readToken() async {
    token = await storage.read(key: "token");
    if (token != null){
      return false;
    }
    else{
      return true;
    }
  }

Future main() async {
    bool virgin = await readToken();

    if (virgin){
      print("Nuevo usuario detectado");
      new Routes(true);
    }
    else{
      print(token);
      new Routes(false);
    }
    
}