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
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0, top: 5),
                      child: Text(
                        (user.name + user.surname).toLowerCase(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    user.lastSeenAt != 0
                        ? Padding(
                            padding: const EdgeInsets.only(right: 5.0, top: 5),
                            child: Text(
                                'last seen: ${DateTimeUtils.getFormattedDateYear(user.lastSeenAt)}'),
                          )
                        : const SizedBox(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 5.0, right: 5.0, top: 5),
                      child: Text('bloc day: ${DateTimeUtils.getFormattedDateYear(user.createdAt)}'),
                    ),
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
