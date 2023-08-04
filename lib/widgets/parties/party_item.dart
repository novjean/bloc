import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/file_utils.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../helpers/dummy.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/constants.dart';
import '../../utils/network_utils.dart';

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
          child: SizedBox(
            width: mq.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: [
                    SizedBox(
                      height: imageHeight,
                      width: mq.width,
                      child: FadeInImage(
                        placeholder: const AssetImage(
                            'assets/icons/logo.png'),
                        image: NetworkImage(party.imageUrl),
                        fit: BoxFit.cover,),
                    ),

                    Positioned(
                      bottom: 5.0,
                      child: Container(
                        width: mq.width,
                        padding:
                            const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: RichText(
                          text: TextSpan(
                              text: '${party.name.toLowerCase()} ',
                              style: TextStyle(
                                fontFamily: Constants.fontDefault,
                                  color: Colors.white,
                                  backgroundColor: Constants.lightPrimary
                                      .withOpacity(0.7),
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                    text: party.chapter == 'I'
                                        ? ''
                                        : party.chapter,
                                    style: const TextStyle(
                                      fontFamily: Constants.fontDefault,
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
                      Flexible(
                        flex: 4,
                        child: party.eventName.isNotEmpty
                            ? RichText(
                          maxLines: 2,
                          text: TextSpan(
                              text: '${party.eventName.toLowerCase()} ',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: Constants.fontDefault,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                    text: party.genre.isNotEmpty
                                        ? '[${party.genre}]'
                                        : ' ',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: Constants.fontDefault,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FontStyle.italic)),
                              ]),
                        )
                            : party.genre.isNotEmpty? Text(
                                '[${party.genre}]',
                                style: const TextStyle(fontSize: 18),
                              ) : const SizedBox(),
                      ),
                      Flexible(
                        flex: 1,
                        child: Text(
                          party.isTBA
                              ? 'tba'
                              : DateTimeUtils.getFormattedDate(party.startTime),
                          style: const TextStyle(fontSize: 18),
                        ),
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
                          child: Text( party.description.toLowerCase(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: const TextStyle(
                                fontSize: 15,
                                color: Constants.darkPrimary),
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
    );
  }

  Widget showJoinGuestListButton(BuildContext context) {
    return SizedBox(
      height: 75,
      width: 75,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        ),
        child: const Text('join\nguest\nlist'),
        onPressed: () {
          // nav to guest list add page
          PartyGuest partyGuest = Dummy.getDummyPartyGuest(true);
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
          backgroundColor: Constants.darkPrimary,
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
