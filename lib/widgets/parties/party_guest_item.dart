import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party_guest.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';

class PartyGuestItem extends StatelessWidget {
  final PartyGuest partyGuest;
  final String partyName;

  const PartyGuestItem({Key? key, required this.partyGuest, required this.partyName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = partyGuest.name.toLowerCase() + ' ' + partyGuest.surname.toLowerCase();
    int friendsCount = partyGuest.guestsCount - 1;

    if (friendsCount > 0) {
      title += ' +' + friendsCount.toString();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 5),
                      child: Text('requested at: ' +
                          DateTimeUtils.getFormattedDateYear(
                              partyGuest.createdAt)),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                      child: Row(
                        children: [
                          Text('approved: '),
                          Checkbox(
                            value: partyGuest.isApproved,
                            onChanged: (value) {
                              PartyGuest updatedPartyGuest =
                                  partyGuest.copyWith(isApproved: value);
                              print('party guest ' +
                                  updatedPartyGuest.name +
                                  ' approved ' +
                                  value.toString());
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
