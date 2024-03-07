import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../db/entity/advert.dart';

class ManageAdvertItem extends StatelessWidget {
  static const String _TAG = 'ManageAdvertItem';

  Advert advert;

  ManageAdvertItem({Key? key, required this.advert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: advert.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading: advert.imageUrls.isNotEmpty
                      ? FadeInImage(
                          placeholder:
                              const AssetImage('assets/icons/logo.png'),
                          image: NetworkImage(advert.imageUrls[0]),
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(),
                  title: RichText(
                    text: TextSpan(
                      text: '${advert.title} ',
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
                      Text('${advert.views} views'),
                      Text('${advert.clickCount} clicks'),
                      // Text(conversion.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                          '${DateTimeUtils.getFormattedDate(advert.createdAt)} ',
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
