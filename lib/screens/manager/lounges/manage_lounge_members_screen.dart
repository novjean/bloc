import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/user.dart';
import '../../../db/entity/user_lounge.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/logx.dart';
import '../../../widgets/lounge/lounge_member_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';

class ManageLoungeMembersScreen extends StatefulWidget {
  String loungeId;

  ManageLoungeMembersScreen({Key? key, required this.loungeId})
      : super(key: key);

  @override
  State<ManageLoungeMembersScreen> createState() =>
      _ManageLoungeMembersScreenState();
}

class _ManageLoungeMembersScreenState extends State<ManageLoungeMembersScreen> {
  static const String _TAG = 'ManageLoungeMembersScreen';

  List<UserLounge> mUserLounges = [];
  bool isUserLoungesLoading = true;

  List<User> mMembers = [];
  List<User> mNonMembers = [];
  List<User> mPendingMembers = [];
  List<User> mBannedMembers = [];
  List<String> mMemberIds = [];
  List<String> mPendingMemberIds = [];
  List<String> mBannedMemberIds = [];

  List<User> mUsers = [];
  bool isMembersLoading = true;

  late List<String> mOptions;
  String sOption = '';

  @override
  void initState() {
    mOptions = ['pending', 'members', 'add', 'banned'];
    sOption = mOptions.first;

    FirestoreHelper.pullUserLoungeMembers(widget.loungeId).then((res) {
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

      isUserLoungesLoading = false;

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
            }
          }
          setState(() {
            isMembersLoading = false;
          });
        } else {
          Logx.em(_TAG, 'no user found!');
          setState(() {
            isMembersLoading = false;
          });
        }
      });
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
        body: isUserLoungesLoading && isMembersLoading
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
                return

                  GestureDetector(
                    child: LoungeMemberItem(
                      user: list[index],
                      loungeId: widget.loungeId,
                      isMember: isMember,
                      isUserLoungePresent:  isUserLoungePresent,
                    ),
                    onDoubleTap: () {
                      User sUser = mMembers[index];
                      Logx.i(_TAG, 'double tap user selected : ${sUser.name}');

                      // showDialog(
                      //   context: context,
                      //   builder: (BuildContext context) {
                      //     return AlertDialog(
                      //       title: Text("delete user : ${sUser.name}"),
                      //       content: const Text(
                      //           "would you like to delete the user?"),
                      //       actions: [
                      //         TextButton(
                      //           child: const Text("yes"),
                      //           onPressed: () {
                      //             if (sUser.imageUrl.isNotEmpty) {
                      //               FirestorageHelper.deleteFile(
                      //                   sUser.imageUrl);
                      //             }
                      //             FirestoreHelper.deleteUser(sUser);
                      //             Logx.i(_TAG, 'user is deleted');
                      //
                      //             Navigator.of(context).pop();
                      //           },
                      //         ),
                      //         TextButton(
                      //           child: const Text("no"),
                      //           onPressed: () {
                      //             Navigator.of(context).pop();
                      //           },
                      //         )
                      //       ],
                      //     );
                      //   },
                      // );
                    },
                    onTap: () {
                      User sUser = mUsers[index];
                      Logx.i(_TAG, 'user selected : ${sUser.name}');

                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (ctx) => UserAddEditScreen(
                      //       user: sUser,
                      //       task: 'edit',
                      //       userLevels: mUserLevels,
                      //     )));
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

}
