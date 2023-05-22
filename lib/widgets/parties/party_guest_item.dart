import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party_guest.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/logx.dart';

class PartyGuestItem extends StatelessWidget {
  static const String _TAG = 'PartyGuestItem';

  final PartyGuest partyGuest;
  final String partyName;

  const PartyGuestItem({Key? key, required this.partyGuest, required this.partyName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = '${partyGuest.name.toLowerCase()} ${partyGuest.surname.toLowerCase()}';
    int friendsCount = partyGuest.guestsCount - 1;

    if (friendsCount > 0) {
      title += ' +$friendsCount';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Hero(
        tag: partyGuest.id,
        child: Card(
          color: Theme.of(context).primaryColorLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18),
                      ),
                      partyGuest.shouldBanUser?
                      SizedBox.fromSize(
                        size: const Size(25, 25),
                        child: ClipOval(
                          child: Material(
                            color: Colors.redAccent,
                            child: InkWell(
                              splashColor: Colors.red,
                              onTap: () {
                                // here we should write the ban user
                                

                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const <Widget>[
                                  Icon(Icons.dangerous),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ): const SizedBox(),
                      Text(' ${DateTimeUtils.getFormattedDateString(
                          partyGuest.createdAt)}'),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        partyName,
                      ),
                    ),
                ],),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5, top: 5),
                      child: Text(
                        'status : ${partyGuest.guestStatus}',
                      ),
                    ),
                  ],),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 5, bottom: 5),
                      child: Row(
                        children: [
                          Text('supported : ${partyGuest.isChallengeClicked}'),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 5, bottom: 5),
                      child: Row(
                        children: [
                          const Text('approved: '),
                          Checkbox(
                            value: partyGuest.isApproved,
                            onChanged: (value) {
                              PartyGuest updatedPartyGuest =
                                  partyGuest.copyWith(isApproved: value);
                              Logx.i(_TAG, 'party guest ${updatedPartyGuest.name} approved $value');
                              PartyGuest freshPartyGuest =
                                  Fresh.freshPartyGuest(updatedPartyGuest);
                              FirestoreHelper.pushPartyGuest(freshPartyGuest);
                            },
                          ),
                        ],
                      ),
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
