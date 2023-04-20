import 'package:bloc/utils/date_time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../screens/parties/artist_screen.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/string_utils.dart';

class PartyItem extends StatelessWidget {
  final Party party;
  final double imageHeight;
  final bool isGuestListRequested;

  const PartyItem(
      {Key? key,
      required this.party,
      required this.imageHeight,
      required this.isGuestListRequested})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    bool isGuestListActive =
        party.isGuestListActive & (timeNow < party.guestListEndTime);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => ArtistScreen(party: party)),
        );
      },
      child: Hero(
        tag: party.id,
        child: Card(
          elevation: 10,
          color: Theme.of(context).primaryColorLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: [
                      Container(
                        height: imageHeight,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                            image: NetworkImage(party.imageUrl),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  party.name.toLowerCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ]),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        party.eventName.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    party.eventName.toLowerCase(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        Text(
                          party.isTBA
                              ? 'tba'
                              : DateTimeUtils.getFormattedDate(party.startTime),
                          style: const TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              StringUtils.truncateWithEllipsis(
                                  120, party.description.toLowerCase()),
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).primaryColorDark),
                            ),
                          ),
                        ),
                        isGuestListActive &
                                !isGuestListRequested
                            ? Flexible(
                                flex: 1,
                                child: Container(
                                  height: 75,
                                  width: 75,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColorDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 1, vertical: 1),
                                    ),
                                    child: const Text('join\nguest\nlist'),
                                    onPressed: () {
                                      // nav to guest list add page
                                      PartyGuest partyGuest =
                                          Dummy.getDummyPartyGuest();
                                      partyGuest.partyId = party.id;

                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PartyGuestAddEditManagePage(
                                                    partyGuest: partyGuest,
                                                    party: party,
                                                    task: 'add')),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
