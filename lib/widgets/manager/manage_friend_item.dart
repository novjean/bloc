import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../db/entity/friend.dart';
import '../../db/entity/user.dart';
import '../../helpers/fresh.dart';
import '../../utils/logx.dart';

class ManageFriendItem extends StatefulWidget{
  static const String _TAG = 'ManageFriendItem';

  Friend friend;

  ManageFriendItem({Key? key, required this.friend}) : super(key: key);

  @override
  State<ManageFriendItem> createState() => _ManageFriendItemState();
}

class _ManageFriendItemState extends State<ManageFriendItem> {
  static const String _TAG = 'ManageFriendItem';

  late User mUser;
  late User mFriendUser;

  var _isUsersLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    List<String> userIds = [widget.friend.userId, widget.friend.friendUserId];

    FirestoreHelper.pullUsersByIds(userIds).then((res) {
      if(res.docs.isNotEmpty){
        List<User> fcmUsers = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          User user = Fresh.freshUserMap(data, false);
          
          if(user.id == widget.friend.userId){
            mUser = user;
          } else {
            mFriendUser = user;
          }

          if(user.fcmToken.isNotEmpty){
            fcmUsers.add(user);
          }

        }

        setState(() {
          _isUsersLoading = false;
        });

      } else {
        Logx.est(_TAG, 'user members could not be found!');
        // widget.partyPhoto = widget.partyPhoto.copyWith(tags: []);

        setState(() {
          _isUsersLoading = false;
        });
      }

    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // double conversion = friend.hits/friend.reach;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.friend.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: _isUsersLoading? const LoadingWidget(): ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: '${mUser.name} : ${mFriendUser.name}',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text:
                          '${DateTimeUtils.getFormattedDate(widget.friend.friendshipDate)} ',
                          style: const TextStyle(
                            fontFamily: Constants.fontDefault,
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: widget.friend.isFollowing,
                    onChanged: (value) {
                      widget.friend = widget.friend.copyWith(isFollowing: value);
                      FirestoreHelper.pushFriend(widget.friend);

                      setState(() {
                        widget.friend;
                      });
                    },
                  ),
                )),
          ),
        ),
      ),
    );
  }
}