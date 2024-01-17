import 'package:barcode_widget/barcode_widget.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../db/entity/challenge.dart';
import '../../db/entity/challenge_action.dart';
import '../../db/entity/history_music.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_interest.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../screens/parties/tix_buy_edit_screen.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../utils/string_utils.dart';

class BoxOfficeGuestListItem extends StatefulWidget {
  PartyGuest partyGuest;
  final Party party;
  final bool isClickable;
  final List<Challenge> challenges;

  BoxOfficeGuestListItem(
      {Key? key,
      required this.partyGuest,
      required this.isClickable,
      required this.party,
      required this.challenges})
      : super(key: key);

  @override
  State<BoxOfficeGuestListItem> createState() => _BoxOfficeGuestListItemState();
}

class _BoxOfficeGuestListItemState extends State<BoxOfficeGuestListItem> {
  static const String _TAG = 'BoxOfficeItem';

  PartyInterest mPartyInterest = Dummy.getDummyPartyInterest();

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    String title = widget.partyGuest.name.toLowerCase();
    int friendsCount = widget.partyGuest.guestsCount - 1;

    if (friendsCount > 0) {
      title += ' +$friendsCount';
    }

    return Hero(
      tag: widget.partyGuest.id,
      child: Card(
        elevation: 1,
        color: Constants.lightPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          width: MediaQuery.of(context).size.width,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: FadeInImage(
                      placeholder: const AssetImage('assets/icons/logo.png'),
                      image: NetworkImage(widget.party.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.party.isTBA
                        ? 'to be announced'
                        : DateTimeUtils.getFormattedDate(
                            widget.party.startTime),
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${widget.party.name} ${widget.party.chapter}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.party.isTBA
                        ? ' '
                        : '${DateTimeUtils.getFormattedTime(widget.party.startTime)} onwards',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'reach by: ${DateTimeUtils.getFormattedTime(widget.party.guestListEndTime)}',
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ((widget.party.ticketUrl.isNotEmpty || widget.party.isTix)&&
                          !widget.party.isTicketsDisabled)
                      ? _showBuyTicketButton(context)
                      : _showDisabledBuyTicketButton(context),
                  widget.partyGuest.isApproved
                      ? _showApprovedButton(context)
                      : widget.party.isGuestListFull
                          ? _showGuestListFullButton(context)
                          : _showPendingButton(context),
                  widget.partyGuest.isApproved
                      ? _showGuestListEntryButton(context)
                      : widget.party.isGuestListFull
                          ? const SizedBox()
                          : _showEditGuestListButton(context)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showTicketEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    '${widget.party.eventName} | ${widget.party.name}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Center(
                    child: BarcodeWidget(
                  color: Constants.darkPrimary,
                  barcode: Barcode.qrCode(),
                  // Barcode type and settings
                  data: widget.partyGuest.id,
                  // Content
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                )),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${widget.partyGuest.guestStatus} entry. ${widget.partyGuest.guestsRemaining} guests remaining',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'valid until ${DateTimeUtils.getFormattedTime(widget.party.guestListEndTime)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showApprovedButton(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.lightPrimary,
          foregroundColor: Constants.primary,
          shadowColor: Colors.white30,
          minimumSize: const Size.fromHeight(60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          elevation: 3,
        ),
        label: const Text(
          'approved',
          style: TextStyle(fontSize: 14, color: Constants.darkPrimary),
        ),
        icon: const Icon(
          Icons.thumb_up_off_alt_sharp,
          size: 24.0,
          color: Constants.darkPrimary,
        ),
        onPressed: () {
          Logx.ist(_TAG,
              'congratulations, your guest list request has been approved. see you soon!');
        },
      ),
    ));
  }

  _showGuestListFullButton(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.lightPrimary,
          foregroundColor: Constants.primary,
          shadowColor: Colors.white30,
          minimumSize: const Size.fromHeight(60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          elevation: 3,
        ),
        label: const Text(
          '🚧 guest list is full',
          style: TextStyle(fontSize: 14, color: Constants.darkPrimary),
        ),
        icon: const Icon(
          Icons.stop_circle,
          size: 24.0,
          color: Constants.darkPrimary,
        ),
        onPressed: () {
          _showGuestListFullDialog(context);
        },
      ),
    ));
  }

  void _showGuestListFullDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              'limited guest list is full',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  widget.party.ticketUrl.isNotEmpty &&
                          !widget.party.isTicketsDisabled
                      ? Text(
                          'due to an incredible turnout, our event guest list is completely booked. to be part of this exciting event, we kindly suggest purchasing a ticket as your only option. thank you for your interest!'
                              .toLowerCase())
                      : Text(
                          'due to an incredible turnout, our event guest list is completely booked. to be part of this exciting event, we kindly suggest purchasing a ticket at the gate as your only option. thank you for understanding!'
                              .toLowerCase()),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              ((widget.party.ticketUrl.isNotEmpty || widget.party.isTix) &&
                      !widget.party.isTicketsDisabled)
                  ? TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Constants.darkPrimary),
                      ),
                      child: const Text('🎟️ buy ticket',
                          style: TextStyle(color: Constants.primary)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        if(widget.party.isTix){
                          _handleBuyTixPressed();
                        } else {
                          _handleBuyExternalTixPressed();
                        }
                      },
                    )
                  : const SizedBox(),
            ],
          );
        });
  }

  _showBuyTicketButton(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.darkPrimary,
          foregroundColor: Constants.primary,
          shadowColor: Colors.white30,
          minimumSize: const Size.fromHeight(60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          elevation: 3,
        ),
        label: const Text(
          'buy ticket',
          style: TextStyle(fontSize: 14),
        ),
        icon: Icon(
          widget.party.isTix ? Icons.star_rate : Icons.star_half,
          size: 24.0,
        ),
        onPressed: () {
          if(widget.party.isTix){
            _handleBuyTixPressed();
          } else {
            _handleBuyExternalTixPressed();
          }
        },
      ),
    ));
  }

  _showDisabledBuyTicketButton(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Constants.primary,
          shadowColor: Colors.white30,
          minimumSize: const Size.fromHeight(60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          elevation: 3,
        ),
        label: const Text(
          'buy ticket',
          style: TextStyle(fontSize: 14, color: Constants.darkPrimary),
        ),
        icon: const Icon(
          Icons.star_border_outlined,
          size: 24.0,
        ),
        onPressed: () {
          Logx.ilt(_TAG,
              'unfortunately, tickets are not available for this event yet!');
          // _handleBuyTixPressed();
        },
      ),
    ));
  }

  _showEditGuestListButton(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.darkPrimary,
          foregroundColor: Constants.primary,
          shadowColor: Colors.white30,
          minimumSize: const Size.fromHeight(60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          elevation: 3,
        ),
        label: const Text(
          'edit',
          style: TextStyle(fontSize: 14),
        ),
        icon: const Icon(
          Icons.mode_edit_outline_outlined,
          size: 24.0,
        ),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => PartyGuestAddEditManageScreen(
                    partyGuest: widget.partyGuest,
                    party: widget.party,
                    task: 'edit',
                  )));
        },
      ),
    ));
  }

  _showGuestListEntryButton(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.darkPrimary,
          foregroundColor: Constants.primary,
          shadowColor: Colors.white30,
          minimumSize: const Size.fromHeight(60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          elevation: 3,
        ),
        label: const Text(
          'guest entry',
          style: TextStyle(fontSize: 14),
        ),
        icon: const Icon(
          Icons.qr_code_rounded,
          size: 24.0,
        ),
        onPressed: () {
          _showTicketEntryDialog(context);
        },
      ),
    ));
  }

  _showPendingButton(BuildContext context) {
    bool isTicketedEvent = (widget.party.ticketUrl.isNotEmpty || widget.party.isTix) && !widget.party.isTicketsDisabled;
    String text = isTicketedEvent
        ? "your guest list is pending, which means it's waiting for approval. limited spots are only available for this event – secure yours by purchasing your ticket in advance."
        : "your guest list is pending, which means it's waiting for approval. like a kid waiting for santa, you're excited but also a little bit anxious. but don't worry, our team will deliver on your request.";
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        height: 60,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.lightPrimary,
            foregroundColor: Constants.primary,
            shadowColor: Colors.white30,
            minimumSize: const Size.fromHeight(60),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            elevation: 3,
          ),
          label: const Text(
            'pending',
            style: TextStyle(fontSize: 14, color: Constants.darkPrimary),
          ),
          icon: const Icon(
            Icons.pending,
            size: 24.0,
            color: Constants.darkPrimary,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    '⏳ guest list is pending'.toLowerCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, color: Colors.black),
                  ),
                  backgroundColor: Constants.lightPrimary,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  contentPadding: const EdgeInsets.all(16.0),
                  content: Text(text),
                  actions: [
                    TextButton(
                      child: const Text("👍 okay"),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                    isTicketedEvent ?
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Constants.darkPrimary),
                      ),
                      child: const Text(
                        "🎟 buy tix",
                        style: TextStyle(color: Constants.primary),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if(widget.party.isTix){
                          _handleBuyTixPressed();
                        } else {
                          _handleBuyExternalTixPressed();
                        }
                      },
                    )
                    : !widget.partyGuest.isChallengeClicked
                        ? TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Constants.darkPrimary),
                            ),
                            child: const Text(
                              "🎟 win free entry",
                              style: TextStyle(color: Constants.primary),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _loadChallengeDialog(context);
                            },
                          )
                        : const SizedBox(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleBuyExternalTixPressed() {
    final uri = Uri.parse(widget.party.ticketUrl);
    NetworkUtils.launchInBrowser(uri);

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

  Challenge findChallenge() {
    Challenge returnChallenge = widget.challenges.last;

    if (widget.party.overrideChallengeNum > 0) {
      for (Challenge challenge in widget.challenges) {
        if (challenge.level == widget.party.overrideChallengeNum) {
          return challenge;
        }
      }
    } else {
      for (Challenge challenge in widget.challenges) {
        if (challenge.level >= UserPreferences.myUser.challengeLevel) {
          return challenge;
        }
      }
    }

    return returnChallenge;
  }

  bool testMode = false;

  _loadChallengeDialog(BuildContext context) {
    Challenge challenge = findChallenge();
    String challengeText = challenge.description;

    if (challengeText.isEmpty) {
      Logx.ist(_TAG, 'all challenges are completed. congratulations!');
    } else {
      FirestoreHelper.pullChallengeActions(challenge.id).then((res) {
        if (res.docs.isNotEmpty) {
          List<ChallengeAction> cas = [];
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            ChallengeAction ca = Fresh.freshChallengeActionMap(data, false);

            if (ca.actionType == 'instagram_url') {
              ca = ca.copyWith(action: widget.party.instagramUrl);
            } else if (ca.actionType == 'bloc_url') {
              final url =
                  'http://bloc.bar/#/event/${Uri.encodeComponent(widget.party.name)}/${widget.party.chapter}';
              ca = ca.copyWith(action: url);
            }
            cas.add(ca);
          }

          _showChallengeDialog(context, challenge, cas);
        } else {
          _showChallengeDefaultsDialog(context, challenge);
        }
      });
    }
  }

  void _showChallengeDialog(
      BuildContext context, Challenge challenge, List<ChallengeAction> cas) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              '#blocCommunity support & win free 🎟️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    '${challenge.dialogTitle}:\n',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(challenge.description.toLowerCase()),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              cas.length > 1
                  ? TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Constants.darkPrimary),
                      ),
                      child: Text(cas[1].buttonTitle,
                          style: const TextStyle(color: Constants.primary)),
                      onPressed: () async {
                        Logx.ist(_TAG, 'thank you for supporting us! 💖');

                        widget.partyGuest = widget.partyGuest
                            .copyWith(isChallengeClicked: true);
                        if (!testMode) {
                          FirestoreHelper.pushPartyGuest(widget.partyGuest);
                          FirestoreHelper.updateChallengeClickCount(
                              challenge.id);
                        }

                        final uri = Uri.parse(cas[1].action);
                        NetworkUtils.launchInBrowser(uri);

                        Navigator.of(ctx).pop();
                      },
                    )
                  : const SizedBox(),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Constants.darkPrimary),
                ),
                child: Text(cas[0].buttonTitle,
                    style: const TextStyle(color: Constants.primary)),
                onPressed: () async {
                  Logx.ist(_TAG, 'thank you for supporting us! 💖');

                  widget.partyGuest =
                      widget.partyGuest.copyWith(isChallengeClicked: true);
                  if (!testMode) {
                    FirestoreHelper.pushPartyGuest(widget.partyGuest);
                    FirestoreHelper.updateChallengeClickCount(challenge.id);
                  }

                  final uri = Uri.parse(cas[0].action);
                  NetworkUtils.launchInBrowser(uri);

                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        });
  }

  void _showChallengeDefaultsDialog(BuildContext context, Challenge challenge) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              '#blocCommunity support & win free 🎟️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    '${challenge.dialogTitle}:\n',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(challenge.description.toLowerCase()),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Constants
                      .darkPrimary), // Set your desired background color
                ),
                child: Text(challenge.dialogAcceptText,
                    style: const TextStyle(color: Constants.primary)),
                onPressed: () async {
                  Logx.ist(_TAG, 'thank you for supporting us! 💖');

                  widget.partyGuest =
                      widget.partyGuest.copyWith(isChallengeClicked: true);
                  if (!testMode) {
                    FirestoreHelper.pushPartyGuest(widget.partyGuest);
                    FirestoreHelper.updateChallengeClickCount(challenge.id);
                  }

                  if (widget.party.storyImageUrl.isNotEmpty ||
                      widget.party.imageUrl.isNotEmpty) {
                    final urlImage = widget.party.storyImageUrl.isNotEmpty
                        ? widget.party.storyImageUrl
                        : widget.party.imageUrl;
                    if (kIsWeb) {
                      FileUtils.openFileNewTabForWeb(urlImage);
                    } else {
                      FileUtils.sharePhoto(
                          widget.party.id,
                          urlImage,
                          'bloc-${widget.party.name}',
                          ''
                              '${StringUtils.firstFewWords(widget.party.description, 15)}... '
                              '\n\nhey. check out this event at the official bloc app.'
                              '\n\n🍎 ios:\n${Constants.urlBlocAppStore} \n\n🤖 android:\n${Constants.urlBlocPlayStore} \n\n🌏 web:\n${Constants.urlBlocWeb} \n\n#blocCommunity 💛');
                    }
                  } else {
                    final uri = Uri.parse(Constants.blocInstaHandle);
                    NetworkUtils.launchInBrowser(uri);
                  }

                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        });
  }

  void _handleBuyTixPressed() {
    if(kIsWeb){
      if(widget.party.ticketUrl.isNotEmpty){
        final uri = Uri.parse(widget.party.ticketUrl);
        NetworkUtils.launchInBrowser(uri);
      } else {
        //navigate to purchase tix screen
        Tix tix = Dummy.getDummyTix();
        tix = tix.copyWith(partyId: widget.party.id);

        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => TixBuyEditScreen(
                  tix: tix, task: 'buy')),
        );
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
