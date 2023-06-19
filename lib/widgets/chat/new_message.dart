import 'dart:convert';

import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../db/entity/chat.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../utils/logx.dart';
import '../ui/toaster.dart';

class NewMessage extends StatefulWidget {
  // String? token;
  String loungeId;

  NewMessage({Key? key, required this.loungeId}) : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  static const String _TAG = 'NewMessage';

  final _controller = TextEditingController();
  var _enteredMessage = '';

  // void _sendMessage() async {
  //   FocusScope.of(context).unfocus();
  //   FirestoreHelper.sendChatMessage(_enteredMessage);
  //   _controller.clear();
  // }

  // Future<void> sendPushMessage() async {
  //   if (widget.token == null) {
  //     print('Unable to send FCM message, no token exists.');
  //     return;
  //   }
  //
  //   try {
  //     await http.post(
  //       Uri.parse('https://api.rnfirebase.io/messaging/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: constructFCMPayload(widget._token),
  //     );
  //     print('FCM request for device sent!');
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Crude counter to make messages unique
  // int _messageCount = 0;

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  // String constructFCMPayload(String? token) {
  //   _messageCount++;
  //   return jsonEncode({
  //     'token': token,
  //     'data': {
  //       'via': 'FlutterFire Cloud Messaging!!!',
  //       'count': _messageCount.toString(),
  //     },
  //     'notification': {
  //       'title': 'Hello FlutterFire!',
  //       'body': 'This notification (#$_messageCount) was created via FCM!',
  //     },
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'send a message...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: const Icon(Icons.send),
            // null means the button will be disabled
            onPressed: () {
              if(UserPreferences.isUserLoggedIn()){
                if(_enteredMessage.trim().isEmpty) {
                  null;
                } else {
                  FocusScope.of(context).unfocus();

                  Chat chat = Dummy.getDummyChat();
                  chat.loungeId = widget.loungeId;
                  chat.message = _enteredMessage;

                  FirestoreHelper.pushChat(chat);

                  _controller.clear();
                }
              } else {
                Logx.em(_TAG, 'user is not logged in to chat in lounge ${widget.loungeId}');
                Toaster.longToast('log in to chat in the community');
              }
            }
          )
        ],
      ),
    );
  }
}
