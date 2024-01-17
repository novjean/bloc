import 'dart:io';

import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/entity/user_lounge.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

import '../../api/apis.dart';
import '../../db/entity/lounge_chat.dart';
import '../../db/entity/lounge.dart';
import '../../db/entity/party.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/user.dart';
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

  List<UserLounge> mMembers = [];
  List<UserLounge> mFcmMembers = [];

  List<Party> mParties = [];
  List<Party> sParties = [];

  Party sParty = Dummy.getDummyParty('');
  String sPartyName = 'all';
  String sPartyId = '';
  List<String> mPartyNames = [];

  //for handling message text changes
  final _textController = TextEditingController();

  //isUploading -- for checking if image is uploading or not?
  bool _isUploading = false;
  String photoChatMessage = '';

  List<String> chatViewUpdatedList = [];

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

        FirestoreHelper.pullUserLounge(
                UserPreferences.myUser.id, widget.loungeId)
            .then((res) {
          if (res.docs.isNotEmpty) {
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              mUserLounge = Fresh.freshUserLoungeMap(data, false);
            }

            if (mUserLounge.isBanned) {
              isMember = false;
              GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
            } else {
              isMember = true;
            }

            if (mUserLounge.userFcmToken.isEmpty) {
              if (UserPreferences.myUser.fcmToken.isNotEmpty) {
                mUserLounge = mUserLounge.copyWith(
                    userFcmToken: UserPreferences.myUser.fcmToken);
                FirestoreHelper.pushUserLounge(mUserLounge);
              }
            } else {
              if (UserPreferences.myUser.fcmToken.isNotEmpty &&
                  mUserLounge.userFcmToken != UserPreferences.myUser.fcmToken) {
                mUserLounge = mUserLounge.copyWith(
                    userFcmToken: UserPreferences.myUser.fcmToken);
                FirestoreHelper.pushUserLounge(mUserLounge);
              }
            }

            setState(() {
              isUserLoungeLoading = false;
            });
          } else {
            if (UserPreferences.myUser.clearanceLevel >=
                Constants.MANAGER_LEVEL) {
              setState(() {
                isMember = false;
                isUserLoungeLoading = false;
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mLounge.isVip) {
                  _showPrivateLoungeDialog(context);
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
          title: AppBarTitle(title: mLounge.name,),
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
        floatingActionButton: !isMember
            ? SizedBox(
                height: 150,
                width: 150,
                child: FloatingActionButton(
                  onPressed: () async {
                    UserLounge userLounge = Dummy.getDummyUserLounge();
                    userLounge = userLounge.copyWith(
                        userId: UserPreferences.myUser.id,
                        userFcmToken: UserPreferences.myUser.fcmToken,
                        loungeId: widget.loungeId);
                    FirestoreHelper.pushUserLounge(userLounge);

                    FirebaseMessaging.instance
                        .subscribeToTopic(widget.loungeId);

                    setState(() {
                      isMember = true;
                    });
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  tooltip: 'join lounge',
                  elevation: 5,
                  splashColor: Colors.grey,
                  shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.zero),
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
              )
            : const SizedBox(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: isLoungeLoading && isUserLoungeLoading
            ? const LoadingWidget()
            : _buildBody(context),
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
          child: _loadMessages(),
        ),
        if (_isUploading)
          const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: CircularProgressIndicator(strokeWidth: 2))),
        _chatInput(context),
      ],
    );
  }

  _loadMessages() {
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
                    style:
                        TextStyle(fontSize: 18, color: Constants.lightPrimary),
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
            LoungeChat chat = mChats[index];

            if (!chatViewUpdatedList.contains(chat.id)) {
              chatViewUpdatedList.add(chat.id);
              FirestoreHelper.updateLoungeChatViewCount(chat.id);
              Logx.d(_TAG, 'chat ${chat.id} | views : ${chat.views}');
            }

            return GestureDetector(
              child: ChatItem(
                chat: chat,
                isMe: chat.userId == UserPreferences.myUser.id,
                isMember: isMember,
                // use key for better efficiency
                key: ValueKey(chat.id),
              ),
              onTap: () {
                Logx.d(_TAG, 'chat selected: $index');
              },
              onLongPress: () {
                if (UserPreferences.myUser.clearanceLevel >=
                    Constants.MANAGER_LEVEL) {
                  _showActionsDialog(context, chat);
                }
              },
            );
          }),
    );
  }

  _showActionsDialog(BuildContext context, LoungeChat chat) {
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
                                        FirestoreHelper.pullUserLounge(
                                                chat.userId, mLounge.id)
                                            .then((res) {
                                          if (res.docs.isNotEmpty) {
                                            DocumentSnapshot document =
                                                res.docs[0];
                                            Map<String, dynamic> data =
                                                document.data()!
                                                    as Map<String, dynamic>;
                                            UserLounge userLounge =
                                                Fresh.freshUserLoungeMap(
                                                    data, false);
                                            userLounge = userLounge.copyWith(
                                                isBanned: true);
                                            FirestoreHelper.pushUserLounge(
                                                userLounge);

                                            Logx.ist(_TAG, 'user is banned!');
                                          }
                                        });

                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                          const SizedBox(height: 10),
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
                                        FirestoreHelper.deleteLoungeChat(
                                            chat.id);

                                        String photoUrl = '';
                                        String photoChat = '';

                                        if (chat.type == 'image') {
                                          int firstDelimiterIndex =
                                              chat.message.indexOf('|');
                                          if (firstDelimiterIndex != -1) {
                                            // Use substring to split the string into two parts
                                            photoChat = chat.message.substring(
                                                0, firstDelimiterIndex);
                                            photoUrl = chat.message.substring(
                                                firstDelimiterIndex + 1);
                                          } else {
                                            // Handle the case where the delimiter is not found
                                            photoUrl = chat.message;
                                          }

                                          //need to check here to avoid deleting the party photo by mistake
                                          if (photoUrl.contains(
                                              FirestorageHelper.CHAT_IMAGES)) {
                                            FirestorageHelper.deleteFile(
                                                photoUrl);
                                          }
                                        }
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                          const SizedBox(height: 10),
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
                      DarkButtonWidget(
                        text: '🚪 leave lounge',
                        onClicked: () {
                          FirestoreHelper.deleteUserLounge(mUserLounge.id);

                          List<String> exitedMembers = mLounge.exitedUserIds;
                          exitedMembers.add(mUserLounge.userId);
                          mLounge =
                              mLounge.copyWith(exitedUserIds: exitedMembers);
                          FirestoreHelper.pushLounge(mLounge);

                          FirebaseMessaging.instance
                              .unsubscribeFromTopic(mLounge.id);
                          Logx.ilt(
                              _TAG, 'you have has exited the lounge. bye 👋');

                          GoRouter.of(context).pushReplacementNamed(
                              RouteConstants.landingRouteName);
                        },
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  UserPreferences.myUser.clearanceLevel >= Constants.ADMIN_LEVEL
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: ButtonWidget(
                                text: '♀️💃🏻',
                                onClicked: () async {
                                  FirestoreHelper.pullActiveGuestListParties(
                                          Timestamp.now()
                                              .millisecondsSinceEpoch)
                                      .then((res) {
                                    if (res.docs.isNotEmpty) {
                                      for (int i = 0;
                                          i < res.docs.length;
                                          i++) {
                                        DocumentSnapshot document = res.docs[i];
                                        Map<String, dynamic> data = document
                                            .data()! as Map<String, dynamic>;
                                        final Party party =
                                            Fresh.freshPartyMap(data, true);
                                        mParties.add(party);
                                        mPartyNames.add(
                                            '${party.name} ${party.chapter}');
                                      }

                                      _showPartiesAndInvite(
                                          context, true, false, false);
                                    }
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: ButtonWidget(
                                text: '♂️🕺🏼',
                                onClicked: () async {
                                  FirestoreHelper.pullActiveGuestListParties(
                                          Timestamp.now()
                                              .millisecondsSinceEpoch)
                                      .then((res) {
                                    if (res.docs.isNotEmpty) {
                                      for (int i = 0;
                                          i < res.docs.length;
                                          i++) {
                                        DocumentSnapshot document = res.docs[i];
                                        Map<String, dynamic> data = document
                                            .data()! as Map<String, dynamic>;
                                        final Party party =
                                            Fresh.freshPartyMap(data, true);
                                        mParties.add(party);
                                        mPartyNames.add(
                                            '${party.name} ${party.chapter}');
                                      }

                                      _showPartiesAndInvite(
                                          context, false, true, false);
                                    }
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: ButtonWidget(
                                text: '☿️🦄',
                                onClicked: () async {
                                  FirestoreHelper.pullActiveGuestListParties(
                                          Timestamp.now()
                                              .millisecondsSinceEpoch)
                                      .then((res) {
                                    if (res.docs.isNotEmpty) {
                                      for (int i = 0;
                                          i < res.docs.length;
                                          i++) {
                                        DocumentSnapshot document = res.docs[i];
                                        Map<String, dynamic> data = document
                                            .data()! as Map<String, dynamic>;
                                        final Party party =
                                            Fresh.freshPartyMap(data, true);
                                        mParties.add(party);
                                        mPartyNames.add(
                                            '${party.name} ${party.chapter}');
                                      }

                                      _showPartiesAndInvite(
                                          context, false, false, true);
                                    }
                                  });
                                },
                              ),
                            ),
                            ButtonWidget(
                              text: '♂️☿️♀️🧜🏻',
                              onClicked: () {
                                FirestoreHelper.pullActiveGuestListParties(
                                        Timestamp.now().millisecondsSinceEpoch)
                                    .then((res) {
                                  if (res.docs.isNotEmpty) {
                                    for (int i = 0; i < res.docs.length; i++) {
                                      DocumentSnapshot document = res.docs[i];
                                      Map<String, dynamic> data = document
                                          .data()! as Map<String, dynamic>;
                                      final Party party =
                                          Fresh.freshPartyMap(data, true);
                                      mParties.add(party);
                                      mPartyNames.add(
                                          '${party.name} ${party.chapter}');
                                    }

                                    _showPartiesAndInvite(
                                        context, true, true, true);
                                  }
                                });
                              },
                            ),
                          ],
                        )
                      : const SizedBox(),
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

  _showPartiesAndInvite(
      BuildContext context, bool checkFemale, bool checkMale, bool checkTrans) {
    String defaultTitle = 'You\'re invited! 💛';
    String defaultMessage =
        'you are exclusively invited to this party 🎉! Entry\'s on a first come, first serve basis. Come in early or reserve a table for a guaranteed spot. 💖';

    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5.0,
                      bottom: 10,
                    ),
                    child: const Text(
                      '🎟️ invite members to party',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  MultiSelectDialogField(
                    items: mParties
                        .map(
                            (e) => MultiSelectItem(e, '${e.name} ${e.chapter}'))
                        .toList(),
                    initialValue: sParties.map((e) => e).toList(),
                    listType: MultiSelectListType.CHIP,
                    buttonIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade700,
                    ),
                    title: const Text('pick a party'),
                    buttonText: const Text(
                      'select',
                      style: TextStyle(color: Constants.darkPrimary),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        width: 0.0,
                      ),
                    ),
                    searchable: true,
                    onConfirm: (values) {
                      setState(() {
                        sParties = values;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFieldWidget(
                    label: 'title',
                    text: defaultTitle,
                    maxLength: 200,
                    maxLines: 1,
                    onChanged: (text) {
                      defaultTitle = text;
                    },
                  ),
                  TextFieldWidget(
                    label: 'description',
                    text: defaultMessage,
                    maxLength: 1000,
                    maxLines: 7,
                    onChanged: (text) {
                      defaultMessage = text;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Constants.darkPrimary),
              ),
              child: const Text(
                'send invites',
                style: TextStyle(color: Constants.primary),
              ),
              onPressed: () {
                if (sParties.isNotEmpty) {
                  _sendInvites(ctx, defaultTitle, defaultMessage, checkFemale,
                      checkMale, checkTrans);
                  Navigator.of(ctx).pop();
                } else {
                  Logx.ist(_TAG, 'please select a party!');
                }
              },
            ),
          ],
        );
      },
    );
  }

  _sendInvites(BuildContext ctx, String addTitle, String addMessage,
      bool checkFemale, bool checkMale, bool checkTrans) async {
    Party sParty = sParties.first;

    FirestoreHelper.pullPartyGuestsByPartyId(sParty.id).then((res) {
      List<String> partyGuestIds = [];

      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyGuest partyGuest = Fresh.freshPartyGuestMap(data, false);
          partyGuestIds.add(partyGuest.guestId);
        }
      }
      Logx.ist(_TAG, '${partyGuestIds.length} members in guest list');

      FirestoreHelper.pullTixsByPartyId(sParty.id).then((res) {
        List<String> tixUserIds = [];

        if (res.docs.isNotEmpty) {
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final Tix tix = Fresh.freshTixMap(data, false);
            if(tix.isCompleted && tix.isSuccess){
              tixUserIds.add(tix.userId);
            }
          }
        }
        Logx.ist(_TAG, '${tixUserIds.length} members have tixs');

        FirestoreHelper.pullUserLoungeMembers(mLounge.id).then((res) async {
          if (res.docs.isNotEmpty) {
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);
              mMembers.add(userLounge);

              if (userLounge.userFcmToken.isNotEmpty) {
                mFcmMembers.add(userLounge);
              }
            }

            int successCount = 0;
            int failCount = 0;

            for (int i = 0; i < mFcmMembers.length; i++) {
              UserLounge userLounge = mFcmMembers[i];

              //check if user has already requested
              if (partyGuestIds.contains(userLounge.userId) ||
                  tixUserIds.contains(userLounge.userId)) {
                continue;
              }

              await FirestoreHelper.pullUser(userLounge.userId)
                  .then((res) async {
                if (res.docs.isNotEmpty) {
                  DocumentSnapshot document = res.docs[0];
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  final User user = Fresh.freshUserMap(data, false);

                  if (user.clearanceLevel == Constants.CUSTOMER_LEVEL ||
                      user.clearanceLevel == Constants.ADMIN_LEVEL) {
                    if (user.isAppUser && user.fcmToken.isNotEmpty) {
                      if (checkFemale) {
                        if (user.gender != 'female') {
                          return;
                        }
                      } else if (checkMale) {
                        if (user.gender != 'male') {
                          return;
                        }
                      } else if (checkTrans) {
                        if (user.gender == 'male' || user.gender == 'female') {
                          return;
                        }
                      }

                      // notify them of invite
                      PartyGuest partyGuest = Dummy.getDummyPartyGuest(false);
                      partyGuest = partyGuest.copyWith(
                        partyId: sParty.id,
                        guestId: user.id,
                        name: user.name,
                        surname: user.surname,
                        phone: user.phoneNumber.toString(),
                        email: user.email,
                        gender: user.gender,
                        isApproved: true,
                        guestStatus: 'promoter',
                        promoterId: Constants.blocPromoterId,
                      );

                      FirestoreHelper.pushPartyGuest(partyGuest);

                      String title = '🎁 ${sParty.name}, $addTitle';
                      String message = 'Hey ${user.name}, $addMessage';
                      bool isSuccess = await Apis.sendPushNotification(
                          user.fcmToken, title, message);
                      if (isSuccess) {
                        successCount++;
                      } else {
                        failCount++;
                      }
                    }
                  } else {
                    //internal team, no invite will be sent
                  }
                }
              });
            }
            Logx.ilt(_TAG, 'invite success: $successCount | fail: $failCount');
          }
        });
      });
    });

    Navigator.of(ctx).pop();
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
                    ),
                  ),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        if (!kIsWeb) {
                          if (isMember) {
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
                            Toaster.shortToast(
                                'have the 🍕 and join us to post photo');
                          }
                        } else {
                          Toaster.shortToast(
                              'bloc app is required to be able to post photo');
                        }
                      },
                      icon: const Icon(Icons.image,
                          color: Constants.primary, size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        if (!kIsWeb) {
                          if (isMember) {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 95,
                                maxHeight: 768,
                                maxWidth: 440);
                            _storePhotoChat(image);
                          } else {
                            Toaster.longToast(
                                'have the 🍕 and join us to post photo');
                          }
                        } else {
                          Toaster.shortToast(
                              'bloc app is required to be able to post photo');
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
              if (isMember) {
                if (_textController.text.isNotEmpty) {
                  LoungeChat chat = Dummy.getDummyLoungeChat();
                  chat = chat.copyWith(
                    loungeId: mLounge.id,
                    loungeName: mLounge.name,
                    type: FirestoreHelper.CHAT_TYPE_TEXT,
                    message: _textController.text,
                  );

                  StringUtils.getRandomString(5);
                  FirestoreHelper.pushLoungeChat(chat);
                  FirestoreHelper.updateLoungeLastChat(
                      mLounge.id, chat.message, chat.time);

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
      chat = chat.copyWith(
        loungeId: mLounge.id,
        loungeName: mLounge.name,
        imageUrl: imageUrl,
        message: '',
        type: FirestoreHelper.CHAT_TYPE_IMAGE,
      );

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
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: Text(
                      'photo chat',
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    width: MediaQuery.of(context).size.width,
                    child: FadeInImage(
                      placeholder:
                          const AssetImage('assets/images/logo_3x2.png'),
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
                if (chat.message.contains(FirestorageHelper.CHAT_IMAGES)) {
                  FirestorageHelper.deleteFile(chat.message);
                }

                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Constants.darkPrimary),
              ),
              child: const Text(
                "💌 send",
                style: TextStyle(color: Constants.primary),
              ),
              onPressed: () {
                chat = chat.copyWith(message: photoChatMessage);

                FirestoreHelper.pushLoungeChat(chat);
                FirestoreHelper.updateLoungeLastChat(
                    mLounge.id, '📸 $photoChatMessage', chat.time);

                setState(() => _isUploading = false);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showPrivateLoungeDialog(BuildContext context) {
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
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '🔥🌟 Welcome to the VIP vibes! You gotta score an invite, join the guest list or drop a request to join the wave, but hold tight – the admins gonna give it that golden touch before you\'re in the spotlight. It\'s all about that exclusive energy! 🚀👑'
                      .toLowerCase(),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                )
              ],
            ),
          ),
          actions: [
            mLounge.name.isNotEmpty
                ? TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Constants.darkPrimary),
                    ),
                    child: const Text(
                      "🔑 request access",
                      style: TextStyle(color: Constants.primary),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      UserLounge userLounge = Dummy.getDummyUserLounge();
                      userLounge = userLounge.copyWith(
                          userId: UserPreferences.myUser.id,
                          userFcmToken: UserPreferences.myUser.fcmToken,
                          loungeId: mLounge.id,
                          isAccepted: false);
                      FirestoreHelper.pushUserLounge(userLounge);
                      Logx.ist(_TAG,
                          'request to join the vip lounge has been sent 🫰');
                      GoRouter.of(context).pushReplacementNamed(
                          RouteConstants.landingRouteName);
                    },
                  )
                : const SizedBox(),
            TextButton(
              child: const Text("exit"),
              onPressed: () {
                Navigator.of(context).pop();
                GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
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

                return Text(
                  '$count members',
                  style: const TextStyle(
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
