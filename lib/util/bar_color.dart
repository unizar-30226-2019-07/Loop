import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter/material.dart';

/// Utilidad para cambiar el color de la barra de herramientas superior
class BarColor {
  static bool changing = false;

  static void changeBarColor(
      {@required Color color, @required bool whiteForeground}) async {
    if (!changing) {
      // workaround para varias peticiones simultaneas
      changing = true;
      await FlutterStatusbarcolor.setStatusBarColor(color);
      await FlutterStatusbarcolor.setStatusBarWhiteForeground(
          whiteForeground);
      changing = false;
    } else {
      print('error');
    }
  }
}
