import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';

/// Foto de perfil con carga dinámica (mostrar la foto por defecto o la del usuario)
class ProfilePicture extends StatelessWidget {

  final UsuarioClass _user;

  ProfilePicture(this._user);

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // No existe foto de perfil: foto por defecto
      return Image.asset(
        'assets/img/profile_default.jpg',
      );
    } else {
      String _url = _user.pictureBase64;
      // Tiene foto de perfil: mostrar la foto por defecto
      // hasta que cargue la foto real
      Uint8List bytes = base64.decode(_url);

      return new Image.memory(bytes);

      
/*
      return FadeInImage.assetNetwork(
        placeholder: 'assets/img/profile_default.jpg',
        image: _url,
        fadeInCurve: Curves.linear,
        fadeInDuration: const Duration(milliseconds: 100),
      );
      */
    }
  }
}