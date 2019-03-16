import 'package:flutter/material.dart';

class UsuarioModel {
  // TODO por ahora contiene los datos que se muestran en el perfil,
  // supongo más adelante contendrá toda la información relacionada
  String nombre;
  String apellidos;
  String sexo;
  int edad;
  String ubicacionCiudad; // Ej: Zaragoza
  String ubicacionResto; // Ej: Aragon, España
  double numeroEstrellas;
  int reviews;
  dynamic fotoPerfil; // TODO tipo común image-fadeinimage

  dynamic _getProfilePicture(String url) {
    if (url == null || url.isEmpty) {
      return Image.asset(
        'images/profile_default.jpg',
      );
    } else {
      return FadeInImage.assetNetwork(
        placeholder: 'images/profile_default.jpg',
        image: url,
        fadeInCurve: Curves.linear,
        fadeInDuration: const Duration(milliseconds: 100),
      );
    }
  }

  UsuarioModel(
      {this.nombre,
      this.apellidos,
      this.sexo,
      this.edad,
      this.ubicacionCiudad,
      this.ubicacionResto,
      this.numeroEstrellas,
      this.reviews,
      urlPerfil})
      : assert(edad > 0 &&
            reviews > 0 &&
            numeroEstrellas >= 1 &&
            numeroEstrellas <= 5) {
    fotoPerfil = _getProfilePicture(urlPerfil);
  }

  // TODO una vez acordado el formato del JSON, crear el constructor
  //UsuarioModel.fromJson(Map<String, dynamic> json)
  //    : this(nombre: json['nombre'], apellidos: json['apellidos']);

  // Usuario por defecto, para mostrarlo mientras carga
  UsuarioModel.placeholder() {
    fotoPerfil = _getProfilePicture(null);
  }
}
