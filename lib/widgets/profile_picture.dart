import 'dart:io';
import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/util/api/api_config.dart';


/// Foto de perfil con carga dinámica (mostrar la foto por defecto o la del usuario)
class ProfilePicture extends StatelessWidget {

  final UsuarioClass _user;

  ProfilePicture(this._user);


  @override
  Widget build(BuildContext context) {
    if (_user == null || _user.idImagen == null) {
      // No existe foto de perfil: foto por defecto
      print ("Sin foto");
      return Image.asset(
        'assets/img/profile_default.jpg',
      );
    } else {
      print ("Recuperando foto ${_user.idImagen}");
      // Tiene foto de perfil: mostrar la foto por defecto
      // hasta que cargue la foto real
      return Image.network('${APIConfig.BASE_URL}/pictures/${_user.idImagen}',headers: {
                    HttpHeaders.authorizationHeader: _user.token,
      } );
    }
  }
}