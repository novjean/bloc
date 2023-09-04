import 'package:flutter/material.dart';

import '../../../db/entity/party_photo.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';

class ManagePartyPhotoItem extends StatelessWidget{
  static const String _TAG = 'ManagePartyPhotoItem';

  PartyPhoto partyPhoto;

  ManagePartyPhotoItem({Key? key, required this.partyPhoto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: partyPhoto.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading: FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(partyPhoto.imageThumbUrl.isNotEmpty? partyPhoto.imageThumbUrl: partyPhoto.imageUrl),
                    fit: BoxFit.cover,),
                  title: RichText(
                    text: TextSpan(
                      text: '${partyPhoto.partyName} ',
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
                      Text('${partyPhoto.views} 👁️'),
                      Text('${partyPhoto.likers.length + partyPhoto.initLikes} 🖤'),
                      Text('${partyPhoto.downloadCount} 💾'),
                    ],
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      '${DateTimeUtils.getFormattedDate(partyPhoto.endTime)} ',
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