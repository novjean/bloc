import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/user.dart';
import '../../main.dart';
import '../../utils/constants.dart';

class UserItem extends StatelessWidget {
  final User user;

  const UserItem({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = '${user.name} ${user.surname}'.toLowerCase();

    String appDetails = '';

    if(user.isAppUser){
      if(user.isIos){
        appDetails = '${user.appVersion} 🍏';
      } else {
        appDetails = '${user.appVersion} 🤖';
      }
    } else {
      appDetails = '${user.appVersion} 🌏';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Hero(
        tag: user.id,
        child: Card(
          color: Constants.lightPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            width: mq.width,
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18),
                    ),
                    user.lastSeenAt != 0
                        ? Text(
                            '${DateTimeUtils.getFormattedTime2(user.lastSeenAt)}, ${DateTimeUtils.getFormattedDate4(user.lastSeenAt)}')
                        : const SizedBox(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('bloc day: ${DateTimeUtils.getFormattedDateYear(user.createdAt)}'),
                    // user.isAppUser ? Text(user.appVersion) : const SizedBox(),
                    Text(appDetails)
                  ],
                ),
                user.phoneNumber == 0 ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(user.phoneNumber.toString()),
                    Text('level ${user.challengeLevel}')
                  ],
                ):const SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
