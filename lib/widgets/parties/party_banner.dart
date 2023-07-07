import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/network_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/history_music.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/party_interest.dart';
import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/logx.dart';

class PartyBanner extends StatefulWidget {
  static const String _TAG = 'PartyBanner';

  Party party;
  final bool isClickable;
  final bool shouldShowButton;
  final bool isGuestListRequested;
  final bool shouldShowInterestCount;

  PartyBanner(
      {Key? key,
      required this.party,
      required this.isClickable,
      required this.shouldShowButton,
      required this.isGuestListRequested,
      required this.shouldShowInterestCount})
      : super(key: key);

  @override
  State<PartyBanner> createState() => _PartyBannerState();
}

class _PartyBannerState extends State<PartyBanner> {
  static const String _TAG = 'PartyBanner';

  PartyInterest mPartyInterest = Dummy.getDummyPartyInterest();

  @override
  void initState() {
    if (widget.shouldShowInterestCount) {
      mPartyInterest.partyId = widget.party.id;

      FirestoreHelper.pullPartyInterest(widget.party.id).then((res) {
        if (res.docs.isNotEmpty) {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyInterest partyInterest =
              Fresh.freshPartyInterestMap(data, false);
          setState(() {
            mPartyInterest = partyInterest;
          });
        } else {
          // party interest does not exist
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    bool isGuestListActive = widget.party.isGuestListActive &
        (timeNow < widget.party.guestListEndTime);

    int interestCount = mPartyInterest.initCount + mPartyInterest.userIds.length;

    return GestureDetector(
      onTap: () {
        if (widget.isClickable) {
          if (widget.party.type == 'event') {
            GoRouter.of(context).pushNamed(RouteConstants.eventRouteName,
                params: {
                  'partyName': widget.party.name,
                  'partyChapter': widget.party.chapter
                });
          } else {
            GoRouter.of(context).pushNamed(RouteConstants.artistRouteName,
                params: {
                  'name': widget.party.name,
                  'genre': widget.party.genre
                });
          }
        } else {
          Logx.i(PartyBanner._TAG, 'party banner no click');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Hero(
            tag: widget.party.id,
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
                                  text: '${widget.party.name.toLowerCase()} ',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: Constants.fontDefault,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: widget.party.chapter == 'I'
                                            ? ''
                                            : widget.party.chapter,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontFamily: Constants.fontDefault,
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FontStyle.italic)),
                                  ]),
                            ),
                          ),
                          widget.party.eventName.isNotEmpty
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5.0, top: 10),
                                  child: Text(
                                    widget.party.eventName.toLowerCase(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                )
                              : const SizedBox(),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              widget.party.isTBA
                                  ? 'tba'
                                  : '${DateTimeUtils.getFormattedDate(widget.party.startTime)}, ${DateTimeUtils.getFormattedTime(widget.party.startTime)}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const Spacer(),
                          widget.shouldShowInterestCount
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 5, bottom: 1),
                                      child: DelayedDisplay(
                                        delay: const Duration(seconds: 1),
                                        child: Text(
                                          interestCount >= 9 ||
                                                  UserPreferences.myUser
                                                          .clearanceLevel >=
                                                      Constants.ADMIN_LEVEL
                                              ? '$interestCount 🖤'
                                              : '',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          widget.shouldShowButton
                              ? !widget.party.isTBA &&
                                      widget.party.ticketUrl.isNotEmpty
                                  ? showBuyTixButton(context)
                                  : isGuestListActive
                                      ? !widget.isGuestListRequested
                                          ? showGuestListButton(context)
                                          : showBoxOfficeButton(context)
                                      : showListenOrInstaDialog(context)
                              : const SizedBox()
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Stack(children: [
                        SizedBox(
                          height: 200,
                          child: FadeInImage(
                            placeholder:
                                const AssetImage('assets/icons/logo.png'),
                            image: NetworkImage(widget.party.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        widget.party.genre.isNotEmpty
                            ? Positioned(
                                bottom: 3,
                                right: 3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 2),
                                    child: Text(
                                      widget.party.genre,
                                      style: TextStyle(
                                        fontSize: 14,
                                        backgroundColor: Constants.lightPrimary
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox()
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  showListenOrInstaDialog(BuildContext context) {
    bool isListen = widget.party.listenUrl.isNotEmpty;
    bool isInsta = widget.party.instagramUrl.isNotEmpty;

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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
        ),
        onPressed: () {
          final uri = Uri.parse(
              isListen ? widget.party.listenUrl : widget.party.instagramUrl);
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
        ),
        onPressed: () {
          PartyGuest partyGuest = Dummy.getDummyPartyGuest(true);
          partyGuest.partyId = widget.party.id;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PartyGuestAddEditManageScreen(
                  partyGuest: partyGuest, party: widget.party, task: 'add'),
            ),
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
        ),
        onPressed: () {
          final uri = Uri.parse(widget.party.ticketUrl);
          NetworkUtils.launchInBrowser(uri);

          if (UserPreferences.isUserLoggedIn()) {
            User user = UserPreferences.myUser;

            FirestoreHelper.pullHistoryMusic(user.id, widget.party.genre)
                .then((res) {
              if (res.docs.isEmpty) {
                // no history, add new one
                HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
                historyMusic.userId = user.id;
                historyMusic.genre = widget.party.genre;
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

            if (UserPreferences.isUserLoggedIn()) {
              if (!mPartyInterest.userIds.contains(UserPreferences.myUser.id)) {
                mPartyInterest.userIds.add(UserPreferences.myUser.id);
                FirestoreHelper.pushPartyInterest(mPartyInterest);

                Logx.d(_TAG, 'user added to party interest');
              }
            }
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
        GoRouter.of(context).pushNamed(RouteConstants.boxOfficeRouteName);
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
