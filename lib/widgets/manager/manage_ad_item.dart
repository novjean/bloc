import 'package:flutter/material.dart';

import '../../../db/entity/party_photo.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../db/entity/ad.dart';

class ManageAdItem extends StatelessWidget{
  static const String _TAG = 'ManageAdItem';

  Ad ad;

  ManageAdItem({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double conversion = ad.hits/ad.reach;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: ad.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading:
                  ad.imageUrl.isNotEmpty?
                  FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(ad.imageUrl),
                    fit: BoxFit.cover,) : const SizedBox(),
                  title: RichText(
                    text: TextSpan(
                      text: '${ad.title} ',
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
                      Text('${ad.reach} reach'),
                      Text('${ad.hits} hits'),

                      Text(conversion.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      '${DateTimeUtils.getFormattedDate(ad.createdAt)} ',
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