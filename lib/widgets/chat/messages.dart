import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../db/entity/chat.dart';
import '../../helpers/firestore_helper.dart';
import 'message_bubble.dart';

class Messages extends StatelessWidget {
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _stream = FirestoreHelper.getChatsSnapshot();

    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return LoadingWidget();
          }
          List<Chat> chats = [];

          for (int i=0; i<chatSnapshot.data!.docs.length; i++) {
            DocumentSnapshot document = chatSnapshot.data!.docs[i];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            final Chat chat = Chat.fromJson(data);
            chats.add(chat);

            if (i == chatSnapshot.data!.docs.length - 1) {
              return _displayChats(context, chats);
            }
          }
          return Text('loading chats...');
        });
  }

  ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.linear);
  }

  _displayChats(
      BuildContext context, List<Chat> chats) {
    final user = FirebaseAuth.instance.currentUser;

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
                  isMe: chats[index].userId == user!.uid,
                  // use key for better efficiency
                  key: ValueKey(chats[index].userId),
                ),
                onTap: () {
                  logger.d(
                      'chat selected : ' + index.toString());
                });
          }),
    );
  }

}