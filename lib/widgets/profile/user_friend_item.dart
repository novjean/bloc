import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../db/entity/friend.dart';
import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/logx.dart';

class UserFriendItem extends StatefulWidget {
  static const String _TAG = 'UserFriendItem';

  Friend friend;

  UserFriendItem({Key? key, required this.friend}) : super(key: key);

  @override
  State<UserFriendItem> createState() => _UserFriendItemState();
}

class _UserFriendItemState extends State<UserFriendItem> {
  static const String _TAG = 'UserFriendItem';

  User mFriendUser = Dummy.getDummyUser();

  var _isFriendUserLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullUser(widget.friend.friendUserId).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mFriendUser = Fresh.freshUserMap(data, false);

        setState(() {
          _isFriendUserLoading = false;
        });
      } else {
        Logx.est(_TAG,
            'friend user could not be found : ${widget.friend.friendUserId}');

        setState(() {
          _isFriendUserLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // double conversion = friend.hits/friend.reach;

    String dispName = '';
    if(mFriendUser.surname.isNotEmpty){
      dispName = mFriendUser.name[0] + mFriendUser.surname[0];
    } else {
      if(mFriendUser.name.length>1){
        dispName = mFriendUser.name[0] + mFriendUser.name[1];
      } else {
        dispName = mFriendUser.name[0];
      }
    }

    return GestureDetector(
      onTap: () {

        if(mFriendUser.username.isNotEmpty){
          GoRouter.of(context).pushNamed(RouteConstants.profileRouteName, params: {
            'username': mFriendUser.username,
          });
        } else {
          Logx.est(_TAG, 'profile is not created yet!');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SizedBox(
          width: 60.0, // Adjust the width and height for the circle size
          height: 60.0,
          child: _isFriendUserLoading? const SizedBox() : ClipOval(
            child: mFriendUser.imageUrl.isNotEmpty
                ? Image.network(
                    mFriendUser.imageUrl, // Replace with your image URL
                    width: 60.0,
                    // Make sure to match the width and height of the Container
                    height: 60.0,
                    fit: BoxFit.cover, // Adjust the BoxFit property as needed
                  )
                : Container(
                    width:
                        60.0, // Adjust the width and height for the circle size
                    height: 60.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Constants.primary, // Set the border color
                        width: 2.0, // Set the border width
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dispName.toLowerCase(), // Your two alphabets
                        style: TextStyle(
                          color: Constants.primary, // Set the text color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
