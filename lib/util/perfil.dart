import 'dart:convert';

Perfil perfilFromJson(String str) {
  final jsonData = json.decode(str);
  return Perfil.fromJson(jsonData);
}

String perfilToJson(Perfil data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

List<Perfil> allPerfilesFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<Perfil>.from(jsonData.map((x) => Perfil.fromJson(x)));
}

String allPerfilToJson(List<Perfil> data) {
  final dyn = new List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}

class Perfil {

int idUsuario;
String gender;
String birth_date;
int posX;
int posY;
int rating;
String status;
String email;
String last_name;
String first_name;
String usuario;

  Perfil({
    this.idUsuario,
    this.gender,
    this.birth_date,
    this.posX,
    this.posY,
    this.rating,
    this.status,
    this.email,
    this.last_name,
    this.first_name,
    this.usuario,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) => new Perfil(
    idUsuario: json["idUsuario"],
    gender: json["gender"],
    birth_date: json["birth_date"],
    posX: json["posX"],
    posY: json["posY"],
    rating: json["rating"],
    status: json["status"],
    email: json["email"],
    last_name: json["last_name"],
    first_name: json["first_name"],
    usuario: json["usuario"],
  );

  Map<String, dynamic> toJson() => {
    "idUsuario": idUsuario,
    "gender": gender,
    "birth_date": birth_date,
    "posX": posX,
    "posY": posY,
    "rating": rating,
    "status": status,
    "email": email,
    "last_name": last_name,
    "first_name": first_name,
    "usuario": usuario,
  };
}