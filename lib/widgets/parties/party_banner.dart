import 'package:bloc/routing/arguments/gl_arguments.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/network_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../helpers/dummy.dart';
import '../../routing/app_routes.dart';
import '../../screens/parties/artist_screen.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/logx.dart';

class PartyBanner extends StatelessWidget {
  static const String _TAG = 'PartyBanner';

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
    bool isGuestListActive =
        party.isGuestListActive & (timeNow < party.guestListEndTime);

    return GestureDetector(
      onTap: () {
        isClickable
            ? Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => ArtistScreen(party: party)),
              )
            : Logx.i(_TAG, 'party banner no click');
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
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Row(
                          children: [
                            Text(
                              party.name.toLowerCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            party.chapter.isNotEmpty? Text(
                              ' (${party.chapter})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.right,
                            ): const SizedBox(),

                          ],
                        ),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.only(
                      //       top: 3, left: 5.0, right: 0.0),
                      //   child: Flexible(
                      //     flex: 1,
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           party.name.toLowerCase(),
                      //           overflow: TextOverflow.ellipsis,
                      //           style: const TextStyle(
                      //             fontSize: 24,
                      //             fontWeight: FontWeight.w800,
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //         party.chapter.isNotEmpty? Text(
                      //           ' (${party.chapter})',
                      //           style: const TextStyle(
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.w400,
                      //           ),
                      //           textAlign: TextAlign.right,
                      //         ): const SizedBox(),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      party.eventName.isNotEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, top: 10),
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
                              : '${DateTimeUtils.getFormattedDate(party.startTime)}, ${DateTimeUtils.getFormattedTime(party.startTime)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          party.genre.isNotEmpty ? '[${party.genre}]' : '',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const Spacer(),
                      shouldShowButton
                          ? !party.isTBA && party.ticketUrl.isNotEmpty
                              ? showBuyTixButton(context)
                              : isGuestListActive
                                  ? displayGuestListButton(context)
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
                      borderRadius: const BorderRadius.all(Radius.circular(0)),
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

  displayGuestListButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.background,
        foregroundColor: Constants.primary,
        shadowColor: Colors.white10,
        elevation: 3,
        minimumSize: const Size.fromHeight(60),
      ),
      onPressed: () {
        PartyGuest partyGuest = Dummy.getDummyPartyGuest();
        partyGuest.partyId = party.id;

        Navigator.pushNamed(
          context,
          AppRoutes.gl,
          arguments: GlArguments(partyGuest: partyGuest, party: party, task: 'add'),
        );
      },
      icon: const Icon(
        Icons.app_registration,
        size: 24.0,
      ),
      label: const Text(
        'guest list',
        style: TextStyle(fontSize: 20, color: Constants.primary),
      ),
    );
  }

  showBuyTixButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.background,
        foregroundColor: Constants.primary,
        shadowColor: Colors.white30,
        elevation: 3,
        minimumSize: const Size.fromHeight(60),
      ),
      onPressed: () {
        final uri = Uri.parse(party.ticketUrl);
        NetworkUtils.launchInBrowser(uri);
      },
      label: const Text(
        'buy ticket',
        style: TextStyle(fontSize: 20, color: Constants.primary),
      ),
      icon: const Icon(
        Icons.star_half,
        size: 24.0,
      ),
    );
  }
}
