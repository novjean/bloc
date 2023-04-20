import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/network_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../helpers/dummy.dart';
import '../../screens/parties/artist_screen.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';

class PartyBanner extends StatelessWidget {
  final Party party;
  final bool isClickable;
  final bool shouldShowButton;

  const PartyBanner(
      {Key? key,
      required this.party,
      required this.isClickable,
      required this.shouldShowButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    bool isGuestListActive = party.isGuestListActive & (timeNow < party.guestListEndTime);

    return GestureDetector(
      onTap: () {
        isClickable
            ? Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => ArtistScreen(party: party)),
              )
            : print('party banner no click');
      },
      child: Hero(
        tag: party.id,
        child: Card(
          elevation: 1,
          color: Theme.of(context).primaryColorLight,
          child: SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 3, left: 5.0, right: 0.0),
                        child: Text(
                          party.name.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      party.eventName.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 10),
                              child: Text(
                                party.eventName.toLowerCase(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          party.isTBA
                              ? 'tba'
                              : DateTimeUtils.getFormattedDate(party.startTime),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          party.isTBA
                              ? ''
                              : DateTimeUtils.getFormattedTime(party.startTime),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),

                      const Spacer(),

                      shouldShowButton
                          ? party.isTBA
                              ? showListenOrInstaDialog(context)
                              : isGuestListActive
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(right: 0.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).highlightColor,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.white30,
                                          elevation: 3,

                                          minimumSize: const Size.fromHeight(
                                              60),
                                        ),
                                        onPressed: () {
                                          PartyGuest partyGuest = Dummy.getDummyPartyGuest();
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
                                        child: Text(
                                          'join guest list',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                      ),
                                    )
                                  : showListenOrInstaDialog(context)
                          : const SizedBox()
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      image: DecorationImage(
                        image: NetworkImage(party.imageUrl),
                        fit: BoxFit.fitHeight,
                        // AssetImage(food['image']),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showListenOrInstaDialog(BuildContext context) {
    bool isListen = party.listenUrl.isNotEmpty;
    bool isInsta = party.instagramUrl.isNotEmpty;

    if (!isListen && !isInsta) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).highlightColor,
          foregroundColor: Colors.white,
          shadowColor: Colors.white30,
          elevation: 3,
          minimumSize: const Size.fromHeight(60),
        ),
        onPressed: () {
          final uri =
              Uri.parse(isListen ? party.listenUrl : party.instagramUrl);
          NetworkUtils.launchInBrowser(uri);
        },
        child: Text(
          isListen ? 'listen' : 'social',
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }

  Widget displayButton(BuildContext context, bool isGuestListActive) {
    if(isGuestListActive){
      return Padding(
        padding:
        const EdgeInsets.only(right: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
            Theme.of(context).highlightColor,
            foregroundColor: Colors.white,
            shadowColor: Colors.white30,
            elevation: 3,

            minimumSize: const Size.fromHeight(
                60), //////// HERE
          ),
          onPressed: () {
            PartyGuest partyGuest = Dummy.getDummyPartyGuest();
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
          child: Text(
            'join guest list',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black),
          ),
        ),
      );
    } else {
      return showListenOrInstaDialog(context);
    }
  }
}
