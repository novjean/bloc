import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/chat.dart';
import '../../db/entity/lounge.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../helpers/token_monitor.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/new_message.dart';

class LoungeChatScreen extends StatefulWidget {
  String id;

  LoungeChatScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<LoungeChatScreen> createState() => _LoungeChatScreenState();
}

class _LoungeChatScreenState extends State<LoungeChatScreen> {
  static const String _TAG = 'LoungeChatScreen';

  Lounge mLounge = Dummy.getDummyLounge();
  var isLoungeLoading = true;

  // String? _token;

  @override
  void initState() {
    FirestoreHelper.pullLounge(widget.id).then((res) {
      if(res.docs.isNotEmpty){
        for(int i=0;i<res.docs.length;i++){
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          mLounge = Fresh.freshLoungeMap(data, false);
        }
        setState(() {
          isLoungeLoading = false;
        });
      } else {
        setState(() {
          isLoungeLoading = false;
        });
      }
    });

    // TokenMonitor((token) {
    //   _token = token;
    //   return token == null
    //       ? const SizedBox()
    //       : Text(token, style: const TextStyle(fontSize: 12));
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bloc | ${mLounge.name}'),
      ),
      backgroundColor: Constants.background,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: loadMessages(),
        ),
        NewMessage(loungeId: mLounge.id),
      ],
    );
  }

  loadMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getChats(mLounge.id),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        try {
          List<Chat> chats = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data = document.data()! as Map<String,
                dynamic>;
            final Chat chat = Fresh.freshChatMap(data, false);
            chats.add(chat);

            if (i == snapshot.data!.docs.length - 1) {
              return _showChats(context, chats);
            }
          }
        } catch (e){
          Logx.em(_TAG, e.toString());
        }

        return const LoadingWidget();
      },
    );
  }

  _showChats(BuildContext context, List<Chat> chats) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Expanded(
      child: ListView.builder(
          itemCount: chats.length,
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: MessageBubble(
                  chat: chats[index],
                  isMe: chats[index].userId == UserPreferences.myUser.id,
                  // use key for better efficiency
                  key: ValueKey(chats[index].userId),
                ),
                onTap: () {
                  Logx.d(_TAG, 'chat selected : ' + index.toString());
                });
          }),
    );
  }

  final ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.linear);
  }
}
