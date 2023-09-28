import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../db/entity/notification_test.dart';

class ManageNotificationTestItem extends StatelessWidget{
  static const String _TAG = 'ManageNotificationTestItem';

  NotificationTest notificationTest;

  ManageNotificationTestItem({Key? key, required this.notificationTest}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: notificationTest.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading:
                  notificationTest.imageUrl.isNotEmpty?
                  FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(notificationTest.imageUrl),
                    fit: BoxFit.cover,) : const SizedBox(),
                  title: RichText(
                    text: TextSpan(
                      text: '${notificationTest.title} ',
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
                      Text('id: ${notificationTest.id}'),

                    ],
                  ),
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