import 'package:flutter/material.dart';

/// Datos de usuario registrado, ya sea para mostrarlos en el perfil
/// o para cualquier otro uso. Puede tener campos nulos aunque sean
/// campos obligatorios para un usuario registrado, ya que un campo nulo
/// representa el usuario por defecto hasta que cargue el usuario real
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
      // No existe foto de perfil: foto por defecto
      return Image.asset(
        'images/profile_default.jpg',
      );
    } else {
      // Tiene foto de perfil: mostrar la foto por defecto
      // hasta que cargue la foto real
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
