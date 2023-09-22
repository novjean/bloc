import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/genre.dart';
import '../../../db/entity/lounge.dart';
import '../../../db/entity/user.dart';
import '../../../db/entity/user_level.dart';
import '../../../db/entity/user_lounge.dart';
import '../../../db/shared_preferences/user_preferences.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/lounge/lounge_member_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';
import '../users/user_add_edit_screen.dart';

class ManageLoungeMembersScreen extends StatefulWidget {
  Lounge lounge;

  ManageLoungeMembersScreen({Key? key, required this.lounge})
      : super(key: key);

  @override
  State<ManageLoungeMembersScreen> createState() =>
      _ManageLoungeMembersScreenState();
}

class _ManageLoungeMembersScreenState extends State<ManageLoungeMembersScreen> {
  static const String _TAG = 'ManageLoungeMembersScreen';

  List<UserLounge> mUserLounges = [];
  bool _isUserLoungesLoading = true;

  List<User> mMembers = [];
  List<User> mNonMembers = [];
  List<User> mFemaleNonMembers = [];
  List<User> mPendingMembers = [];
  List<User> mBannedMembers = [];
  List<User> mExitedMembers = [];

  List<String> mMemberIds = [];
  List<String> mPendingMemberIds = [];
  List<String> mBannedMemberIds = [];

  List<User> mUsers = [];
  bool _isMembersLoading = true;

  late List<String> mOptions;
  String sOption = '';

  List<UserLevel> mUserLevels = [];
  var _isUserLevelsLoading = true;

  List<Genre> mGenres = [];
  var _isGenresLoading = true;

  bool _showUserMusicHistory = false;

  @override
  void initState() {
    mOptions = ['pending', 'members', 'add', 'exited', 'banned'];
    sOption = mOptions.first;

    FirestoreHelper.pullUserLoungeMembers(widget.lounge.id).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);
          mUserLounges.add(userLounge);

