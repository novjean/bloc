import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';

class ManagePartyItem extends StatelessWidget{
  static const String _TAG = 'LoungeItem';

  Party party;

  ManagePartyItem({Key? key, required this.party}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: party.id,
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
                  //   image: NetworkImage(party.imageUrl),
                  //   fit: BoxFit.cover,),
                  title: RichText(
                    text: TextSpan(
                      text: '${party.name} ${party.chapter} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  subtitle: Text('active: ${party.isActive}'),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      '${DateTimeUtils.getFormattedDate(party.startTime)} ',
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