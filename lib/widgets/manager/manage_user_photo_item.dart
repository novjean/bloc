import 'package:bloc/db/entity/party_photo.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../db/entity/user.dart';
import '../../db/entity/user_photo.dart';
import '../../helpers/fresh.dart';

class ManageUserPhotoItem extends StatefulWidget{
  UserPhoto userPhoto;

  ManageUserPhotoItem({Key? key, required this.userPhoto}) : super(key: key);

  @override
  State<ManageUserPhotoItem> createState() => _ManageUserPhotoItemState();
}

class _ManageUserPhotoItemState extends State<ManageUserPhotoItem> {
  static const String _TAG = 'ManageUserPhotoItem';

  PartyPhoto photo;
  User user;

  var _isPhotoLoading = true;
  var _isUserLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullPartyPhoto(widget.userPhoto.partyPhotoId).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        photo = Fresh.freshPartyPhotoMap(data, false);

        setState(() {
          _isPhotoLoading = false;
        });
      } else {

      }
    });


    super.initState();
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
            child: _isPhotoLoading && _isUserLoading? const LoadingWidget() : Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading: FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(photo.imageThumbUrl.isNotEmpty? photo.imageThumbUrl: photo.imageUrl),
                    fit: BoxFit.cover,),
                  title: RichText(
                    text: TextSpan(
                      text: '${photo.partyName} ',
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
                      Text('${widget.userPhoto.views} 👁️'),
                      Text('${widget.userPhoto.likers.length + widget.userPhoto.initLikes} 🖤'),
                      Text('${widget.userPhoto.downloadCount} 💾'),
                    ],
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      '${DateTimeUtils.getFormattedDate(widget.userPhoto.endTime)} ',
                      style: const TextStyle(
                        fontFamily: Constants.fontDefault,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}