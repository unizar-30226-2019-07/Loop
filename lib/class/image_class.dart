import 'package:flutter/material.dart';

/// Datos de imagen de la aplicación, además de la propia imagen
/// almacena su ID interno del sistema. Empleado por ambos [UsuarioClass] e [ItemClass]
class ImageClass {
  int imageId;
  Image image;

  /// Constructor por defecto
  ImageClass({this.imageId, this.image})
      : assert(imageId > 0, 'Una imagen debe tener un ID mayor que 0');

  /// Constructor a partir de [base64]
  /// TODO ver cómo usar [mime] y [charset]
  ImageClass.fromBase64({imageId, @required base64, mime, charset})
      : this(imageId: imageId, image: Image.memory(base64));

  ImageClass.fromJson(Map<String, dynamic> json)
      : this.fromBase64(
            imageId: json['id'],
            base64: json['base64'],
            mime: json['mime'],
            charset: json['charset']);
}