          if(userLounge.isBanned){
            mBannedMemberIds.add(userLounge.userId);
          } else {
            if (userLounge.isAccepted) {
              mMemberIds.add(userLounge.userId);
            } else if (!userLounge.isAccepted){
              mPendingMemberIds.add(userLounge.userId);
            }
          }
        }
        Logx.i(_TAG, 'members in the lounge: ${mUserLounges.length}');
      } else {
        //nobody in lounge
        Logx.i(_TAG, 'nobody in the lounge yet');
      }

      _isUserLoungesLoading = false;

      FirestoreHelper.pullUsersSortedName()
          .then((res) {
        if (res.docs.isNotEmpty) {
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final User user = Fresh.freshUserMap(data, false);
            mUsers.add(user);

            if (mMemberIds.contains(user.id)) {
              mMembers.add(user);
            } else if(mPendingMemberIds.contains(user.id)) {
              mPendingMembers.add(user);
            }  else if(mBannedMemberIds.contains(user.id)) {
              mBannedMembers.add(user);
            } else {
              mNonMembers.add(user);

              if(user.gender == 'female'){
                mFemaleNonMembers.add(user);
              }
            }

            if(widget.lounge.exitedUserIds.contains(user.id)){
              mExitedMembers.add(user);
            }
          }
          setState(() {
            _isMembersLoading = false;
          });
        } else {
          Logx.em(_TAG, 'no user found!');
          setState(() {
            _isMembersLoading = false;
          });
        }
      });
    });

    FirestoreHelper.pullUserLevels(UserPreferences.myUser.clearanceLevel)
        .then((res) {
      Logx.i(_TAG, 'successfully retrieved user levels');

      if (res.docs.isNotEmpty) {
        List<UserLevel> _userLevels = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final UserLevel userLevel = UserLevel.fromMap(data);
          _userLevels.add(userLevel);
        }

        setState(() {
          mUserLevels = _userLevels;
          _isUserLevelsLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no user levels found!');
        setState(() {
          _isUserLevelsLoading = false;
        });
      }
    });

    FirestoreHelper.pullGenres().then((res) {
      Logx.i(_TAG, "successfully pulled in all genres ");

      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Genre genre = Fresh.freshGenreMap(data, false);
          mGenres.add(genre);
        }

        if(mounted){
          setState(() {
            _isGenresLoading = false;
          });
        }
      } else {
        Logx.i(_TAG, 'no genres found!');
        if(mounted){
          setState(() {
            _isGenresLoading = false;
          });
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: AppBarTitle(
            title: '${mMembers.length} members',
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showActionsDialog(context);
          },
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: 'actions',
          elevation: 5,
          splashColor: Colors.grey,
          child: const Icon(
            Icons.science,
            color: Constants.darkPrimary,
            size: 29,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        body: _isUserLoungesLoading && _isMembersLoading && _isUserLevelsLoading
          && _isGenresLoading
            ? const LoadingWidget()
            : _buildBody(context));
  }

  _buildBody(BuildContext context) {
    List<User> list = [];
    bool isMember = false;
    bool isUserLoungePresent = true;

    if(sOption == mOptions.first){
      list = mPendingMembers;
    } else if(sOption == mOptions[1]){
      list = mMembers;
      isMember = true;
    } else if(sOption == mOptions[2]) {
      list = mNonMembers;
      isUserLoungePresent = false;
    } else if(sOption == mOptions[3]) {
      list = mExitedMembers;
      isUserLoungePresent = false;
    } else {
      list = mBannedMembers;
    }

    return Column(
      children: [
        displayOptions(context),
        const Divider(),
        Expanded(
          child: ListView.builder(
              itemCount: list.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (ctx, index) {
                User user = list[index];

                bool isExited = false;
                if(widget.lounge.exitedUserIds.contains(user.id)){
                  isExited = true;
                }

                return GestureDetector(
                    child: LoungeMemberItem(
                      user: user,
                      loungeId: widget.lounge.id,
                      isMember: isMember,
                      isUserLoungePresent:  isUserLoungePresent,
                      isExited: isExited,
                      showHistory: _showUserMusicHistory,
                      genres: mGenres,
                    ),
                    onTap: () {
                      User sUser = list[index];
                      Logx.i(_TAG, 'user selected : ${sUser.name}');

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => UserAddEditScreen(
                            user: sUser,
                            task: 'edit',
                            userLevels: mUserLevels,
                          )));
                    });
              }),
        ),
      ],
    );
  }

  displayOptions(BuildContext context) {
    double containerHeight = mq.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: mq.height / 15,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: mq.width / 4,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                  });
                });
          }),
    );
  }

  _showActionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: _actionsList(ctx),
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

  _actionsList(BuildContext ctx) {
    return SizedBox(
      height: mq.height * 0.5,
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
              height: mq.height * 0.45,
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
                        const Text('user info / music history'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () {
                                  Navigator.of(ctx).pop();

                                  setState(() {
                                    _showUserMusicHistory = true;
                                  });

                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.queue_music_outlined,color: Constants.darkPrimary,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('update fcm user lounge'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () {
                                  mUserLounges.sort((a, b) => a.userId.compareTo(b.userId));
                                  mMembers.sort((a, b) => a.id.compareTo(b.id));

                                  int count = 0;
                                  for(UserLounge userLounge in mUserLounges){
                                    if(userLounge.userFcmToken.isEmpty){
                                      for(int i = 0; i<mMembers.length; i++){
                                        User user = mMembers[i];

                                        if(user.id == userLounge.userId && user.fcmToken.isNotEmpty){
                                          userLounge = userLounge.copyWith(userFcmToken: user.fcmToken);
                                          FirestoreHelper.pushUserLounge(userLounge);
                                          count++;
                                        }
                                      }
                                    }
                                  }

                                  Logx.ist(_TAG, 'successfully completed updating lounge fcm token for $count members');
                                  Navigator.of(ctx).pop();
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.token_sharp,color: Constants.darkPrimary,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('add all female'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () {
                                  Navigator.of(ctx).pop();

                                  int count = 0;
                                  for(User user in mFemaleNonMembers){
                                    if(!(widget.lounge.exitedUserIds.contains(user.id))){
                                      UserLounge userLounge = Dummy.getDummyUserLounge();
                                      userLounge = userLounge.copyWith(
                                          loungeId : widget.lounge.id,
                                          userId: user.id,
                                        userFcmToken: user.fcmToken
                                      );
                                      FirestoreHelper.pushUserLounge(userLounge);
                                      count++;
                                    }
                                  }
                                  Logx.ist(_TAG, '${widget.lounge.name} has $count new female members! 🥳');

                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.female, color: Colors.pinkAccent,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('add all'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () {
                                  Navigator.of(ctx).pop();

                                  int count = 0;
                                  for(User user in mNonMembers){
                                    if(!(widget.lounge.exitedUserIds.contains(user.id))){
                                      UserLounge userLounge = Dummy.getDummyUserLounge();
                                      userLounge = userLounge.copyWith(loungeId : widget.lounge.id,
                                          userId: user.id, userFcmToken: user.fcmToken);
                                      FirestoreHelper.pushUserLounge(userLounge);
                                      count++;
                                    }
                                  }
                                  Logx.ist(_TAG, '${widget.lounge.name} has $count new members! 🥳');

                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.add_reaction_sharp),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('remove all'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () {
                                  Navigator.of(ctx).pop();

                                  FirestoreHelper.pullUserLoungeMembers(widget.lounge.id).then((res) {
                                    if(res.docs.isNotEmpty){
                                      for (int i = 0; i < res.docs.length; i++) {
                                        DocumentSnapshot document = res.docs[i];
                                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                        UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);
                                        FirestoreHelper.deleteUserLounge(userLounge.id);
                                      }

                                      Logx.ist(_TAG, 'removed ${res.docs.length} members of ${widget.lounge.name}');
                                    }
                                  });
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.person_remove_alt_1_outlined,
                                        color: Constants.errorColor),
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
    );
  }
}
