import 'dart:convert';

Token postFromJson(String str) {
  final jsonData = json.decode(str);
  return Token.fromJson(jsonData);
}

String postToJson(Item data) {
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

class LocationU {
  double lat;
  double lon;

  LocationU({this.lat, this.lon});

  factory LocationU.fromJson(Map<String, dynamic> json) {
    return LocationU(lat: json['lat'], lon: json['lng']);
  }
  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lon,
      };
}

class Item {
  String type;
  String title;
  int owner_id;
  LocationU location;
  String description;
  String category;
  double price;
  String currency;

  Item(
      {this.type,
      this.title,
      this.owner_id,
      this.location,
      this.description,
      this.category,
      this.price,
      this.currency});

  factory Item.fromJson(Map<String, dynamic> json) => new Item(
        type: json["type"],
        title: json["title"],
        owner_id: json["owner_id"],
        location: LocationU.fromJson(json["location"]),
        description: json["description"],
        category: json["category"],
        price: json["price"],
        currency: json["currency"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "title": title,
        "owner_id": owner_id,
        "location": location.toJson(),
        "description": description,
        "category": category,
        "price": price,
        "currency": currency,
      };
}
