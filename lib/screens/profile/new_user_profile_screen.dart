import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/user.dart' as blocUser;
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/ui/app_bar_title.dart';

class NewUserProfileScreen extends StatefulWidget{
  String username;

  NewUserProfileScreen({key, required this.username});

  @override
  State<NewUserProfileScreen> createState() => _NewUserProfileScreenState();
}

class _NewUserProfileScreenState extends State<NewUserProfileScreen> {
  static const String _TAG = 'NewUserProfileScreen';


  blocUser.User mUser = Dummy.getDummyUser();
  var _isUserLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullUserByUsername(widget.username).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mUser = Fresh.freshUserMap(data, false);

        setState(() {
          _isUserLoading = false;
        });

        // FirestoreHelper.pullHistoryMusicByUser(mUser.id).then((res) {
        //   if (res.docs.isEmpty) {
        //     setState(() {
        //       showMusicHistory = false;
        //       isMusicHistoryLoading = false;
        //     });
        //   } else {
        //     for (int i = 0; i < res.docs.length; i++) {
        //       DocumentSnapshot document = res.docs[i];
        //       Map<String, dynamic> data =
        //       document.data()! as Map<String, dynamic>;
        //       final HistoryMusic historyMusic =
        //       Fresh.freshHistoryMusicMap(data, false);
        //       mHistoryMusics.add(historyMusic);
        //     }
        //
        //     setState(() {
        //       showMusicHistory = true;
        //       isMusicHistoryLoading = false;
        //     });
        //   }
        // });
        //
        // FirestoreHelper.pullPartyPhotosByUserId(mUser.id).then((res) {
        //   if (res.docs.isNotEmpty) {
        //     for (int i = 0; i < res.docs.length; i++) {
        //       DocumentSnapshot document = res.docs[i];
        //       Map<String, dynamic> data =
        //       document.data()! as Map<String, dynamic>;
        //       PartyPhoto partyPhoto = Fresh.freshPartyPhotoMap(data, false);
        //       mPartyPhotos.add(partyPhoto);
        //     }
        //
        //     setState(() {
        //       _isPartyPhotosLoading = false;
        //     });
        //   } else {
        //     setState(() {
        //       _isPartyPhotosLoading = false;
        //     });
        //   }
        // });
        //
        // if (UserPreferences.isUserLoggedIn()) {
        //   FirestoreHelper.pullFriend(UserPreferences.myUser.id, mUser.id)
        //       .then((res) {
        //     if (res.docs.isNotEmpty) {
        //       DocumentSnapshot document = res.docs[0];
        //       Map<String, dynamic> data =
        //       document.data()! as Map<String, dynamic>;
        //       mFriend = Fresh.freshFriendMap(data, false);
        //
        //       setState(() {
        //         isFriend = true;
        //         _buttonText = '☠️ unfriend';
        //         isFollowing = mFriend.isFollowing;
        //       });
        //     } else {
        //       setState(() {
        //         isFriend = false;
        //         _buttonText = '🤍 friend';
        //         isFollowing = false;
        //       });
        //     }
        //   });
        // }
      } else {
        // profile not found, navigate to home
        Logx.ist(_TAG, 'unfortunately, the profile could not be found');
        GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: ''),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
          },
        ),
      ),
      backgroundColor: Constants.background,
      body: _isUserLoading ? const LoadingWidget(): Column(
        children: [
          Center(
            child: Text(
              'Hello World, ${mUser.name}!',
              style: TextStyle(color: Constants.primary),
            ),
          ),
        ],
      ),
    );
  }
}