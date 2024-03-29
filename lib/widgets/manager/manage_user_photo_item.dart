import 'package:bloc/db/entity/friend_notification.dart';
import 'package:bloc/db/entity/party_photo.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../db/entity/user.dart';
import '../../db/entity/user_photo.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/logx.dart';

class ManageUserPhotoItem extends StatefulWidget{
  UserPhoto userPhoto;

  ManageUserPhotoItem({Key? key, required this.userPhoto}) : super(key: key);

  @override
  State<ManageUserPhotoItem> createState() => _ManageUserPhotoItemState();
}

class _ManageUserPhotoItemState extends State<ManageUserPhotoItem> {
  static const String _TAG = 'ManageUserPhotoItem';

  late PartyPhoto mPhoto;
  late User mUser;

  var _isPhotoLoading = true;
  var _isUserLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullPartyPhoto(widget.userPhoto.partyPhotoId).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mPhoto = Fresh.freshPartyPhotoMap(data, false);

        setState(() {
          _isPhotoLoading = false;
        });
      } else {
        Logx.est(_TAG, 'photo could not be found');
        setState(() {
          mPhoto = Dummy.getDummyPartyPhoto();
          _isPhotoLoading = false;
        });
      }
    });

    super.initState();

    FirestoreHelper.pullUser(widget.userPhoto.userId).then((res){
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
        mUser = Fresh.freshUserMap(map, true);

        if(mUser.username.isEmpty){
          String username = '';
          if(mUser.surname.trim().isNotEmpty){
            username = '${mUser.name.trim().toLowerCase()}_${mUser.surname.trim().toLowerCase()}';
          } else {
            username = mUser.name.trim().toLowerCase();
          }

          mUser = mUser.copyWith(username: username);
          FirestoreHelper.pushUser(mUser);
        }

        setState(() {
          _isUserLoading = false;
        });
      } else {
        setState(() {
          mUser = Dummy.getDummyUser();
          _isUserLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.userPhoto.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: _isPhotoLoading && _isUserLoading? const LoadingWidget() :
            Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading: FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(mPhoto.imageThumbUrl.isNotEmpty? mPhoto.imageThumbUrl: mPhoto.imageUrl),
                    fit: BoxFit.cover,),
                  title: RichText(
                    text: TextSpan(
                      text: '${mPhoto.partyName} ',
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
                      Text('${mUser.name } ${mUser.surname}'),
                      Text(''),
                    ],
                  ),
                  trailing: Checkbox(
                    value: widget.userPhoto.isConfirmed,
                    onChanged: (value) {
                      widget.userPhoto = widget.userPhoto.copyWith(isConfirmed: value);
                      FirestoreHelper.pushUserPhoto(widget.userPhoto);

                      if(value!){
                        // add tag to photo
                        if(!mPhoto.tags.contains(widget.userPhoto.userId)){
                          List<String> tags = mPhoto.tags;
                          tags.add(widget.userPhoto.userId);
                          mPhoto = mPhoto.copyWith(tags: tags);

                          FirestoreHelper.pushPartyPhoto(mPhoto);
                          Logx.ist(_TAG, '${mUser.name} tagged to the photo');

                          _showNotifyFriendsDialog(context);
                        } else {
                          Logx.ist(_TAG, '${mUser.name} is already tagged to the photo');
                        }
                      } else {
                        List<String> tags = mPhoto.tags;
                        tags.remove(widget.userPhoto.userId);

                        FirestoreHelper.pushPartyPhoto(mPhoto);
                        Logx.ist(_TAG, '${mUser.name} is not tagged to the photo');
                      }

                      setState(() {
                        widget.userPhoto;
                      });

                    },
                  ),
                )),
          ),
        ),
      ),
    );
  }

  _showNotifyFriendsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(
            'notify ${mUser.name}\'s followers',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: const Text(
              "are you sure you want to notify them?"),
          actions: [
            TextButton(
              child: const Text("yes"),
              onPressed: () async {
                Navigator.of(context).pop();

                FriendNotification notification = Dummy.getDummyFriendNotification();
                notification = notification.copyWith(topic: mUser.id,
                    imageUrl: mPhoto.imageUrl,
                    title: '🤩 ${mUser.name} has a new photo'.toLowerCase(),
                    message: 'Latest pic just landed, catch ${mUser.name} in the spotlight! 📸💝'.toLowerCase()
                );
                FirestoreHelper.pushFriendNotification(notification);

                Logx.ist(_TAG, 'friend notification sent to all followers of ${mUser.name}');
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text("no"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

}