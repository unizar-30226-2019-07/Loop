import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/util/api/api_config.dart';


class ChatClass {
  
  UsuarioClass usuario;
  int miId;
  ItemClass producto;
  bool visibleAnunciante;
  bool visibleCliente;
  

  ChatClass({this.usuario, this.miId, this.producto, 
    this.visibleAnunciante, this.visibleCliente});
  
}
