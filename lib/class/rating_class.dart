import 'package:selit/class/usuario_class.dart';

class RatingClass {
  UsuarioClass usuarioComprador;
  double numeroEstrellas;
  String descripcion;

  RatingClass(
      {usuarioBuyer,
      usuarioSeller,
      miId,
      this.numeroEstrellas,
      this.descripcion}) {
    this.usuarioComprador =
        usuarioBuyer.userId == miId ? usuarioSeller : usuarioBuyer;
  }

  RatingClass.fromJson(Map<String, dynamic> json, String token, int miId)
      : this(
            usuarioBuyer: json['buyer'] == null
                ? null
                : UsuarioClass.fromJson(json['buyer'], token),
            usuarioSeller: json['seller'] == null
                ? null
                : UsuarioClass.fromJson(json['seller'], token),
            miId: miId,
            numeroEstrellas: json['valor'],
            descripcion: json['comentario']);
}
