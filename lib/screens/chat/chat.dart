import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:selit/class/chat_class.dart';
import 'package:selit/screens/chat/message_list.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'package:selit/widgets/chats/message_sent.dart';
import 'package:selit/widgets/chats/message_received.dart';

final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;

var currentUserEmail;
var _scaffoldContext;

class ChatScreen extends StatefulWidget {
  final ChatClass chat;

  ChatScreen(this.chat);

  @override
  ChatScreenState createState() {
    return new ChatScreenState(chat);
  }
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  bool _isComposingMessage = false;
  final reference = FirebaseDatabase.instance.reference().child('messages');

  ChatClass _chat;
  UsuarioClass _usuario;

  ChatScreenState(ChatClass chat) {
    this._chat = chat;
    //_leerIdUsuario();
  }

  static final _styleTitle =
      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

/*
  void _leerIdUsuario() async {
    int idAnunciante = _chat.usuarioAnunciante.userId;
    int miId = await Storage.loadUserId();
    print('Mi id ' + miId.toString());
    print('Id Anunciante ' + idAnunciante.toString());
    if (miId == idAnunciante) {
      setState(() {
        _usuario = _chat.usuarioCliente;
      }
    );
    }
    else{
      setState(() {
        _usuario = _chat.usuarioAnunciante;
      });
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    Widget image = _usuario.profileImage == null
        ? Container()
        : Container(
            padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, right: 10.0),
            child: SizedBox.fromSize(
                size: Size(50.0, double.infinity),
                child: ProfilePicture(_chat.usuario.profileImage)));
    return new Scaffold(
        appBar: new AppBar(
          title: InkWell(
            onTap: (){
              Navigator.of(context)
                          .pushNamed('/profile', arguments: _chat.usuario.userId);
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
                  image,
                  Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          _chat.usuario.nombre + ' ' + _chat.usuario.apellidos,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: _styleTitle)))
                ],
              ),
            )),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[

              //Para debug del estilo de los mensajes
              //TODO: borrar cuando se obtengan los mensajes de firebase.
              MessageReceivedTile('Mensaje recibido...', '18:00'),
              MessageSentTile('Mensaje enviado...', '18:00'),

              //TODO: Descomentar para obtener mensajes de firebase.
              /*
              new Flexible(
                child: new FirebaseAnimatedList(
                  query: reference,
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  sort: (a, b) => b.key.compareTo(a.key),
                  //comparing timestamp of messages to check which one would appear first
                  itemBuilder: (_, DataSnapshot messageSnapshot,
                      Animation<double> animation, int i) {
                    return new ChatMessageListItem(
                      messageSnapshot: messageSnapshot,
                      animation: animation,
                    );
                  },
                ),
              ),*/

              new Divider(height: 1.0),
              new Container(
                decoration:
                    new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
              new Builder(builder: (BuildContext context) {
                _scaffoldContext = context;
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
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isComposingMessage
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(
                      Icons.photo_camera,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
                      /*
                      await _ensureLoggedIn();
                      File imageFile = await ImagePicker.pickImage();
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      StorageReference storageReference = FirebaseStorage
                          .instance
                          .ref()
                          .child("img_" + timestamp.toString() + ".jpg");
                      StorageUploadTask uploadTask =
                          storageReference.put(imageFile);
                      Uri downloadUrl = (await uploadTask.future).downloadUrl;
                      _sendMessage(
                          messageText: null, imageUrl: downloadUrl.toString());

                          */
                    }),
              ),
              new Flexible(
                child: new TextField(
                  controller: _textEditingController,
                  onChanged: (String messageText) {
                    setState(() {
                      _isComposingMessage = messageText.length > 0;
                    });
                  },
                  onSubmitted: _textMessageSubmitted,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
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

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });
    _sendMessage(messageText: text, imageUrl: null);
  }

  void _sendMessage({String messageText, String imageUrl}) {
    reference.push().set({
      'text': messageText,
      'email': '',
      'imageUrl': imageUrl,
      'senderName': '',
      'senderPhotoUrl': '',
      'time': ''
    });

    analytics.logEvent(name: 'send_message');
  }
}