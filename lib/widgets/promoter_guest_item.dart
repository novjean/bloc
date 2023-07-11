
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constants.dart';
import '../db/entity/promoter_guest.dart';

class PromoterGuestItem extends StatefulWidget {
  PromoterGuest promoterGuest;

  PromoterGuestItem({Key? key, required this.promoterGuest })
      : super(key: key);

  @override
  State<PromoterGuestItem> createState() => _PromoterGuestItemState();
}

class _PromoterGuestItemState extends State<PromoterGuestItem> {
  static const String _TAG = 'PromoterGuestItem';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.promoterGuest.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  // leading: FadeInImage(
                  //   placeholder: const AssetImage(
                  //       'assets/icons/logo.png'),
                  //   image: NetworkImage(widget..imageUrl),
                  //   fit: BoxFit.cover,),
                  title: RichText(
                    text: TextSpan(
                      text: '${widget.promoterGuest.name} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  subtitle: Text('phone: ${widget.promoterGuest.phone}'),

                  // trailing: RichText(
                  //   text: TextSpan(
                  //     text:
                  //     '${DateTimeUtils.getChatDate(lounge.lastChatTime)} ',
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
