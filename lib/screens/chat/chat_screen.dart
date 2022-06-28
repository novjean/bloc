import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../db/dao/bloc_dao.dart';
import '../../helpers/token_monitor.dart';
import '../../main.dart';
import '../../widgets/chat/messages.dart';
import '../../widgets/chat/new_message.dart';
import '../../widgets/experimental/meta_card.dart';


class ChatScreen extends StatefulWidget {
  BlocDao dao;

  ChatScreen({key, required this.dao}):super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:

      Container(
        child: Column(
          children: [
            MetaCard(
              'FCM Token',
              TokenMonitor((token) {
                _token = token;
                return token == null
                    ? const CircularProgressIndicator()
                    : Text(token, style: const TextStyle(fontSize: 12));
              }),
            ),
            Expanded(
              child: Messages(),
            ),
            NewMessage(_token),
          ],
        ),
      ),
    );
  }
}
