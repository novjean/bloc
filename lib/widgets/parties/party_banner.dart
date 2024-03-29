import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/main.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/network_utils.dart';
import 'package:bloc/widgets/ui/square_icon_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/history_music.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/party_interest.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../screens/parties/tix_buy_edit_screen.dart';
import '../../utils/logx.dart';
import 'mini_artist_item.dart';

class PartyBanner extends StatefulWidget {

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

  List<Party> mArtists = [];
  var _isArtistsLoading = true;

  PartyInterest mPartyInterest = Dummy.getDummyPartyInterest();

  @override
  void initState() {
    super.initState();

    if (widget.shouldShowInterestCount) {
      mPartyInterest.partyId = widget.party.id;

      FirestoreHelper.pullPartyInterest(widget.party.id).then((res) {
        if (res.docs.isNotEmpty) {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyInterest partyInterest =
              Fresh.freshPartyInterestMap(data, false);
          if (mounted) {
            setState(() {
              mPartyInterest = partyInterest;
            });
          }
        } else {
          // party interest does not exist
        }
      });
    }

    if (widget.party.isBigAct) {
      if (widget.party.artistIds.isNotEmpty) {
        FirestoreHelper.pullPartyArtistsByIds(widget.party.artistIds)
            .then((res) {
          if (res.docs.isNotEmpty) {
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              final Party artist = Fresh.freshPartyMap(data, false);
              if (artist.isBigAct) {
                mArtists.add(artist);
              }
            }

            if (mounted) {
              setState(() {
                _isArtistsLoading = false;
              });
            } else {
              Logx.d(_TAG, 'not mounted');
            }
          } else {
            Logx.em(_TAG, 'artists no longer exist!');
            setState(() {
              _isArtistsLoading = false;
            });
          }
        });
      } else {
        setState(() {
          _isArtistsLoading = false;
        });
      }
    } else {
      setState(() {
        _isArtistsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    bool isGuestListActive = widget.party.isGuestListActive &
        (timeNow < widget.party.guestListEndTime);

    bool showGuestListBuyTix = false;
    if (widget.shouldShowButton) {
      if (!widget.party.isTBA &&
          !widget.party.isTicketsDisabled &&
          (widget.party.isTix || widget.party.ticketUrl.isNotEmpty)) {
        if (isGuestListActive) {
          if (!widget.isGuestListRequested) {
            showGuestListBuyTix = true;
          }
        }
      }
    }

    int interestCount =
        mPartyInterest.initCount + mPartyInterest.userIds.length;

    return GestureDetector(
      onTap: () {
        if (widget.isClickable) {
          if (widget.party.type == 'event') {
            GoRouter.of(context).go('/event/${widget.party.name}/${widget.party.chapter}');
          } else {
            GoRouter.of(context).pushNamed(RouteConstants.artistRouteName,
                pathParameters: {
                  'name': widget.party.name,
                  'genre': widget.party.genre
                });
          }
        } else {
          Logx.i(_TAG, 'party banner no click');
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
              color: Constants.lightPrimary,
              child: SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: RichText(
                              maxLines: 1,
                              text: TextSpan(
                                  text: '${widget.party.name.toLowerCase()} ',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: Constants.fontDefault,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: widget.party.chapter == 'I'
                                            ? ' '
                                            : '${widget.party.chapter} ',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontFamily: Constants.fontDefault,
                                            fontSize: 17,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FontStyle.italic)),
                                  ]),
                            ),
                          ),
                          widget.party.eventName.isNotEmpty
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5.0, top: 5),
                                  child: Text(
                                    widget.party.eventName.toLowerCase(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                )
                              : const SizedBox(),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              widget.party.isTBA
                                  ? 'tba'
                                  : '${DateTimeUtils.getFormattedDate(widget.party.startTime)}, ${DateTimeUtils.getFormattedTime(widget.party.startTime)}',
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                          const Spacer(),
                          mArtists.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, right: 4, bottom: 1),
                                  child: SizedBox(
                                    height: 25, // Adjust the height as needed
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: mArtists.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          child: MiniArtistItem(
                                              artist: mArtists[index]),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : const SizedBox(),
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
                                          interestCount > 0
                                              ? '$interestCount 🖤'
                                              : '10 🖤',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          showGuestListBuyTix && !widget.party.isGuestListFull
                              ? _displayGuestListTicketRow()
                              : widget.shouldShowButton
                                  ? _showBottomButton(
                                      context, isGuestListActive)
                                  : const SizedBox()
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Stack(children: [
                        Container(
                          height: 200,
                          color: Constants.background,
                          child: kIsWeb
                              ? FadeInImage(
                                  placeholder:
                                      const AssetImage('assets/icons/logo.png'),
                                  image: NetworkImage(widget.party.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: widget.party.imageUrl,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      const FadeInImage(
                                    placeholder:
                                        AssetImage('assets/images/logo.png'),
                                    image: AssetImage('assets/images/logo.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
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
          NetworkUtils.launchInAppBrowser(uri);
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
          _handleGuestListPressed();
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

  _showBuyTixButton(BuildContext context) {
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
          _handleBuyTixPressed();
        },
        label: const Text(
          'buy ticket',
          style: TextStyle(fontSize: 20, color: Constants.primary),
        ),
        icon: const Icon(
          Icons.star,
          size: 24.0,
        ),
      ),
    );
  }

  _showExternalBuyTixButton(BuildContext context) {
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
          _handleBuyExternalTixPressed();
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
      ),
    );
  }

  _showBottomButton(BuildContext context, bool isGuestListActive) {
    if (!widget.party.isTBA &&
        !widget.party.isTicketsDisabled &&
        (widget.party.ticketUrl.isNotEmpty || widget.party.isTix)) {
      if(widget.party.isTix){
        return _showBuyTixButton(context);
      } else if(widget.party.ticketUrl.isNotEmpty) {
        return _showExternalBuyTixButton(context);
      } else if (isGuestListActive) {
        if (!widget.isGuestListRequested) {
          if (widget.party.isGuestListFull) {
            return showListenOrInstaDialog(context);
          } else {
            return showGuestListButton(context);
          }
        } else {
          return showBoxOfficeButton(context);
        }
      } else {
        return showListenOrInstaDialog(context);
      }
    } else if (isGuestListActive) {
      if (!widget.isGuestListRequested) {
        if (widget.party.isGuestListFull) {
          return showListenOrInstaDialog(context);
        } else {
          return showGuestListButton(context);
        }
      } else {
        return showBoxOfficeButton(context);
      }
    } else {
      return showListenOrInstaDialog(context);
    }
  }

  void _handleBuyExternalTixPressed() {
    if(widget.party.ticketUrl.isEmpty){
      Logx.ist(_TAG, '📱 tickets are available only through the bloc app');
      return;
    }

    final uri = Uri.parse(widget.party.ticketUrl);
    NetworkUtils.launchInAppBrowser(uri);

    if (UserPreferences.isUserLoggedIn()) {
      User user = UserPreferences.myUser;

      FirestoreHelper.pullHistoryMusic(user.id, widget.party.genre).then((res) {
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
      } else {
        int initCount = mPartyInterest.initCount + 1;
        mPartyInterest = mPartyInterest.copyWith(initCount: initCount);
        FirestoreHelper.pushPartyInterest(mPartyInterest);
      }
    }
  }

  void _handleGuestListPressed() {
    PartyGuest partyGuest = Dummy.getDummyPartyGuest(true);
    partyGuest.partyId = widget.party.id;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PartyGuestAddEditManageScreen(
            partyGuest: partyGuest, party: widget.party, task: 'add'),
      ),
    );
  }

  _displayGuestListTicketRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          flex : 3,
          child : widget.party.isTix
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.background,
              foregroundColor: Constants.primary,
              shadowColor: Colors.white30,
              minimumSize: const Size.fromHeight(60),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              elevation: 3,
            ),
            label: const Text(
              'ticket',
              style: TextStyle(fontSize: 18),
            ),
            icon: const Icon(
              Icons.star,
              size: 24.0,
            ),
            onPressed: () {
              _handleBuyTixPressed();
            },
          ),
        )
            : Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.background,
              foregroundColor: Constants.primary,
              shadowColor: Colors.white30,
              minimumSize: const Size.fromHeight(60),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              elevation: 3,
            ),
            label: const Text(
              'ticket',
              style: TextStyle(fontSize: 18),
            ),
            icon: const Icon(
              Icons.star_half,
              size: 24.0,
            ),
            onPressed: () {
              _handleBuyExternalTixPressed();
            },
          ),
        ),),

        Flexible(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            height: 60,
            child: SquareIconButton(
              icon : Icons.app_registration,
              onPressed: () {
              _handleGuestListPressed();
            },)
          ),
        ),
      ],
    );
  }

  void _handleBuyTixPressed() {
    if(kIsWeb){
      if(widget.party.isTix) {
        Tix tix = Dummy.getDummyTix();
        tix = tix.copyWith(partyId: widget.party.id);

        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => TixBuyEditScreen(
                  tix: tix, task: 'buy')),
        );
      } else if(widget.party.ticketUrl.isNotEmpty) {
          final uri = Uri.parse(widget.party.ticketUrl);
          NetworkUtils.launchInAppBrowser(uri);
      } else {
        Logx.ist(_TAG, 'no tickets are available at the moment!');
      }
    } else{
      //navigate to purchase tix screen
      Tix tix = Dummy.getDummyTix();
      tix = tix.copyWith(partyId: widget.party.id);

      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => TixBuyEditScreen(
                tix: tix, task: 'buy')),
      );
    }

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
          if (res.docs.length > 1) {
            // that means there are multiple, so consolidate
            HistoryMusic hm = Dummy.getDummyHistoryMusic();
            int totalCount = 0;

            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              final HistoryMusic historyMusic =
              Fresh.freshHistoryMusicMap(data, false);

              totalCount += historyMusic.count;
              if (i == 0) {
                hm = historyMusic;
              }
              FirestoreHelper.deleteHistoryMusic(historyMusic.id);
            }

            totalCount = totalCount + 1;
            hm = hm.copyWith(count: totalCount);
            FirestoreHelper.pushHistoryMusic(hm);
          } else {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> data =
            document.data()! as Map<String, dynamic>;
            HistoryMusic historyMusic =
            Fresh.freshHistoryMusicMap(data, false);
            int newCount = historyMusic.count + 1;

            historyMusic = historyMusic.copyWith(count: newCount);
            FirestoreHelper.pushHistoryMusic(historyMusic);
          }
        }
      });
    }
  }
}
