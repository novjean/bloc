import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/chat.dart';
import '../../db/entity/lounge.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/chat/chat_item.dart';
import '../../widgets/chat/new_chat.dart';

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

  var showDetails = false;

  @override
  void initState() {
    FirestoreHelper.pullLounge(widget.id).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
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
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show the dialog after the screen finishes loading.
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Center(child: Text('how are you feeling today?')),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.star),
              Icon(Icons.favorite),
              Icon(Icons.add),
              Icon(Icons.thumb_up),
              Icon(Icons.thumb_down),
            ],),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          actions: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   child: Text('OK'),
            // ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: GestureDetector(
          onTap: () {
            showLoungeDetails(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(mLounge.name),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    mLounge.imageUrl,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Constants.background,
      body: isLoungeLoading
          ? const LoadingWidget() : _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: loadMessages(),
        ),
        NewChat(loungeId: mLounge.id),
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
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final Chat chat = Fresh.freshChatMap(data, false);
            chats.add(chat);

            if (i == snapshot.data!.docs.length - 1) {
              return _showChats(context, chats);
            }
          }
        } catch (e) {
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
                child: ChatItem(
                  chat: chats[index],
                  isMe: chats[index].userId == UserPreferences.myUser.id,
                  // use key for better efficiency
                  key: ValueKey(chats[index].userId),
                ),
                onTap: () {
                  Logx.d(_TAG, 'chat selected: $index');
                });
          }),
    );
  }

  final ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.easeIn);
  }

  void showLoungeDetails(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Container(
          color: Constants.background,
          height: 400,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      mLounge.description,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                    color: Constants.primary,
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10, bottom: 5),
                    child: Text('rules',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Constants.primary,
                        fontWeight: FontWeight.normal,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0, left: 10, right: 10),
                    child: Text(
                      mLounge.rules,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Constants.primary,
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
