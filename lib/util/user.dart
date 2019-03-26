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
 
  String user;
  String password;

  User({
    this.user,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => new User(
    user: json["user"],
    password: json["password"],

  );

  Map<String, dynamic> toJson() => {
    "email": user,
    "password": password,
 
  };
}

