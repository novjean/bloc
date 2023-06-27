import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/network_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/history_music.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../screens/box_office/box_office_screen.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/logx.dart';

class PartyBanner extends StatelessWidget {
  static const String _TAG = 'PartyBanner';

  Party party;
  final bool isClickable;
  final bool shouldShowButton;
  final bool isGuestListRequested;

  PartyBanner(
      {Key? key,
      required this.party,
      required this.isClickable,
      required this.shouldShowButton,
      required this.isGuestListRequested})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    bool isGuestListActive =
        party.isGuestListActive & (timeNow < party.guestListEndTime);

    return GestureDetector(
      onTap: () {
        if (isClickable) {
          if (party.type == 'event') {
            GoRouter.of(context).pushNamed(RouteConstants.eventRouteName,
                params: {
                  'partyName': party.name,
                  'partyChapter': party.chapter
                });
          } else {
            GoRouter.of(context).pushNamed(RouteConstants.artistRouteName,
                params: {'name': party.name, 'genre': party.genre});
          }
        } else {
          Logx.i(_TAG, 'party banner no click');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(children: [
            Hero(
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
                              child: RichText(
                                text: TextSpan(
                                    text: '${party.name.toLowerCase()} ',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: Constants.fontDefault,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: party.chapter == 'I'
                                              ? ''
                                              : party.chapter,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: Constants.fontDefault,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                              fontStyle: FontStyle.italic)),
                                    ]),
                              ),
                            ),
                            party.eventName.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, top: 10),
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
                            const Spacer(),
                            shouldShowButton
                                ? !party.isTBA && party.ticketUrl.isNotEmpty
                                    ? showBuyTixButton(context)
                                    : isGuestListActive
                                        ? !isGuestListRequested
                                            ? showGuestListButton(context)
                                            : showBoxOfficeButton(context)
                                        : showListenOrInstaDialog(context)
                                : const SizedBox()
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 200,
                          child: FadeInImage(
                            placeholder: const AssetImage(
                                'assets/icons/logo.png'),
                            image: NetworkImage(party.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            party.genre.isNotEmpty
                ? Positioned(
                    bottom: 5,
                    right: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                        child: Text(
                          party.genre,
                          style: TextStyle(
                              fontSize: 14,
                              backgroundColor: Constants.lightPrimary.withOpacity(0.5),

                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox()
          ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.background,
          foregroundColor: Constants.primary,
          shadowColor: Colors.white10,
          elevation: 3,
          minimumSize: const Size.fromHeight(60),
        ),
        onPressed: () {
          final uri =
              Uri.parse(isListen ? party.listenUrl : party.instagramUrl);
          NetworkUtils.launchInBrowser(uri);
        },
        icon: Icon(
          isListen ? Icons.music_note_outlined : Icons.join_right,
          size: 24.0,
        ),
        label: Text(
          isListen ? 'listen' : 'social',
          style: const TextStyle(fontSize: 20, color: Constants.primary),
        ),
      ),
    );
  }

  showGuestListButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton.icon(
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

          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => PartyGuestAddEditManageScreen(
                    partyGuest: partyGuest, party: party, task: 'add')),
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
      ),
    );
  }

  showBuyTixButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton.icon(
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

          if (UserPreferences.isUserLoggedIn()) {
            User user = UserPreferences.myUser;

            FirestoreHelper.pullHistoryMusic(user.id, party.genre).then((res) {
              if (res.docs.isEmpty) {
                // no history, add new one
                HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
                historyMusic.userId = user.id;
                historyMusic.genre = party.genre;
                historyMusic.count = 1;
                FirestoreHelper.pushHistoryMusic(historyMusic);
              } else {
                for (int i = 0; i < res.docs.length; i++) {
                  DocumentSnapshot document = res.docs[i];
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  final HistoryMusic historyMusic =
                      Fresh.freshHistoryMusicMap(data, false);
                  historyMusic.count++;
                  FirestoreHelper.pushHistoryMusic(historyMusic);
                }
              }
            });
          }
        },
        label: const Text(
          'buy ticket',
          style: TextStyle(fontSize: 20, color: Constants.primary),
        ),
        icon: const Icon(
          Icons.star_half,
          size: 24.0,
        ),
      ),
    );
  }

  showBoxOfficeButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.background,
        foregroundColor: Constants.primary,
        shadowColor: Colors.white30,
        elevation: 3,
        minimumSize: const Size.fromHeight(60),
      ),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => BoxOfficeScreen()));
      },
      label: const Text(
        'box office',
        style: TextStyle(fontSize: 20, color: Constants.primary),
      ),
      icon: const Icon(
        Icons.keyboard_command_key_sharp,
        size: 24.0,
      ),
    );
  }
}
