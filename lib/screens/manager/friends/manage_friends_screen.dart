import 'package:bloc/db/entity/friend_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/friend.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/logx.dart';
import '../../../widgets/manager/manage_friend_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';

class ManageFriendsScreen extends StatelessWidget {
  static const String _TAG = 'ManageFriendsScreen';

  String blocServiceId;

  ManageFriendsScreen({Key? key,
    required this.blocServiceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title:'manage friends'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirestoreHelper.pullFriendNotifications().then((res) {
            if(res.docs.isNotEmpty){
              for (int i = 0; i < res.docs.length; i++) {
                DocumentSnapshot document = res.docs[i];
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                final FriendNotification noti = Fresh.freshFriendNotificationMap(data, false);
                FirestoreHelper.deleteFriendNotification(noti.id);
              }

              Logx.ist(_TAG, 'deleted ${res.docs.length} friend notification docs');
            } else {
              Logx.ist(_TAG, 'no friend notification docs found to delete');
            }
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'clear friend notifications',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.delete_outline_outlined,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildFriends(context),
    );
  }

  _buildFriends(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getManageFriends(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<Friend> friends = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
                  final Friend friend = Fresh.freshFriendMap(map, false);
                  friends.add(friend);
                }
                return _displayFriends(context, friends);
              }
          }
        });
  }

  _displayFriends(BuildContext context, List<Friend> friends) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: friends.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageFriendItem(
                  friend: friends[index],
                ),
                onTap: () {
                  // Ad sAd = ads[index];
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //       builder: (ctx) => AdAddEditScreen(
                  //         ad: sAd,
                  //         task: 'edit',
                  //       )),
                  // );
                });
          }),
    );
  }
}
