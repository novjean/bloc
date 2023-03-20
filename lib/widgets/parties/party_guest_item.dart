import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party_guest.dart';

class PartyGuestItem extends StatelessWidget {
  final PartyGuest partyGuest;

  const PartyGuestItem({Key? key, required this.partyGuest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.only(left : 5.0, top: 5),
                      child: Text(
                        partyGuest.name.toLowerCase(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    // partyGuest.lastSeenAt != 0
                    //     ? Padding(
                    //   padding: const EdgeInsets.only(right : 5.0, top: 5),
                    //   child: Text('last seen: ' +
                    //       DateTimeUtils.getFormattedDateYear(
                    //           partyGuest.lastSeenAt)),
                    // )
                    //     : const SizedBox(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left : 5.0, right: 5.0, top: 5),
                      child: Text('requested at: ' +
                          DateTimeUtils.getFormattedDateYear(partyGuest.createdAt)),
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
