import 'dart:io';

import 'package:bloc/db/entity/user_lounge.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

import '../../api/apis.dart';
import '../../db/entity/lounge_chat.dart';
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
import '../../widgets/ui/textfield_widget.dart';
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

  List<LoungeChat> mChats = [];

  // var _isMembersLoading = true;
  // List<UserLounge> mMembers = [];
  // List<UserLounge> mFcmMembers = [];

  //for handling message text changes
  final _textController = TextEditingController();

  var showDetails = false;

  //isUploading -- for checking if image is uploading or not?
  bool _isUploading = false;

  String photoChatMessage = '';

  @override
  void initState() {
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

            if(mUserLounge.isBanned){
              isMember = false;
              GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
            } else {
              isMember = true;
            }

            if(mUserLounge.userFcmToken.isEmpty){
              if(UserPreferences.myUser.fcmToken.isNotEmpty){
                mUserLounge = mUserLounge.copyWith(userFcmToken: UserPreferences.myUser.fcmToken);
                FirestoreHelper.pushUserLounge(mUserLounge);
              }
            } else {
              if(UserPreferences.myUser.fcmToken.isNotEmpty && mUserLounge.userFcmToken != UserPreferences.myUser.fcmToken){
                mUserLounge = mUserLounge.copyWith(userFcmToken: UserPreferences.myUser.fcmToken);
                FirestoreHelper.pushUserLounge(mUserLounge);
              }
            }

            setState(() {
              isUserLoungeLoading = false;
            });
          } else {
            if(UserPreferences.myUser.clearanceLevel>=Constants.MANAGER_LEVEL){
              setState(() {
                isMember = false;
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
            }
          }
        });
      } else {
        setState(() {
          isLoungeLoading = false;
        });
      }
    });

    super.initState();

    // FirestoreHelper.pullUserLoungeMembers(widget.loungeId).then((res) {
    //   if (res.docs.isNotEmpty) {
    //     for (int i = 0; i < res.docs.length; i++) {
    //       DocumentSnapshot document = res.docs[i];
    //       Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    //       UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);
    //
    //       if(userLounge.isAccepted && !userLounge.isBanned){
    //         mMembers.add(userLounge);
    //
    //         if(userLounge.userFcmToken.isNotEmpty){
    //           if(userLounge.userId != UserPreferences.myUser.id){
    //             mFcmMembers.add(userLounge);
    //           }
    //         }
    //       }
    //     }
    //     Logx.i(_TAG, 'members in the lounge: ${mMembers.length}');
    //   } else {
    //     //nobody in lounge
    //     Logx.i(_TAG, 'nobody in the lounge yet');
    //   }
    //
    //   setState(() {
    //     _isMembersLoading = false;
    //   });
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
                    _showLoungeDetails(context);
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (kIsWeb) {
                if (UserPreferences.isUserLoggedIn()) {
                  GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                } else {
                  GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
                }
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        backgroundColor: Constants.background,
        floatingActionButton: !isMember? SizedBox(
          height: 150,
          width: 150,
          child: FloatingActionButton(
            onPressed: () async {
              UserLounge userLounge = Dummy.getDummyUserLounge();
              userLounge = userLounge.copyWith(
                userId: UserPreferences.myUser.id,
                userFcmToken: UserPreferences.myUser.fcmToken,
                  loungeId: widget.loungeId
              );
              FirestoreHelper.pushUserLounge(userLounge);

              FirebaseMessaging.instance.subscribeToTopic(widget.loungeId);

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
      stream: FirestoreHelper.getLoungeChats(mLounge.id),
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

                //todo: remove this after testing
                // mChats.add(DummyData.dummyPhotoChat());

                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  final LoungeChat chat = Fresh.freshLoungeChatMap(data, false);

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
                  LoungeChat chat = mChats[index];

                  showActionsDialog(context, chat);
                }
              },
            );
          }),
    );
  }

  showActionsDialog(BuildContext context, LoungeChat chat) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'actions',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    width: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ban user'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () {
                                        FirestoreHelper.pullUserLounge(chat.userId, mLounge.id).then((res){
                                          if(res.docs.isNotEmpty){
                                            DocumentSnapshot document = res.docs[0];
                                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                            UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);
                                            userLounge = userLounge.copyWith(isBanned: true);
                                            FirestoreHelper.pushUserLounge(userLounge);

                                            Logx.ist(_TAG, 'user is banned!');
                                          }
                                        });

                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.cancel),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height:10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('delete chat'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () async {
                                        FirestoreHelper.deleteLoungeChat(chat.id);

                                        String photoUrl = '';
                                        String photoChat = '';

                                        if (chat.type == 'image') {
                                          int firstDelimiterIndex = chat.message.indexOf('|');
                                          if (firstDelimiterIndex != -1) {
                                            // Use substring to split the string into two parts
                                            photoChat = chat.message.substring(0, firstDelimiterIndex);
                                            photoUrl = chat.message.substring(firstDelimiterIndex + 1);
                                          } else {
                                            // Handle the case where the delimiter is not found
                                            photoUrl = chat.message;
                                          }

                                          //need to check here to avoid deleting the party photo by mistake
                                          if(photoUrl.contains('chat_image')){
                                            FirestorageHelper.deleteFile(photoUrl);
                                          }
                                        }
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.delete),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height:10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLoungeDetails(BuildContext context) {
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

                        List<String> exitedMembers = mLounge.exitedUserIds;
                        exitedMembers.add(mUserLounge.userId);
                        mLounge = mLounge.copyWith(exitedUserIds: exitedMembers);
                        FirestoreHelper.pushLounge(mLounge);

                        FirebaseMessaging.instance.unsubscribeFromTopic(mLounge.id);

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
          vertical: MediaQuery.of(context).size.height * .01, horizontal: MediaQuery.of(context).size.width * .025),
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
                          if(isMember){
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 95,
                                maxHeight: 768,
                                maxWidth: 440);
                            _storePhotoChat(image);

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
                                maxHeight: 768,
                                maxWidth: 440);
                            _storePhotoChat(image);
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
                  SizedBox(width: MediaQuery.of(context).size.width * .02),
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: () {
                if(isMember) {
                  if (_textController.text.isNotEmpty) {
                    LoungeChat chat = Dummy.getDummyLoungeChat();
                    chat.loungeId = mLounge.id;
                    chat.loungeName = mLounge.name;
                    chat.message = _textController.text;
                    chat.type = 'text';
                    chat.time = Timestamp.now().millisecondsSinceEpoch;

                    FirestoreHelper.pushLoungeChat(chat);

                    FirestoreHelper.updateLoungeLastChat(
                        mLounge.id, chat.message, chat.time);

                    // for(UserLounge fcmMember in mFcmMembers){
                    //   String title = '🗨️chat: ${chat.loungeName}';
                    //   String msg = '${UserPreferences.myUser.name}: ${chat.message}';
                    //
                    //   Apis.sendChatNotification(fcmMember.userFcmToken, title, msg);
                    // }

                    // if(UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL){
                    //   Logx.ist(_TAG, 'chat notification sent to ${mFcmMembers.length} members');
                    // }

                    _textController.text = '';
                  }
                } else {
                  Toaster.shortToast('have the 🍕 slice and join us to chat');
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
          FirestorageHelper.CHAT_IMAGES,
          StringUtils.getRandomString(28),
          newImage);

      LoungeChat chat = Dummy.getDummyLoungeChat();
      chat.loungeId = mLounge.id;
      chat.loungeName = mLounge.name;
      chat.message = imageUrl;
      chat.type = 'image';
      chat.time = Timestamp.now().millisecondsSinceEpoch;

      _showPhotoChatDialog(context, chat);
    }
  }

  _showPhotoChatDialog(BuildContext context, LoungeChat chat) {
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
                          image: NetworkImage(chat.message),
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
                FirestorageHelper.deleteFile(chat.message);

                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text(
                "💌 send",
                style: TextStyle(color: Constants.primary),
              ),
              onPressed: () {
                String message = '$photoChatMessage|${chat.message}';
                chat = chat.copyWith(message: message);

                FirestoreHelper.pushLoungeChat(chat);
                FirestoreHelper.updateLoungeLastChat(mLounge.id, '📸 $photoChatMessage', chat.time);

                // for(UserLounge fcmMember in mFcmMembers){
                //   String title = '📸 photo: ${chat.loungeName}';
                //   String msg = '${UserPreferences.myUser.name}: $photoChatMessage}';
                //
                //   Apis.sendPushNotification(fcmMember.userFcmToken, title, msg);
                // }

                // if(UserPreferences.myUser.clearanceLevel>=Constants.ADMIN_LEVEL || UserPreferences.myUser.id == Constants.blocUuid){
                //   Logx.ist(_TAG, 'chat notification sent to ${mFcmMembers.length} members');
                // }

                setState(() => _isUploading = false);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showPrivateLoungeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Constants.background,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${mLounge.name} ⚜️ vip lounge',
                  style: const TextStyle(fontSize: 22, color: Colors.black),
                ),
                const SizedBox(height: 20,),
                Text(
                  '🔥🌟 Welcome to the VIP vibes! You gotta score an invite, join the guest list or drop a request to join the wave, but hold tight – the admins gonna give it that golden touch before you\'re in the spotlight. It\'s all about that exclusive energy! 🚀👑'.toLowerCase(),
                  textAlign: TextAlign.center,
                    softWrap: true,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                )
              ],
            ),
          ),
          actions: [
            mLounge.name.isNotEmpty?
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text("🔑 request access", style: TextStyle(color: Constants.primary),),
              onPressed: () {
                Navigator.of(context).pop();
                UserLounge userLounge = Dummy.getDummyUserLounge();
                userLounge = userLounge.copyWith(userId :UserPreferences.myUser.id,
                    userFcmToken: UserPreferences.myUser.fcmToken,
                    loungeId: mLounge.id, isAccepted: false);
                FirestoreHelper.pushUserLounge(userLounge);
                Logx.ist (_TAG, 'request to join the vip lounge has been sent 🫰');
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
            return const Text('...');
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
}
