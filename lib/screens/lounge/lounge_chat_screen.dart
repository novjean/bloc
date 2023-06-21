import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/lounge/lounge_banner.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/chat.dart';
import '../../db/entity/lounge.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../helpers/token_monitor.dart';
import '../../routes/route_constants.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: GestureDetector(
          onTap: () {
            // setState(() {
            //   showDetails = !showDetails;
            // });
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
          ? const LoadingWidget()
          : showDetails
              ? _buildDetailsBody(context)
              : _buildBody(context),
    );
  }

  _buildDetailsBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
            child: LoungeBanner(
          lounge: mLounge,
        )),
        // mLounge.description.isNotEmpty
        //     ? Padding(
        //   padding:
        //   const EdgeInsets.only(left: 5.0, top: 10),
        //   child: Text(
        //     mLounge.description.toLowerCase(),
        //     style: const TextStyle(fontSize: 18),
        //   ),
        // )
        //     : const SizedBox(),
      ],
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // LoungeBanner(lounge: mLounge,),
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
}
