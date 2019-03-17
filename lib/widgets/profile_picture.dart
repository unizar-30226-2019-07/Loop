import 'package:flutter/material.dart';

/// Foto de perfil con carga dinámica (mostrar la foto por defecto o la del usuario)
class ProfilePicture extends StatelessWidget {

  final String _url;

  ProfilePicture(this._url);

  @override
  Widget build(BuildContext context) {
    if (_url == null || _url.isEmpty) {
      // No existe foto de perfil: foto por defecto
      return Image.asset(
        'images/profile_default.jpg',
      );
    } else {
      // Tiene foto de perfil: mostrar la foto por defecto
      // hasta que cargue la foto real
      return FadeInImage.assetNetwork(
        placeholder: 'images/profile_default.jpg',
        image: _url,
        fadeInCurve: Curves.linear,
        fadeInDuration: const Duration(milliseconds: 100),
      );
    }
  }
}