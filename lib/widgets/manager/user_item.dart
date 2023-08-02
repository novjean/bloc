import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/user.dart';

class UserItem extends StatelessWidget {
  final User user;

  const UserItem({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Hero(
        tag: user.id,
        child: Card(
          color: Theme.of(context).primaryColorLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ('${user.name} ${user.surname}').toLowerCase(),
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
