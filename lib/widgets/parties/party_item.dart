import 'package:bloc/utils/date_time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../helpers/dummy.dart';
import '../../routes/route_constants.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/network_utils.dart';
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
        if (party.type == 'event') {
          GoRouter.of(context).pushNamed(RouteConstants.eventRouteName,
              params: {
                'partyName': party.name,
                'partyChapter': party.chapter
              });
        } else {
          GoRouter.of(context).pushNamed(RouteConstants.artistRouteName,
              params: {
                'name': party.name,
                'genre': party.genre
              });
        }
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
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: RichText(
                            text: TextSpan(
                                text: '${party.name.toLowerCase()} ',
                                style: const TextStyle(
                                  fontFamily: 'Oswald',
                                    color: Colors.white,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: party.chapter == 'I'
                                          ? ''
                                          : party.chapter,
                                      style: const TextStyle(
                                        fontFamily: 'Oswald',
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.italic)),
                                ]),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        party.eventName.isNotEmpty
                            ? Text(
                                '${party.eventName.toLowerCase()} [${party.genre}]',
                                style: const TextStyle(fontSize: 18),
                              )
                            : Text(
                                '[${party.genre}]',
                                style: const TextStyle(fontSize: 18),
                              ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5.0),
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
                        party.ticketUrl.isNotEmpty
                            ? Flexible(
                                flex: 1, child: showBuyTicketNowButton(context))
                            : (isGuestListActive & !isGuestListRequested)
                                ? Flexible(
                                    flex: 1,
                                    child: showJoinGuestListButton(context))
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

  Widget showJoinGuestListButton(BuildContext context) {
    return SizedBox(
      height: 75,
      width: 75,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColorDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        ),
        child: const Text('join\nguest\nlist'),
        onPressed: () {
          // nav to guest list add page
          PartyGuest partyGuest = Dummy.getDummyPartyGuest();
          partyGuest.partyId = party.id;

          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => PartyGuestAddEditManageScreen(
                    partyGuest: partyGuest, party: party, task: 'add')),
          );
        },
      ),
    );
  }

  Widget showBuyTicketNowButton(BuildContext context) {
    return SizedBox(
      height: 75,
      width: 75,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColorDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        ),
        child: const Text('buy\nticket\nnow'),
        onPressed: () {
          final uri = Uri.parse(party.ticketUrl);
          NetworkUtils.launchInBrowser(uri);
        },
      ),
    );
  }
}
