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
  @override
  ChatListState createState() {
    return new ChatListState();
  }
}

class ChatListState extends State<ChatList> {
  List<ChatClass> _chats = new List();
  int miId;
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    _leerIdUsuario();
    _chats = <ChatClass>[];

  }

  void _leerIdUsuario() async {
    miId = await Storage.loadUserId();
  }

  Future<ChatClass> _getChatData(BuildContext context, DocumentSnapshot document) async {
    ItemClass item = await ItemRequest.getItembyId(itemId: document['idProducto']);
    int idOtro = document['idAnunciante'];
    if(miId == idOtro){
      idOtro = document['idCliente'];
    }
    // Obtener UsuarioClass del otro usuario
    UsuarioClass usuario = await UsuarioRequest.getUserById(idOtro);
    ChatClass chat =  new ChatClass(usuario: usuario, miId: miId, producto: item, visible: document['visible']);
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
              onPress: () {},
              backgroudColor: Colors.transparent),
        ], child: ChatTile(chat)
    ));

  }


  @override
  Widget build(BuildContext context) {
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
              RaisedButton(
                  onPressed : (){
                    print("Presionado");
                    Firestore.instance.runTransaction((transaction) async {
                        await transaction.set(Firestore.instance.collection("users").document(), {'idUser' : 'otro'});
                        
                    });
                  },
                  textColor: Colors.black,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: new Text(
                    "Prueba",
                  ),
              ),
              Expanded(
                child: Container(
                  child: StreamBuilder(
                    stream: Firestore.instance.collection('chat').where('visible', arrayContains: miId).snapshots(),
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
