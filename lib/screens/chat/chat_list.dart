import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _chats = <ChatClass>[];

    // Añadir 2 chats para debug
    _loadDebugChats();
  }

  /*
   * Función debug para mostrar dos conversacion con el usuario 1
   * y dos para el 88.
   */
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
              Expanded(
                child: Container(child: _buildChatList()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
