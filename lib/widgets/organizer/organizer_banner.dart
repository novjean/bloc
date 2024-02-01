import 'package:bloc/db/entity/user_organizer.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/organizer.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class OrganizerBanner extends StatefulWidget {
  static const String _TAG = 'OrganizerBanner';

  Organizer organizer;
  final bool isClickable;

  OrganizerBanner(
      {Key? key,
        required this.organizer,
        required this.isClickable})
      : super(key: key);

  @override
  State<OrganizerBanner> createState() => _OrganizerBannerState();
}

class _OrganizerBannerState extends State<OrganizerBanner> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      // padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Hero(
          tag: widget.organizer.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            child: ListTile(
              leading: widget.organizer.imageUrl.isNotEmpty?
              FadeInImage(
                placeholder: const AssetImage(
                    'assets/icons/logo.png'),
                image: NetworkImage(widget.organizer.imageUrl),
                fit: BoxFit.cover,) : const SizedBox(),
              title: Text(
                  widget.organizer.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: Constants.fontDefault,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${widget.organizer.followersCount} followers'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.event_available_outlined,
                  color: Constants.darkPrimary,),
                onPressed: () {
                  if(UserPreferences.isUserLoggedIn()){
                    FirestoreHelper.pullUserOrganizer(UserPreferences.myUser.id, widget.organizer.id).then((res) {
                      if(res.docs.isEmpty){
                        UserOrganizer userOrganizer = Dummy.getDummyUserOrganizer().copyWith(
                          userId: UserPreferences.myUser.id, organizerId: widget.organizer.id
                        );
                        FirestoreHelper.pushUserOrganizer(userOrganizer);

                        Logx.ist(OrganizerBanner._TAG, 'following ${widget.organizer.name}');
                        setState(() {
                          int count = widget.organizer.followersCount - 1;
                          widget.organizer = widget.organizer.copyWith(followersCount: count);
                          FirestoreHelper.updateOrganizerFollowersCount(widget.organizer.id, true);
                        });
                      } else {
                        try{
                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          UserOrganizer userOrganizer = Fresh.freshUserOrganizerMap(data, false);

                          FirestoreHelper.deleteUserOrganizer(userOrganizer.id);

                          setState(() {
                            int count = widget.organizer.followersCount - 1;
                            widget.organizer = widget.organizer.copyWith(followersCount: count);
                            FirestoreHelper.updateOrganizerFollowersCount(widget.organizer.id, false);
                          });
                        } catch(e) {
                          Logx.em(OrganizerBanner._TAG, 'unfollowing organizer failed');
                        }
                      }
                    });
                  } else {
                    Logx.ist(OrganizerBanner._TAG, 'please login to follow ${widget.organizer.name}');
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}


