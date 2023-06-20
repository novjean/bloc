import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/chat.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../ui/toaster.dart';

class NewChat extends StatefulWidget {
  // String? token;
  String loungeId;

  NewChat({Key? key, required this.loungeId}) : super(key: key);

  @override
  _NewChatState createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  static const String _TAG = 'NewChat';

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
      padding: const EdgeInsets.only(left: 20, right: 10, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: Colors.white),
              autocorrect: true,
              enableSuggestions: true,
              maxLength: 160,
              decoration: const InputDecoration(labelText: 'send a sms...',
                labelStyle: TextStyle(color: Constants.primary),
                hintStyle: TextStyle(color: Constants.primary),
                counterStyle:
                TextStyle(color: Constants.primary),
              ),
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
                  chat.time = Timestamp.now().millisecondsSinceEpoch;
                  FirestoreHelper.pushChat(chat);

                  FirestoreHelper.updateLoungeLastChat(widget.loungeId, chat.message, chat.time);

                  _controller.clear();
                }
              } else {
                Logx.em(_TAG, 'user is not logged in to chat in lounge ${widget.loungeId}');
                Toaster.longToast('please log in to chat in the community');
              }
            }
          )
        ],
      ),
    );
  }
}
