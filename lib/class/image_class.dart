import 'package:flutter/material.dart';
import 'package:selit/util/api/api_config.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'dart:io';

/// Datos de imagen de la aplicación, además de la propia imagen
/// almacena su ID interno del sistema. Empleado por ambos [UsuarioClass] e [ItemClass]
class ImageClass {
  int imageId;
  Image image;

  String base64;
  String mime;
  String charset;

  void _loadImage(Future<String> token) async {
    image = Image.network(
      '${APIConfig.BASE_URL}/pictures/$imageId',
      headers: {
        HttpHeaders.authorizationHeader: await token,
      },
      fit: BoxFit.cover,
    );
  }

  // Constructor a partir de un ID
  ImageClass.network({@required this.imageId, @required Future<String> tokenHeader}) {
    assert(imageId == null || imageId > 0, 'Una imagen debe tener un ID mayor que 0');
    if (imageId == null) {
      image = Image.asset('assets/img/profile_default.jpg', fit: BoxFit.cover); // TODO elegir imagen por defecto
    } else {
      _loadImage(tokenHeader);
    }
  }

  ImageClass.file({@required File fileImage}) {
    imageId = null;
    image = Image.file(fileImage);

    base64 = base64Encode(fileImage.readAsBytesSync());
    mime = lookupMimeType(fileImage.path);
    charset = 'utf-8';
  }

  Map<String, dynamic> toJson() => {
    'idImagen' : imageId,
    'base64' : base64,
    'mime' : mime,
    'charset' : charset,
  };
        
}
