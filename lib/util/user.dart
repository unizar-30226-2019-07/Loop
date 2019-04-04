import 'dart:convert';

Token postFromJson(String str) {
  final jsonData = json.decode(str);
  return Token.fromJson(jsonData);
}

String postToJson(User data) {
  final dyn = data.toJson();
  //print(json.encode(dyn));
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
class User {
 
  String email;
  String password;
  String first_name;
  String last_name;

  User({
    this.email,
    this.password,
    this.first_name,
    this.last_name,
  });

  factory User.fromJson(Map<String, dynamic> json) => new User(
    email: json["email"],
    password: json["password"],
    first_name: json["first_name"],
    last_name: json["last_name"],

  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
    "first_name": first_name,
    "last_name": last_name,
 
  };
}

