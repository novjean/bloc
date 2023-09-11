import 'package:bloc/utils/date_time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party_guest.dart';
import '../../db/entity/user.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class ManageGuestListItem extends StatelessWidget {
  static const String _TAG = 'ManageGuestListItem';

  final PartyGuest partyGuest;
  final String partyName;

  const ManageGuestListItem(
      {Key? key, required this.partyGuest, required this.partyName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title =
        '${partyGuest.name.toLowerCase()} ${partyGuest.surname.toLowerCase()}';
    int friendsCount = partyGuest.guestsCount - 1;

    if (friendsCount > 0) {
      title += ' +$friendsCount';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Hero(
        tag: partyGuest.id,
        child: Card(
          color: Constants.lightPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
            width: mq.width,
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
                    partyGuest.shouldBanUser
                        ? showBannedIcon(context)
                        : const SizedBox(),
                    Text(
                        ' ${DateTimeUtils.getFormattedDateString(partyGuest.createdAt)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'status : ${partyGuest.guestStatus}',
                    ),
                    Text('$partyName', style: const TextStyle(fontWeight: FontWeight.bold),)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('supported : ${partyGuest.isChallengeClicked}'),
                    const Spacer(),
                    Text(partyGuest.isApproved?'✅': '⭕'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showBannedIcon(BuildContext context) {
    SizedBox.fromSize(
      size: const Size(25, 25),
      child: ClipOval(
        child: Material(
          color: Colors.redAccent,
          child: InkWell(
            splashColor: Colors.red,
            onTap: () {
              // here we should write the ban user
              FirestoreHelper.pullUser(partyGuest.guestId).then((res) {
                Logx.i(_TAG,
                    'successfully pulled in user for id ${partyGuest.guestId}');

                if (res.docs.isNotEmpty) {
                  DocumentSnapshot document = res.docs[0];
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  final User user = Fresh.freshUserMap(data, false);
                  user.isBanned = true;
                  FirestoreHelper.pushUser(user);

                  Logx.ist(_TAG, '${user.name} ${user.surname} is banned');
                }
              });
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.dangerous),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
