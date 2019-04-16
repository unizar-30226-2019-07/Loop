import 'package:flutter/material.dart';
import 'package:selit/class/image_class.dart';

/// Foto de perfil con carga dinámica (mostrar la foto por defecto o la del usuario)
class ProfilePicture extends StatelessWidget {
  static final defaultImage = Image.asset('assets/img/profile_default.jpg', fit: BoxFit.cover);
  static final color = Colors.grey[200];

  final ImageClass _image;

  ProfilePicture(this._image);

  @override
  Widget build(BuildContext context) => ClipOval(
    child: AspectRatio(
      aspectRatio: 1.0, // cuadrado
      child: Container(
        color: color,
        child: _image?.image == null ? defaultImage : _image.image,
      ),
    )
  );
      
}
