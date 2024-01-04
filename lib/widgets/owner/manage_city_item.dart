import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../db/entity/city.dart';

class ManageCityItem extends StatelessWidget{
  static const String _TAG = 'ManageCityItem';

  City city;

  ManageCityItem({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: city.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading:
                  city.imageUrl.isNotEmpty?
                  FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(city.imageUrl),
                    fit: BoxFit.cover,) : const SizedBox(),
                  title: RichText(
                    text: TextSpan(
                      text: city.name.toLowerCase(),
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  // subtitle: Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('${city.reach} reach'),
                  //     Text('${ad.hits} hits'),
                  //
                  //     Text(conversion.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold),),
                  //   ],
                  // ),
                  // trailing: RichText(
                  //   text: TextSpan(
                  //     text:
                  //     '${DateTimeUtils.getFormattedDate(ad.createdAt)} ',
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