import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/widgets/chats/chat_tile.dart';
import 'package:selit/class/chat_class.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:selit/widgets/chats/swipe_widget.dart';


class ChatList extends StatefulWidget {
  @override
  ChatListState createState() {
    return new ChatListState();
  }
}

class ChatListState extends State<ChatList> {
  List<ChatClass> _chats = <ChatClass>[];
  int miId;

  @override
  void initState() {
    super.initState();
    _leerIdUsuario();
    _chats = <ChatClass>[];

    // Añadir 2 chats para debug
    //_loadDebugChats();
  }

  void _leerIdUsuario() async {
    miId = await Storage.loadUserId();
  }

  /*
   * Función debug para mostrar dos conversacion con el usuario 1
   * y dos para el 88.
   */
/*

  Future<void> _loadDebugChats() async {
    await UsuarioRequest.getUserById(1).then((user) {
      //Obtener usuario 1
      setState(() {
        _chats.add(new ChatClass(usuario: user));
        _chats.add(new ChatClass(usuario: user));
      });
    }).catchError((error) {
      print('Error al cargar el perfil de usuario: $error');
    });
    await UsuarioRequest.getUserById(88).then((user) {
      //Obtener usuario 1
      setState(() {
        _chats.add(new ChatClass(usuario: user));
        _chats.add(new ChatClass(usuario: user));
      });
    }).catchError((error) {
      print('Error al cargar el perfil de usuario: $error');
    });
    await UsuarioRequest.getUserById(1).then((user) {
      //Obtener usuario 1
      setState(() {
        _chats.add(new ChatClass(usuario: user));
        _chats.add(new ChatClass(usuario: user));
      });
    }).catchError((error) {
      print('Error al cargar el perfil de usuario: $error');
    });
    await UsuarioRequest.getUserById(88).then((user) {
      //Obtener usuario 1
      setState(() {
        _chats.add(new ChatClass(usuario: user));
        _chats.add(new ChatClass(usuario: user));
      });
    }).catchError((error) {
      print('Error al cargar el perfil de usuario: $error');
    });
  }
  */


/*
  Widget _buildChatList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        return new OnSlide(items: <ActionItems>[
          new ActionItems(
              icon: new IconButton(
                icon: new Icon(Icons.delete),
                onPressed: () {},
                color: Colors.red,
              ),
              onPress: () {},
              backgroudColor: Colors.transparent),
        ], child: ChatTile(_chats[index]));
      },
    );
  }
  */


  Widget _buildChatList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        return new OnSlide(items: <ActionItems>[
          new ActionItems(
              icon: new IconButton(
                icon: new Icon(Icons.delete),
                onPressed: () {},
                color: Colors.red,
              ),
              onPress: () {},
              backgroudColor: Colors.transparent),
        ], child: ChatTile(_chats[index]));
      },
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document){
    return Container(
      child: Text(document['idAnunciante'].toString())
    );

  }

  @override
  Widget build(BuildContext context) {
    DocumentReference referenciaNuevoUsuario =
      Firestore.instance.collection("users").document();
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
                          itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
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
