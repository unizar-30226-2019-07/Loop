/* TODO borrar si funciona
import 'dart:convert';

Token postFromJson(String str) {
  final jsonData = json.decode(str);
  return Token.fromJson(jsonData);
}

String postToJson(User data) {
  final dyn = data.toJson();
  print(dyn);
  return json.encode(dyn);
}
String postToJsonL(User data) {
  final dyn = data.toJsonL();
  print(dyn);
  return json.encode(dyn);
}


List<Token> allPostsFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<Token>.from(jsonData.map((x) => Token.fromJson(x)));
}

String allPostsToJson(List<Token> data) {
  final dyn = new List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}

class Token {
 
  String token;

  Token({
    this.token,
  });

  factory Token.fromJson(Map<String, dynamic> json) => new Token(
    token: json["token"],

  );

  Map<String, dynamic> toJson() => {
    "token": token,
 
  };
}

class LocationU{
  double lat;
  double lon;

  LocationU({
    this.lat,
    this.lon
});

factory LocationU.fromJson(Map<String, dynamic> json){
    return LocationU(
      lat: json['lat'],
      lon: json['lng']
    );
  }
  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lon,
  };


}



class User {
 
  String email;
  String password;
  String first_name;
  String last_name;
  LocationU location;

  User({
    this.email,
    this.password,
    this.first_name,
    this.last_name,
    this.location
  });



  factory User.fromJson(Map<String, dynamic> json) => new User(
    email: json["email"],
    password: json["password"],
    first_name: json["first_name"],
    last_name: json["last_name"],
    location: LocationU.fromJson(json["location"])

  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
    "first_name": first_name,
    "last_name": last_name,
    "location": location.toJson(),

 
  };

  Map<String, dynamic> toJsonL() => {
    "email": email,
    "password": password, 
  };
}

*/