import 'package:flutter/material.dart';

import '../../../db/entity/party_photo.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';

class ManagePartyPhotoItem extends StatefulWidget{
  static const String _TAG = 'ManagePartyPhotoItem';

  PartyPhoto partyPhoto;
  final ValueChanged<bool>? onChanged;

  ManagePartyPhotoItem({Key? key, required this.partyPhoto, required this.onChanged,}) : super(key: key);

  @override
  State<ManagePartyPhotoItem> createState() => _ManagePartyPhotoItemState();
}

class _ManagePartyPhotoItemState extends State<ManagePartyPhotoItem> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.partyPhoto.id,
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
                    image: NetworkImage(widget.partyPhoto.imageThumbUrl.isNotEmpty? widget.partyPhoto.imageThumbUrl: widget.partyPhoto.imageUrl),
                    fit: BoxFit.cover,),
                  title: RichText(
                    text: TextSpan(
                      text: '${widget.partyPhoto.partyName} ',
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
                      Text('${widget.partyPhoto.views} 👁️'),
                      Text('${widget.partyPhoto.likers.length + widget.partyPhoto.initLikes} 🖤'),
                      Text('${widget.partyPhoto.downloadCount} 💾'),
                    ],
                  ),
                  trailing: Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                      });

                      // Trigger the callback with the new value
                      widget.onChanged?.call(value!);
                    },
                  )

                  // RichText(
                  //   text: TextSpan(
                  //     text:
                  //     '${DateTimeUtils.getFormattedDate(partyPhoto.endTime)} ',
                  //     style: const TextStyle(
                  //       fontFamily: Constants.fontDefault,
                  //       color: Colors.black,
                  //       fontStyle: FontStyle.italic,
                  //       fontSize: 13,
                  //     ),
                  //   ),
                  // ),
                )),
          ),
        ),
      ),
    );
  }
}