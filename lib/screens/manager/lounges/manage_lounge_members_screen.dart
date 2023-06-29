import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/user.dart';
import '../../../db/entity/user_lounge.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/lounge/lounge_member_item.dart';
import 'manage_lounge_members_add_screen.dart';

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
  List<String> mMemberIds = [];

  List<User> mUsers = [];
  bool isMembersLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullUserLoungeMembers(widget.loungeId).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);
          mUserLounges.add(userLounge);
          mMemberIds.add(userLounge.userId);
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) =>
                      ManageLoungeMembersAddScreen(loungeId: widget.loungeId,
                        nonMembers: mNonMembers,)),
            );
          },
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          tooltip: 'add members',
          elevation: 5,
          splashColor: Colors.grey,
          child: const Icon(
            Icons.add,
            color: Colors.black,
            size: 29,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        body: isUserLoungesLoading && isMembersLoading
            ? const LoadingWidget()
            : _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return ListView.builder(
        itemCount: mMembers.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          return GestureDetector(
              child: LoungeMemberItem(
                user: mMembers[index],
                loungeId: widget.loungeId,
                isMember: true,
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
        });
  }
}
