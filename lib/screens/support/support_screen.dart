import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;

import '../../db/entity/support_chat.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/support_chat/support_chat_item.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/textfield_widget.dart';
import '../manager/support/manage_support_chats_screen.dart';

class SupportScreen extends StatefulWidget {
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const String _TAG = 'SupportScreen';

  final _textController = TextEditingController();

  List<SupportChat> mChats = [];

  String photoChatMessage = '';
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
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
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text('support', overflow: TextOverflow.ellipsis,),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 10),
                child: GestureDetector(
                  onTap: () {
                    if(UserPreferences.myUser.clearanceLevel>Constants.MANAGER_LEVEL){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (ctx) => ManageSupportChatsScreen()),
                      );
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/logo.png',
                    ),
                  ),
                ),
              )
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
            onPressed: () {
              if (kIsWeb) {
                GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        backgroundColor: Constants.background,
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

        _chatInput(context),
      ],
    );
  }

  loadMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getSupportChats(UserPreferences.myUser.id),
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
                        'how can we help you today 👋',
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
                isMe: mChats[index].userName == UserPreferences.myUser.name,
                // use key for better efficiency
                key: ValueKey(mChats[index].id),
              ),
              onTap: () {
                Logx.d(_TAG, 'chat selected: $index');
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

  Widget _chatInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .01,
          horizontal: MediaQuery.of(context).size.width * .025),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(
              color: Constants.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //adding some space
                  SizedBox(width: MediaQuery.of(context).size.width * .02),
                  Expanded(
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Constants.primary),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: () {},
                        decoration: const InputDecoration(
                            hintText: 'type something...',
                            hintStyle: TextStyle(color: Constants.primary),
                            border: InputBorder.none),
                      )),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        if(!kIsWeb){
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 95,
                              maxHeight: 768,
                              maxWidth: 440);
                          _storePhotoChat(image);
                        } else {
                          Logx.ist(_TAG, 'bloc app is required to be able to post photo');
                        }
                      },
                      icon: const Icon(Icons.image,
                          color: Constants.primary, size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        if(!kIsWeb){
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 95,
                              maxHeight: 768,
                              maxWidth: 440);
                          _storePhotoChat(image);
                        } else {
                          Logx.ist(_TAG, 'bloc app is required to be able to post photo');
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Constants.primary, size: 26)),

                  //adding some space
                  SizedBox(width: MediaQuery.of(context).size.width * .02),
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                SupportChat chat = Dummy.getDummySupportChat();
                chat = chat.copyWith(
                  type: FirestoreHelper.CHAT_TYPE_TEXT,
                  message: _textController.text,
                  time: Timestamp.now().millisecondsSinceEpoch,
                );

                FirestoreHelper.pushSupportChat(chat);

                // FirestoreHelper.updateLoungeLastChat(
                //     mLounge.id, chat.message, chat.time);

                _textController.text = '';
              }
            },
            minWidth: 0,
            padding:
            const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Constants.primary,
            child: const Icon(Icons.send, color: Colors.black, size: 22),
          )
        ],
      ),
    );
  }

  void _storePhotoChat(XFile? image) async {
    if (image != null) {
      Logx.i(_TAG, 'image path: ${image.path}');
      setState(() => _isUploading = true);

      final directory = await getApplicationDocumentsDirectory();
      final name = Path.basename(image.path);
      final imageFile = File('${directory.path}/$name');
      final newImage = await File(image.path).copy(imageFile.path);

      String imageUrl = await FirestorageHelper.uploadFile(
          FirestorageHelper.SUPPORT_CHAT_IMAGES,
          StringUtils.getRandomString(28),
          newImage);

      SupportChat chat = Dummy.getDummySupportChat();
      chat = chat.copyWith(
        imageUrl: imageUrl,
        message: '',
        type: FirestoreHelper.CHAT_TYPE_IMAGE,
      );

      _showPhotoChatDialog(context, chat);
    }
  }

  _showPhotoChatDialog(BuildContext context, SupportChat chat) {
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
                  Center(
                      child: SizedBox(
                        width: mq.width,
                        child: FadeInImage(
                          placeholder: const AssetImage('assets/images/logo_3x2.png'),
                          image: NetworkImage(chat.imageUrl),
                          fit: BoxFit.contain,
                        ),
                      )),
                  TextFieldWidget(
                    text: '',
                    maxLines: 3,
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
                if(chat.message.contains(FirestorageHelper.CHAT_IMAGES)){
                  FirestorageHelper.deleteFile(chat.message);
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
                chat = chat.copyWith(message: photoChatMessage);

                FirestoreHelper.pushSupportChat(chat);
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