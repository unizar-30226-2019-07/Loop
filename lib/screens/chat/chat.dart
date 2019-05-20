import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:selit/class/chat_class.dart';

import 'package:selit/widgets/chats/message_sent.dart';
import 'package:selit/widgets/chats/message_received.dart';

class ChatScreen extends StatefulWidget {
  final ChatClass chat;

  ChatScreen(this.chat);

  @override
  ChatScreenState createState() {
    return new ChatScreenState(chat);
  }
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController _textEditingController = new TextEditingController();
  bool _isComposingMessage = false;

  ChatClass _chat;
  int _miId;
  // var _scaffoldContext;

  ChatScreenState(ChatClass chat) {
    this._chat = chat;
    if (_miId == null){
      _miId = -1; //Quitar null porque sino hará query de todos los chats
    }
    print('CHECK iniciando');
    _leerIdUsuario();
  }

  void _leerIdUsuario() async {
    int idStorage = await Storage.loadUserId();
    setState(() {
      _miId = idStorage;
    });
  }

  static final _styleUsuario =
    TextStyle(fontSize: 14.0, color: Colors.black);
  static final _styleTitle =
      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    Widget itemImage = _chat.producto.media.isEmpty || _chat.producto.media[0] == null
        ? Container()
        : Container(
            padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, right: 10.0),
            child: SizedBox.fromSize(
                size: Size(50.0, double.infinity),
                child: ProfilePicture(_chat.producto.media[0])));
    Widget userImage = _chat.usuario.profileImage == null
        ? Container()
        : Container(
            padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, right: 10.0),
            child: SizedBox.fromSize(
                size: Size(30.0, 30.0),
                child: ProfilePicture(_chat.usuario.profileImage)));
    return new Scaffold(
        appBar: new AppBar(
          title: InkWell(
            onTap: (){
              Navigator.of(context)
                      .pushNamed('/item-details', arguments: _chat.producto);
            },
            splashColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.05),
            highlightColor: Colors.transparent,
            child: new Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: <Widget>[
                      itemImage,
                      Positioned(
                        left: 20.0,
                        top: 20.0,
                        child: userImage)
                    ],
                  ),
                  
                  Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(3.0),
                        child:
                        Column(
                          children: <Widget>[
                            Text(_chat.producto.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: _styleTitle),
                            Text(_chat.usuario.nombre + ' ' + _chat.usuario.apellidos,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: _styleUsuario),
                          ],
                        )
                      ))
                ],
              ),
            )),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: StreamBuilder(
                    stream: Firestore.instance.collection('chat').document(_chat.docId).collection('mensaje').orderBy('fecha', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                          reverse: true,
                          shrinkWrap: true,
                          itemBuilder: (context, index) =>
                            buildMessage(snapshot.data.documents[index]),   
                          itemCount: snapshot.data.documents.length,
                        );
                      }
                    },
                  ),),
              ),
              new Divider(height: 1.0),
              new Container(
                decoration:
                    new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
              new Builder(builder: (BuildContext context) {
                // _scaffoldContext = context;
                return new Container(width: 0.0, height: 0.0);
              })
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(
                      top: new BorderSide(
                  color: Colors.grey[200],
                )))
              : null,
        ));
  }

  CupertinoButton getIOSSendButton() {
    return new CupertinoButton(
      child: new Text("Send"),
      onPressed: (){
        _sendMessage(messageText: _textEditingController.text);
      },
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: (){
        _sendMessage(messageText: _textEditingController.text);
      },
    );
  }

  Widget buildMessage(DocumentSnapshot document){
    // Cambiar a recibido solo los mensajes del otro usuario
    if(document['idEmisor'] != _miId){
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(Firestore.instance.collection("chat").document(document.documentID)
          .collection("mensaje").document(document.documentID), 
          {'contenido' : document['contenido'], 'estado' : 'recibido',
          'fecha' : document['fecha'], 'idEmisor' : document['idEmisor']});
        });
    }
    print('Contenido del mensaje: ' + document['contenido']);
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(document['fecha'].toDate());
    if(_miId == document['idEmisor']){
      return MessageSentTile(document['contenido'], formattedDate, document['estado']);
    }
    else{
      return MessageReceivedTile(document['contenido'], formattedDate);
    }
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isComposingMessage
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.only(left: 8.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  maxLines: 1,
                  controller: _textEditingController,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Envía un mensaje"),
                ),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? getIOSSendButton()
                    : getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  void _sendMessage({String messageText}) async {
    messageText = messageText.trim();
    if(messageText.isNotEmpty){
      _textEditingController.clear();
      print('Enviando mensaje');
      // Falta poner visible al otro si no lo esta
      if(!_chat.visible.contains(_chat.usuario.userId)){
        _chat.visible.add(_chat.usuario.userId);
        print('Cambiando visibilidad');
        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(Firestore.instance.collection("chat").document(_chat.docId), 
            {'idAnunciante' : _chat.usuario.userId, 'idCliente' : _miId,
            'idProducto' : _chat.producto.itemId, 'visible' : _chat.visible,
            'ultimoMensaje' : _chat.lastMessage, 'fechaUltimoMensaje' : _chat.lastMessageDate, 'tipoProducto': _chat.tipoProducto});   
        });
      }
      var fecha = DateTime.now();
      // Mensaje en colleccion mensajes
      await Firestore.instance.collection("chat").document(_chat.docId).collection("mensaje").document().setData({
        'contenido' : messageText, 'estado' : 'enviado',
          'fecha' : fecha, 'idEmisor' : _miId
      });
      Firestore.instance.runTransaction((transaction) async {
          await transaction.set(Firestore.instance.collection("chat").document(_chat.docId), 
            {'idAnunciante' : _chat.usuario.userId, 'idCliente' : _miId,
            'idProducto' : _chat.producto.itemId, 'visible' : _chat.visible,
            'ultimoMensaje' : messageText, 'fechaUltimoMensaje' : fecha, 'tipoProducto': _chat.tipoProducto});   
      });
    } 
  }


}
