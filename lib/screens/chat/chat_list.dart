import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/util/api/item_request.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/widgets/chats/chat_tile.dart';
import 'package:selit/class/chat_class.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:selit/widgets/chats/chat_tile_loading.dart';
import 'package:selit/widgets/chats/swipe_widget.dart';


class ChatList extends StatefulWidget {
  static int miId;
  ChatList(miId);

  @override
  ChatListState createState() {
    return new ChatListState(miId);
  }
}

class ChatListState extends State<ChatList> {
  int _miId;

  ChatListState(int miId){
    print('Mi id es: ' + miId.toString());
    _miId = miId;
  }

  @override
  void initState() {
    super.initState();
    if (_miId == null){
      _miId = -1; //Quitar null porque sino hará query de todos los chats
      _leerIdUsuario();
    }
  }

  void _leerIdUsuario() async {
    int idStorage = await Storage.loadUserId();
    setState(() {
      _miId = idStorage;
    });
  }

  Future<ChatClass> _getChatData(BuildContext context, DocumentSnapshot document) async {
    print('GEEEEEET DATAAAAA -> ' + document.documentID);
    var streamSub = Firestore.instance.collection('chat').document(document.documentID).collection('mensaje')
      .where('estado', isEqualTo: 'enviado').snapshots().listen(
      (data) {
        data.documents.forEach((messageDocument){
          // Cambiar a recibido solo los mensajes del otro usuario
          if(messageDocument['idEmisor'] != _miId){
            Firestore.instance.runTransaction((transaction) async {
              await transaction.set(Firestore.instance.collection("chat").document(document.documentID)
                .collection("mensaje").document(messageDocument.documentID), 
                {'contenido' : messageDocument['contenido'], 'estado' : 'recibido',
                'fecha' : messageDocument['fecha'], 'idEmisor' : messageDocument['idEmisor']});
              });
          }
        });
      } 
    );
    streamSub.cancel();
    // Pedir datos a la api para crear ChatClass
    ItemClass item = await ItemRequest.getItembyId(itemId: document['idProducto'], type: "sale");
    int idOtro = document['idAnunciante'];
    if(_miId == idOtro){
      idOtro = document['idCliente'];
    }
    // Obtener UsuarioClass del otro usuario
    UsuarioClass usuario = await UsuarioRequest.getUserById(idOtro);

    String lastMessage;
    ChatClass chat =  new ChatClass(usuario: usuario, miId: _miId, producto: item,
      visible: new List.from(document['visible']), docId: document.documentID, 
      lastMessage: document['ultimoMensaje'], lastMessageDate: document['fechaUltimoMensaje'].toDate());
    return chat;
  }

  Widget buildChatTile(BuildContext context, ChatClass chat) {
    return Container(
      child: OnSlide(items: <ActionItems>[
          new ActionItems(
              icon: new IconButton(
                icon: new Icon(Icons.delete),
                onPressed: () {},
                color: Colors.red,
              ),
              onPress: () {
                  print('Hello');
                  _showDialogDeleteChat(chat);
              },
              backgroudColor: Colors.transparent),
        ], child: ChatTile(chat)
    ));

  }

  void _showDialogDeleteChat(ChatClass chat) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("¿Seguro que quiere eliminar el chat?",
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          
          content:  Container(
            height: 120,
            child: Column(
            children: <Widget>[
              new Text(
              chat.producto.title + ' - ' + chat.usuario.nombre + ' ' + chat.usuario.apellidos,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.only(top: 10.0),
                child: new Text(
                  "Si pulsa \"Eliminar\" la conversación desaparerá de su lista de chats.",
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold))
              )
            ],
          ),
          ),
          
          
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancelar",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Eliminar",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                var nuevaListaVisible = chat.visible;
                nuevaListaVisible.remove(_miId);
                Firestore.instance.runTransaction((transaction) async {
                  await transaction.set(Firestore.instance.collection("chat").document(chat.docId), 
                    {'idAnunciante' : chat.usuario.userId, 'idCliente' : _miId,
                    'idProducto' : chat.producto.itemId, 'visible' : nuevaListaVisible,
                    'ultimoMensaje' : chat.lastMessage, 'fechaUltimoMensaje' : chat.lastMessageDate});   
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    print('Mi id: ' + _miId.toString());
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Chats",
            style: TextStyle(
                fontSize: 22.0,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment(0.15, -1.0),
              end: Alignment(-0.15, 1.0),
              stops: [
                0.4,
                0.4
              ],
              colors: [
                Theme.of(context).primaryColor,
                Colors.grey[100],
              ]),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: StreamBuilder(
                    stream: Firestore.instance.collection('chat').where('visible', arrayContains: _miId)
                      .orderBy('fechaUltimoMensaje', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          padding: EdgeInsets.all(10.0),
                          itemBuilder: (context, index) => 
                            FutureBuilder(
                              future: _getChatData(context, snapshot.data.documents[index]),
                              builder: (BuildContext context, AsyncSnapshot snapshotFutureBuilder) {
                                print('Id chat: ' + snapshot.data.documents[index].documentID);
                                switch (snapshotFutureBuilder.connectionState) {
                                  case ConnectionState.none:
                                  case ConnectionState.waiting:
                                    return ChatTileLoading();
                                  default:
                                    if (snapshotFutureBuilder.hasError)
                                      return new Text('Error: ${snapshotFutureBuilder.error}');
                                    else
                                      return buildChatTile(context, snapshotFutureBuilder.data);
                                }
                              },
                            ),
                          itemCount: snapshot.data.documents.length,
                        );
                      }
                    },
                  ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
