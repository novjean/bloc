import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:http/http.dart' as http;


import '../../db/entity/challenge.dart';
import '../../db/entity/party.dart';
import '../../main.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../ui/button_widget.dart';
import '../ui/toaster.dart';

class BoxOfficeItem extends StatefulWidget {
  PartyGuest partyGuest;
  final Party party;
  final bool isClickable;
  final List<Challenge> challenges;

  BoxOfficeItem(
      {Key? key,
      required this.partyGuest,
      required this.isClickable,
      required this.party,
        required this.challenges})
      : super(key: key);

  @override
  State<BoxOfficeItem> createState() => _BoxOfficeItemState();
}

class _BoxOfficeItemState extends State<BoxOfficeItem> {
  static const String _TAG = 'BoxOfficeItem';

  @override
  Widget build(BuildContext context) {
    String title = widget.partyGuest.name.toLowerCase();
    int friendsCount = widget.partyGuest.guestsCount - 1;

    if (friendsCount > 0) {
      title += ' +$friendsCount';
    }

    return GestureDetector(
      onTap: () {
        // isClickable
        //     ? Navigator.of(context).push(
        //         MaterialPageRoute(builder: (ctx) => ArtistScreen(party: party)),
        //       )
        //     : print('party guest item no click');
      },
      child: Hero(
        tag: widget.partyGuest.id,
        child: Card(
          elevation: 1,
          color: Theme.of(context).primaryColorLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: SizedBox(
            height: 150,
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
                        padding:
                            const EdgeInsets.only(left: 5.0, right: 5, top: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            UserPreferences.myUser.clearanceLevel >=
                                    Constants.PROMOTER_LEVEL
                                ? ToggleSwitch(
                                    customWidths: [40.0, 40.0],
                                    cornerRadius: 20.0,
                                    activeBgColors: [
                                      [Constants.background],
                                      [Colors.redAccent]
                                    ],
                                    activeFgColor: Colors.white,
                                    inactiveBgColor: Colors.grey,
                                    inactiveFgColor: Colors.white,
                                    initialLabelIndex:
                                        widget.partyGuest.guestsRemaining == 0
                                            ? 0
                                            : 1,
                                    totalSwitches: 2,
                                    labels: ['👍🏼', '👎🏼'],
                                    onToggle: (index) {
                                      debugPrint('switched to: $index');
                                      if (index == 0) {
                                        widget.partyGuest.guestsRemaining = 0;
                                        FirestoreHelper.pushPartyGuest(
                                            widget.partyGuest);
                                      } else {
                                        widget.partyGuest.guestsRemaining =
                                            widget.partyGuest.guestsCount;
                                        FirestoreHelper.pushPartyGuest(
                                            widget.partyGuest);
                                      }
                                    },
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      widget.party.eventName.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 5.0),
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
                              : '${DateTimeUtils.getFormattedDate(widget.party.startTime)}, '
                              '${DateTimeUtils.getFormattedTime(widget.party.startTime)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: widget.partyGuest.isApproved? showApprovedButton(context)
                                :showPendingButton(context)
                          ),
                          const Spacer(),
                          UserPreferences.myUser.clearanceLevel>=Constants.PROMOTER_LEVEL?
                          displayBanUserButton(context) : const SizedBox(),
                          UserPreferences.myUser.clearanceLevel>=Constants.PROMOTER_LEVEL?
                          displayEntryEditButton(context):displayUserEntryEditButton(context),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      image: DecorationImage(
                        image: NetworkImage(widget.party.imageUrl),
                        fit: BoxFit.cover,
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

  displayUserEntryEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 5),
      child: widget.partyGuest.isApproved
          ? DarkButtonWidget(
        text: '🎟 entry',
        onClicked: () {
          showTicketEntryDialog(context);
        },
      ): ButtonWidget(
        text: '✏️ edit',
        onClicked: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => PartyGuestAddEditManageScreen(
                partyGuest: widget.partyGuest,
                party: widget.party,
                task: 'edit',
              )));
        },
      ),
    );
  }

  displayEntryEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 5),
      child: widget.partyGuest.isApproved
          ? SizedBox(
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  shape: const CircleBorder(),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                ),
                child: const Text(
                  '🎟',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  showTicketEntryDialog(context);
                },
              ),
            )
          : SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColorDark,
            shape: const CircleBorder(),
            foregroundColor: Colors.white,
            padding:
            const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          ),
          child: const Text(
            '✏️',
            style: TextStyle(fontSize: 18),
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
      )
    );
  }

  displayBanUserButton(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: !widget.partyGuest.shouldBanUser
            ? SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    shape: const CircleBorder(),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  ),
                  child: const Text(
                    '🚷',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    widget.partyGuest.shouldBanUser = true;
                    FirestoreHelper.pushPartyGuest(widget.partyGuest);
                    Toaster.longToast('request to ban has been sent');
                  },
                ),
              )
            : SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    shape: const CircleBorder(),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  ),
                  child: const Text(
                    '🤝',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    widget.partyGuest.shouldBanUser = false;
                    FirestoreHelper.pushPartyGuest(widget.partyGuest);
                    Toaster.longToast('request to ban has been canceled');
                  },
                ),
              ));
  }

  showTicketEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: mq.height * 0.4,
            width: mq.width * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    '${widget.party.eventName} | ${widget.party.name}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Center(
                    child: BarcodeWidget(
                      color: Theme.of(context).primaryColorDark,
                      barcode: Barcode.qrCode(),
                      // Barcode type and settings
                      data: widget.partyGuest.id,
                      // Content
                      width: mq.width * 0.5,
                      height: mq.width * 0.5,
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
                            style: TextStyle(fontSize: 16),
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

  showApprovedButton(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: 5),
        child:SizedBox(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(),
              foregroundColor: Constants.lightPrimary,
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            ),
            child: const Text(
              '😃 approved',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
            },
          ),
        ));
  }

  showPendingButton(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: 5),
        child:SizedBox(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.lightPrimary,
              shape: const RoundedRectangleBorder(),
              foregroundColor: Constants.darkPrimary,
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            ),
            child: const Text(
              '⏳ pending',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("guest list is pending"),
                    content: const Text("your guest list is pending, which means it's waiting for approval. like a kid waiting for santa, you're excited but also a little bit anxious. but don't worry, our team will deliver on your request."),
                    actions: [
                      !widget.partyGuest.isChallengeClicked?
                      TextButton(
                        child: const Text("🎟 win entry"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          showChallengeDialog(context);
                        },
                      ): const SizedBox(),
                      TextButton(
                        child: const Text("👍 okay"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ));
  }

  Challenge findChallenge() {
    Challenge returnChallenge = widget.challenges.last;

    if(widget.party.overrideChallengeNum>0){
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

  showChallengeDialog(BuildContext context) {
    Challenge challenge = findChallenge();

    String challengeText = challenge.description;

    if (challengeText.isEmpty) {
      // all challenges are completed
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: SizedBox(
              height: 300,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '#blocCommunity  | ${widget.party.name}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    width: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('${challenge.dialogTitle}:\n'),
                          Text(challenge.description.toLowerCase()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('close'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  },
              ),
              challenge.dialogAccept2Text.isNotEmpty?
              TextButton(
                child: Text(challenge.dialogAccept2Text),
                onPressed: () async {
                  Logx.i(_TAG, 'user accepts challenge');
                  Toaster.longToast('thank you for supporting us!');

                  widget.partyGuest = widget.partyGuest.copyWith(isChallengeClicked: true);
                  FirestoreHelper.pushPartyGuest(widget.partyGuest);

                  switch (challenge.level) {
                    case 3:{
                      //android download
                      final uri = Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.novatech.bloc');
                      NetworkUtils.launchInBrowser(uri);
                      break;
                    }
                    default:
                      {
                        final uri =
                        Uri.parse('https://www.instagram.com/bloc.india/');
                        NetworkUtils.launchInBrowser(uri);
                        break;
                      }
                  }
                },
              )
                  : const SizedBox(),

              TextButton(
                child: Text(challenge.dialogAcceptText),
                onPressed: () async {
                  Logx.i(_TAG, 'user accepts challenge');
                  Toaster.longToast('thank you for supporting us!');

                  widget.partyGuest = widget.partyGuest.copyWith(isChallengeClicked: true);
                  FirestoreHelper.pushPartyGuest(widget.partyGuest);

                  switch (challenge.level) {
                    case 1:
                      {
                        final uri =
                        Uri.parse('https://www.instagram.com/bloc.india/');
                        NetworkUtils.launchInBrowser(uri);
                        break;
                      }
                    case 2:
                      {
                        final uri =
                        Uri.parse('https://www.instagram.com/freq.club/');
                        NetworkUtils.launchInBrowser(uri);
                        break;
                      }
                    case 3:{
                      //ios download
                      final uri = Uri.parse(
                          'https://apps.apple.com/in/app/bloc-community/id1672736309');
                      NetworkUtils.launchInBrowser(uri);
                      break;
                    }
                    case 4:{
                      //share or invite your friends
                      final uri = Uri.parse(widget.party.instagramUrl);
                      NetworkUtils.launchInBrowser(uri);
                      break;
                    }
                    case 100:
                      {
                        final urlImage = widget.party.storyImageUrl.isNotEmpty
                            ? widget.party.storyImageUrl
                            : widget.party.imageUrl;
                        final Uri url = Uri.parse(urlImage);
                        final response = await http.get(url);
                        final Uint8List bytes = response.bodyBytes;

                        try {
                          if (kIsWeb) {
                            FileUtils.openFileNewTabForWeb(urlImage);

                            // Image? fromPicker = await ImagePickerWeb.getImageAsWidget();
                          } else {
                            var temp = await getTemporaryDirectory();
                            final path = '${temp.path}/${widget.party.id}.jpg';
                            File(path).writeAsBytesSync(bytes);

                            final files = <XFile>[];
                            files.add(
                                XFile(path, name: '${widget.party.id}.jpg'));

                            await Share.shareXFiles(files,
                                text: '#blocCommunity');
                          }
                        } on PlatformException catch (e, s) {
                          Logx.e(_TAG, e, s);
                        } on Exception catch (e, s) {
                          Logx.e(_TAG, e, s);
                        } catch (e) {
                          logger.e(e);
                        }
                        break;
                      }
                    default:
                      {
                        final uri =
                        Uri.parse('https://www.instagram.com/bloc.india/');
                        NetworkUtils.launchInBrowser(uri);
                        break;
                      }
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }
}
