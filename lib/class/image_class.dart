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

  // Constructor a partir de un ID
  ImageClass.network({@required this.imageId, @required String tokenHeader}) {
    assert(imageId == null || imageId > 0, 'Una imagen debe tener un ID mayor que 0');
    if (imageId == null) {
      image = Image.asset('assets/img/profile_default.jpg', fit: BoxFit.cover);
    } else {
      image = Image.network(
        '${APIConfig.BASE_URL}/pictures/$imageId',
        headers: {
          HttpHeaders.authorizationHeader: tokenHeader,
        },
        fit: BoxFit.cover,
      );
    }
  }

  ImageClass.file({@required File fileImage}) {
    imageId = null;
    image = Image.file(fileImage);
    List<int> imageBytes = fileImage.readAsBytesSync();
    base64 = base64Encode(imageBytes);
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
