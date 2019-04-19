import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:selit/widgets/chats/message_sent.dart';
import 'package:selit/widgets/chats/message_received.dart';

var currentUserEmail;

class ChatMessageListItem extends StatelessWidget {
  final DataSnapshot messageSnapshot;
  final Animation animation;

  ChatMessageListItem({this.messageSnapshot, this.animation});

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor:
          new CurvedAnimation(parent: animation, curve: Curves.decelerate),
      child: currentUserEmail == messageSnapshot.value['email']
          ? getSentMessageLayout(context)
          : getReceivedMessageLayout(context),
    );
  }

  Widget getSentMessageLayout(BuildContext context) {
    return new MessageSentTile(messageSnapshot.value['text'], messageSnapshot.value['time']);
  }

  Widget getReceivedMessageLayout(BuildContext context) {
    return new MessageReceivedTile(messageSnapshot.value['text'], messageSnapshot.value['time']);
  }
}
