import 'dart:io';

import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../db/entity/chat.dart';
import '../../db/entity/lounge.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/chat/chat_item.dart';
import '../../widgets/ui/toaster.dart';

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

  List<Chat> mChats = [];

  //for handling message text changes
  final _textController = TextEditingController();

  var showDetails = false;

  //isUploading -- for checking if image is uploading or not?
  bool _isUploading = false;

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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Show the dialog after the screen finishes loading.
    //   showDialog(
    //     context: context,
    //     builder: (_) => AlertDialog(
    //       title: Center(child: Text('how are you feeling today?')),
    //       content: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //         children: [
    //           Icon(Icons.star),
    //           Icon(Icons.favorite),
    //           Icon(Icons.add),
    //           Icon(Icons.thumb_up),
    //           Icon(Icons.thumb_down),
    //         ],),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(10.0),
    //       ),
    //       actions: [
    //         // TextButton(
    //         //   onPressed: () {
    //         //     Navigator.pop(context);
    //         //   },
    //         //   child: Text('OK'),
    //         // ),
    //       ],
    //     ),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
        body: isLoungeLoading ? const LoadingWidget() : _buildBody(context),
      ),
    );
  }

  _buildBody(BuildContext context) {
    // return loadMessages();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: loadMessages(),
        ),
        // NewChat(loungeId: mLounge.id),
        _chatInput(context),
      ],
    );
  }

  loadMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getChats(mLounge.id),
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
                  final Chat chat = Fresh.freshChatMap(data, false);
                  mChats.add(chat);
                }

                if(mChats.isNotEmpty){
                  return _showChats();
                } else {
                  return const Center(child: Text('say hi 👋', style: TextStyle(fontSize: 18),));
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom();
      }
    });

    return Expanded(
      child: ListView.builder(
          reverse: true,
          itemCount: mChats.length,
          // controller: _scrollController,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ChatItem(
                  chat: mChats[index],
                  isMe: mChats[index].userId == UserPreferences.myUser.id,
                  // use key for better efficiency
                  key: ValueKey(mChats[index].id),
                ),
                onTap: () {
                  Logx.d(_TAG, 'chat selected: $index');
                }, onLongPress: () {
                  if(UserPreferences.myUser.clearanceLevel> Constants.MANAGER_LEVEL){
                    Chat chat = mChats[index];
                    FirestoreHelper.deleteChat(chat.id);
                  }
            },

                );
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
                  const Padding(
                    padding: EdgeInsets.only(top: 10, right: 10, bottom: 5),
                    child: Text(
                      'rules',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Constants.primary,
                        fontWeight: FontWeight.normal,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 5.0, left: 10, right: 10),
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

  Widget _chatInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
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
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 95,
                            maxWidth: 768);
                        storePhotoChat(image);

                        // // Picking multiple images
                        // final List<XFile> images =
                        // await picker.pickMultiImage(imageQuality: 70);
                        //
                        // // uploading & sending image one by one
                        // for (var i in images) {
                        //   Logx.i(_TAG, 'image path: ${i.path}');
                        //   setState(() => _isUploading = true);
                        //
                        //   // await APIs.sendChatImage(widget.user, File(i.path));
                        //   setState(() => _isUploading = false);
                        // }
                      },
                      icon: const Icon(Icons.image,
                          color: Constants.primary, size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 95,
                            maxWidth: 768);
                        storePhotoChat(image);
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Constants.primary, size: 26)),

                  //adding some space
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: () {
              if (UserPreferences.isUserLoggedIn()) {
                if (_textController.text.isNotEmpty) {
                  Chat chat = Dummy.getDummyChat();
                  chat.loungeId = mLounge.id;
                  chat.message = _textController.text;
                  chat.type = 'text';
                  chat.time = Timestamp.now().millisecondsSinceEpoch;
                  FirestoreHelper.pushChat(chat);

                  FirestoreHelper.updateLoungeLastChat(
                      mLounge.id, chat.message, chat.time);
                  _textController.text = '';
                }
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }

  void storePhotoChat(XFile? image) async {
    if (image != null) {
      Logx.i(_TAG, 'image path: ${image.path}');
      setState(() => _isUploading = true);

      final directory = await getApplicationDocumentsDirectory();
      final name = basename(image.path);
      final imageFile = File('${directory.path}/$name');
      final newImage = await File(image.path).copy(imageFile.path);

      String imageUrl = await FirestorageHelper.uploadFile(
          FirestorageHelper.CHAT_IMAGES,
          StringUtils.getRandomString(28),
          newImage);

      Chat chat = Dummy.getDummyChat();
      chat.loungeId = mLounge.id;
      chat.message = imageUrl;
      chat.type = 'image';
      chat.time = Timestamp.now().millisecondsSinceEpoch;
      FirestoreHelper.pushChat(chat);

      FirestoreHelper.updateLoungeLastChat(mLounge.id, chat.message, chat.time);

      setState(() => _isUploading = false);
    }
  }
}
