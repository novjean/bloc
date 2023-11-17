import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../db/entity/friend.dart';

class ManageFriendItem extends StatelessWidget{
  static const String _TAG = 'ManageFriendItem';

  Friend friend;

  ManageFriendItem({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // double conversion = friend.hits/friend.reach;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: friend.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  // leading:
                  // friend.imageUrl.isNotEmpty?
                  // FadeInImage(
                  //   placeholder: const AssetImage(
                  //       'assets/icons/logo.png'),
                  //   image: NetworkImage(friend.imageUrl),
                  //   fit: BoxFit.cover,) : const SizedBox(),
                  title: RichText(
                    text: TextSpan(
                      text: '${friend.userId} : ${friend.friendUserId}',
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
                      Text('following : ${friend.isFollowing}'),
                    ],
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      '${DateTimeUtils.getFormattedDate(friend.friendshipDate)} ',
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