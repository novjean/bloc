
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constants.dart';
import '../db/entity/promoter.dart';

class PromoterItem extends StatefulWidget {
  Promoter promoter;

  PromoterItem({Key? key, required this.promoter })
      : super(key: key);

  @override
  State<PromoterItem> createState() => _PromoterItemState();
}

class _PromoterItemState extends State<PromoterItem> {
  static const String _TAG = 'PromoterItem';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.promoter.id,
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
                      text: '${widget.promoter.name} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  // subtitle: _showLastChat(context),
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
