import 'dart:convert';

import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../helpers/firestore_helper.dart';
import '../ui/toaster.dart';

class NewMessage extends StatefulWidget {
  String? _token;

  NewMessage(this._token);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    FirestoreHelper.sendChatMessage(_enteredMessage);
    _controller.clear();
  }

  Future<void> sendPushMessage() async {
    if (widget._token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(widget._token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  // Crude counter to make messages unique
  int _messageCount = 0;

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload(String? token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'send a message...'),
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
                  FirestoreHelper.sendChatMessage(_enteredMessage);
                  _controller.clear();
                }
              } else {
                Toaster.longToast('log in to chat in the community');
              }

            }
          )
        ],
      ),
    );
  }
}
