import 'package:flutter/material.dart';

import '../../helpers/token_monitor.dart';
import '../../widgets/chat/messages.dart';
import '../../widgets/chat/new_message.dart';


class ChatScreen extends StatefulWidget {
  ChatScreen({key}):super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
    TokenMonitor((token) {
      _token = token;
      return token == null
          ? const SizedBox()
          : Text(token, style: const TextStyle(fontSize: 12));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
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
