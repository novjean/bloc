import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/user.dart';
import '../../../utils/logx.dart';
import '../../../widgets/lounge/lounge_member_item.dart';

class ManageLoungeMembersAddScreen extends StatefulWidget {
  String loungeId;
  List<User> nonMembers;

  ManageLoungeMembersAddScreen({Key? key, required this.loungeId, required this.nonMembers})
      : super(key: key);

  @override
  State<ManageLoungeMembersAddScreen> createState() =>
      _ManageLoungeMembersAddScreenState();
}

class _ManageLoungeMembersAddScreenState extends State<ManageLoungeMembersAddScreen> {
  static const String _TAG = 'ManageLoungeMembersAddScreen';

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: AppBarTitle(
            title: 'add members',
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //           builder: (ctx) =>
        //               LoungeMembersAddScreen(loungeId: widget.loungeId,)),
        //     );
        //   },
        //   backgroundColor: Theme
        //       .of(context)
        //       .primaryColor,
        //   tooltip: 'add members',
        //   elevation: 5,
        //   splashColor: Colors.grey,
        //   child: const Icon(
        //     Icons.add,
        //     color: Colors.black,
        //     size: 29,
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return ListView.builder(
        itemCount: widget.nonMembers.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          return GestureDetector(
              child: LoungeMemberItem(
                user: widget.nonMembers[index],
                loungeId: widget.loungeId,
                isMember: false,
              ),
              onTap: () {
                User sUser = widget.nonMembers[index];
                Logx.i(_TAG, 'user selected : ${sUser.name}');
              });
        });
  }
}


