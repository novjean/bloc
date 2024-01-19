import 'package:bloc/helpers/dummy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../db/entity/support_chat.dart';
import '../../../db/shared_preferences/user_preferences.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../routes/route_constants.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/support_chat/support_chat_item.dart';
import '../../../widgets/ui/loading_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class ManageSupportChatsScreen extends StatefulWidget {
  @override
  State<ManageSupportChatsScreen> createState() => _ManageSupportChatsScreenState();
}

class _ManageSupportChatsScreenState extends State<ManageSupportChatsScreen> {
  static const String _TAG = 'SupportScreen';

  final _textController = TextEditingController();

  List<SupportChat> mChats = [];

  String photoChatMessage = '';
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 40,
                width: 35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/icons/logo-adaptive.png"),
                      fit: BoxFit.fitHeight),
                ),
              ),
              InkWell(
                  onTap: () {
                    GoRouter.of(context)
                        .pushNamed(RouteConstants.landingRouteName);
                  },
                  child: const Text('bloc')),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text('manage support', overflow: TextOverflow.ellipsis,),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8.0, right: 10),
                child: CircleAvatar(
                  backgroundImage: AssetImage(
                    'assets/images/logo.png',
                  ),
                ),
              )
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
            onPressed: () {
              GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
            },
          ),
        ),
        // backgroundColor: Constants.l,
        body: _buildBody(context),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: loadMessages(),
        ),

        if (_isUploading)
          const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: CircularProgressIndicator(strokeWidth: 2))),
        //
        // _chatInput(context),
      ],
    );
  }

  loadMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getAllSupportChats(),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
              try {
                mChats = [];

                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
                  final SupportChat chat = Fresh.freshSupportChatMap(data, false);

                  mChats.add(chat);
                }

                if (mChats.isNotEmpty) {
                  return _showChats();
                } else {
                  return const Center(
                      child: Text(
                        'no support chats yet',
                        style: TextStyle(fontSize: 18, color: Constants.lightPrimary),
                      ));
                }
              } catch (e) {
                Logx.em(_TAG, e.toString());
              }
            }
        }
        return const LoadingWidget();
      },
    );
  }

  Widget _showChats() {
    return Expanded(
      child: ListView.builder(
          reverse: true,
          itemCount: mChats.length,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (ctx, index) {
            return GestureDetector(
              child: SupportChatItem(
                chat: mChats[index],
                isMe: mChats[index].userId == UserPreferences.myUser.id,
                // use key for better efficiency
                key: ValueKey(mChats[index].id),
              ),
              onTap: () {
                Logx.d(_TAG, 'chat selected: $index');

                _showReplyDialog(context, mChats[index]);
              },
              onLongPress: () {
                // if (UserPreferences.myUser.clearanceLevel >
                //     Constants.MANAGER_LEVEL) {
                //   LoungeChat chat = mChats[index];
                //
                //   // showActionsDialog(context, chat);
                // }
              },
            );
          }),
    );
  }

  _showReplyDialog(BuildContext context, SupportChat chat) {

    SupportChat replyChat = Dummy.getDummySupportChat();
    replyChat = replyChat.copyWith(userName: 'bloc',
      userId: chat.userId,
      isResponse: true,
    );

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: mq.height * 0.6,
            width: mq.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding:
                    EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: Text(
                      'photo chat',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Padding(
                  //   padding:
                  //   const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                  //   child: Text(
                  //     DateTimeUtils.getFormattedDate2(partyPhoto.partyDate),
                  //     overflow: TextOverflow.ellipsis,
                  //     style: const TextStyle(fontSize: 16),
                  //   ),
                  // ),
                  // Center(
                  //     child: SizedBox(
                  //       width: mq.width,
                  //       child: FadeInImage(
                  //         placeholder: const AssetImage('assets/images/logo_3x2.png'),
                  //         image: NetworkImage(replyChat.imageUrl),
                  //         fit: BoxFit.contain,
                  //       ),
                  //     )),
                  TextFieldWidget(
                    text: '',
                    maxLines: 5,
                    onChanged: (text) {
                      photoChatMessage = text;
                    },
                    label: 'message',
                  )
                ],
              ),
            ),
          ),
          actions: [

            TextButton(
              child: const Text("cancel"),
              onPressed: () {
                if(replyChat.message.contains(FirestorageHelper.SUPPORT_CHAT_IMAGES)){
                  FirestorageHelper.deleteFile(replyChat.message);
                }

                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary),
              ),
              child: const Text(
                "💌 send",
                style: TextStyle(color: Constants.primary),
              ),
              onPressed: () {
                replyChat = replyChat.copyWith(message: photoChatMessage);

                FirestoreHelper.pushSupportChat(replyChat);
                // FirestoreHelper.updateLoungeLastChat(mLounge.id, '📸 $photoChatMessage', chat.time);

                setState(() => _isUploading = false);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}