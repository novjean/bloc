import 'dart:io';

import 'package:bloc/db/entity/user_lounge.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

import '../../db/entity/chat.dart';
import '../../db/entity/lounge.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/chat/chat_item.dart';
import '../../widgets/ui/dark_button_widget.dart';
import '../../widgets/ui/toaster.dart';

class LoungeChatScreen extends StatefulWidget {
  String loungeId;

  LoungeChatScreen({Key? key, required this.loungeId}) : super(key: key);

  @override
  State<LoungeChatScreen> createState() => _LoungeChatScreenState();
}

class _LoungeChatScreenState extends State<LoungeChatScreen> {
  static const String _TAG = 'LoungeChatScreen';

  Lounge mLounge = Dummy.getDummyLounge();
  var isLoungeLoading = true;

  UserLounge mUserLounge = Dummy.getDummyUserLounge();
  var isUserLoungeLoading = true;
  var isMember = false;

  List<Chat> mChats = [];

  //for handling message text changes
  final _textController = TextEditingController();

  var showDetails = false;

  //isUploading -- for checking if image is uploading or not?
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    FirestoreHelper.pullLounge(widget.loungeId).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          mLounge = Fresh.freshLoungeMap(data, false);
        }
        isLoungeLoading = false;

        FirestoreHelper.pullUserLounge(UserPreferences.myUser.id, widget.loungeId).then((res) {
          if(res.docs.isNotEmpty){
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              mUserLounge = Fresh.freshUserLoungeMap(data, false);
            }

            setState(() {
              isMember = true;
              isUserLoungeLoading = false;
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if(mLounge.isVip){
                showPrivateLoungeDialog(context);
              }
            });

            setState(() {
              isMember = false;
              isUserLoungeLoading = false;
            });
            // todo: popup dialog with lil bit about the community
          }
        });
      } else {
        setState(() {
          isLoungeLoading = false;
        });
      }
    });
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
                    if (UserPreferences.isUserLoggedIn()) {
                      GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                    } else {
                      GoRouter.of(context)
                          .pushNamed(RouteConstants.landingRouteName);
                    }
                  },
                  child: const Text('bloc')),
              const Spacer(),
              Text(mLounge.name, overflow: TextOverflow.ellipsis,),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 10),
                child: GestureDetector(
                  onTap: () {
                    showLoungeDetails(context);
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      mLounge.imageUrl,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        backgroundColor: Constants.background,
        floatingActionButton: !isMember? SizedBox(
          height: 150,
          width: 150,
          child: FloatingActionButton(
            onPressed: () async {
              UserLounge userLounge = Dummy.getDummyUserLounge();
              userLounge = userLounge.copyWith(userId: UserPreferences.myUser.id);
              userLounge = userLounge.copyWith(loungeId: widget.loungeId);
              FirestoreHelper.pushUserLounge(userLounge);

              setState(() {
                isMember = true;
              });
            },
            backgroundColor: Theme.of(context).primaryColor,
            tooltip: 'join lounge',
            elevation: 5,
            splashColor: Colors.grey,
            shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.zero
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_pizza_outlined,
                  color: Theme.of(context).primaryColorDark,
                  size: 28,
                ),
                const Text('join'),
              ],
            ),
          ),
        ): const SizedBox(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        body: isLoungeLoading && isUserLoungeLoading ? const LoadingWidget() : _buildBody(context),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();

    FirestoreHelper.updateUserLoungeLastAccessed(mUserLounge.id);

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

                if (mChats.isNotEmpty) {
                  return _showChats();
                } else {
                  return const Center(
                      child: Text(
                    'say hi 👋',
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
              child: ChatItem(
                chat: mChats[index],
                isMe: mChats[index].userId == UserPreferences.myUser.id,
                isMember: isMember,
                // use key for better efficiency
                key: ValueKey(mChats[index].id),
              ),
              onTap: () {
                Logx.d(_TAG, 'chat selected: $index');
              },
              onLongPress: () {
                if (UserPreferences.myUser.clearanceLevel >
                    Constants.MANAGER_LEVEL) {
                  Chat chat = mChats[index];
                  FirestoreHelper.deleteChat(chat.id);
                }
              },
            );
          }),
    );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      showMembersCount(),
                      DarkButtonWidget(text: 'leave lounge', onClicked: () {
                        FirestoreHelper.deleteUserLounge(mUserLounge.id);

                        Toaster.longToast('you have exited the lounge');
                        Logx.i(_TAG, 'user has exited the lounge');
                        GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);

                      },)
                    ],
                  ),
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
                  //adding some space
                  SizedBox(width: mq.width * .02),
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
                          if(isMember){
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
                          } else {
                            Toaster.shortToast('have the 🍕 and join us to post photo');
                          }
                        } else {
                          Toaster.shortToast('bloc app is required to be able to post photo');
                        }
                      },
                      icon: const Icon(Icons.image,
                          color: Constants.primary, size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        if(!kIsWeb){
                          if(isMember){
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 95,
                                maxWidth: 768);
                            storePhotoChat(image);
                          } else {
                            Toaster.longToast('have the 🍕 and join us to post photo');
                          }
                        } else {
                          Toaster.shortToast('bloc app is required to be able to post photo');
                        }
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
              if(!kIsWeb){
                if(isMember) {
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
                } else {
                  Toaster.shortToast('have the 🍕 slice and join us to chat');
                }
              } else {
                Toaster.shortToast('bloc app is required to be able to chat');
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

  void storePhotoChat(XFile? image) async {
    if (image != null) {
      Logx.i(_TAG, 'image path: ${image.path}');
      setState(() => _isUploading = true);

      final directory = await getApplicationDocumentsDirectory();
      final name = Path.basename(image.path);
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

  showPrivateLoungeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Constants.background,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.lightPrimary,
          content: SizedBox(
            height: mq.height * 0.5,
            width: mq.width * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${mLounge.name} ⚜️ vip lounge',
                  style: const TextStyle(fontSize: 22, color: Colors.black),
                ),
                Text(
                  'Welcome to our exclusive community lounge! Access is reserved for VIPs only. Secure your spot by registering for our upcoming ${mLounge.name} party or impress the community leaders with a compelling request. Get ready for a lounge of fun, laughter, and connections!'.toLowerCase(),
                  textAlign: TextAlign.center,
                  // overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                )
              ],
            ),
          ),
          actions: [
            mLounge.name.isNotEmpty? TextButton(
              child: const Text("request access"),
              onPressed: () {
                Navigator.of(context).pop();
                UserLounge userLounge = Dummy.getDummyUserLounge();
                userLounge = userLounge.copyWith(userId :UserPreferences.myUser.id,
                    loungeId: mLounge.id, isAccepted: false);
                FirestoreHelper.pushUserLounge(userLounge);
                Toaster.longToast('request to join the vip lounge has been sent');
                Logx.i(_TAG, 'user requested to join the vip lounge');
                GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
              },
            ): const SizedBox(),
            TextButton(
              child: const Text("exit"),
              onPressed: () {
                Navigator.of(context).pop();
                GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
              },
            ),
          ],
        );
      },
    );
  }

  showMembersCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getUserLoungeMembers(mLounge.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return Text('...');
          case ConnectionState.active:
          case ConnectionState.done:
            {
              try {
                int count = snapshot.data!.docs.length;

                return Text('$count members', style: const TextStyle(
                  color: Constants.primary,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
                );
              } catch (e) {
                Logx.em(_TAG, e.toString());
              }
            }
        }
        return const LoadingWidget();
      },
    );
  }

  // showMoodDialog(){
    // showDialog(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: Center(child: Text('how are you feeling today?')),
    //     content: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: [
    //         Icon(Icons.star),
    //         Icon(Icons.favorite),
    //         Icon(Icons.add),
    //         Icon(Icons.thumb_up),
    //         Icon(Icons.thumb_down),
    //       ],),
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(10.0),
    //     ),
    //     actions: [
    //       // TextButton(
    //       //   onPressed: () {
    //       //     Navigator.pop(context);
    //       //   },
    //       //   child: Text('OK'),
    //       // ),
    //     ],
    //   ),
    // );
  // }

}
