import 'package:selit/class/usuario_class.dart';

class RatingClass {
  UsuarioClass usuarioComprador;
  double numeroEstrellas;
  String descripcion;

  RatingClass({this.usuarioComprador, this.numeroEstrellas, this.descripcion});

  RatingClass.fromJson(Map<String, dynamic> json, String token)
      : this(
            usuarioComprador: UsuarioClass.fromJson(json['buyer'], token), // TODO esperar a que la API devuelva usuarioValorado
            numeroEstrellas: json['valor'],
            descripcion: json['comentario']);
}
