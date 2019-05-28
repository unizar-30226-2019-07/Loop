import 'package:selit/class/item_class.dart';
import 'package:selit/class/usuario_class.dart';


class ChatClass {
  
  UsuarioClass usuario;
  int miId;
  ItemClass producto;
  List<dynamic> visible;
  String docId;
  String lastMessage;
  DateTime lastMessageDate;
  String tipoProducto;
  

  ChatClass({this.usuario, this.miId, this.producto, 
    this.visible, this.docId, this.lastMessage, this.lastMessageDate,
    this.tipoProducto});
  
}
