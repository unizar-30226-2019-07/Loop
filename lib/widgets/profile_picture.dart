import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';

/// Foto de perfil con carga dinámica (mostrar la foto por defecto o la del usuario)
class ProfilePicture extends StatelessWidget {
  static const DEFAULT = 'assets/img/profile_default.jpg';

  final UsuarioClass _user;

  ProfilePicture(this._user);

  @override
  Widget build(BuildContext context) =>
      _user == null ? Image.asset(DEFAULT) : _user.profileImage.image;
}
