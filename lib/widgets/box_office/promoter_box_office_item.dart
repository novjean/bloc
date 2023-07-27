import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../../db/entity/challenge.dart';
import '../../db/entity/party.dart';
import '../../main.dart';
import '../../screens/parties/box_office_guest_confirm_screen.dart';
import '../../screens/parties/party_guest_add_edit_manage_screen.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../ui/toaster.dart';

class PromoterBoxOfficeItem extends StatefulWidget {
  PartyGuest partyGuest;
  final Party party;
  final bool isClickable;
  final List<Challenge> challenges;

  PromoterBoxOfficeItem(
      {Key? key,
      required this.partyGuest,
      required this.isClickable,
      required this.party,
      required this.challenges})
      : super(key: key);

  @override
  State<PromoterBoxOfficeItem> createState() => _PromoterBoxOfficeItemState();
}

class _PromoterBoxOfficeItemState extends State<PromoterBoxOfficeItem> {
  static const String _TAG = 'PromoterBoxOfficeItem';

  @override
  Widget build(BuildContext context) {
    String title =
        '${widget.partyGuest.name.toLowerCase()} ${widget.partyGuest.surname.toLowerCase()}';
    int friendsCount = widget.partyGuest.guestsCount - 1;

    if (friendsCount > 0) {
      title += ' +$friendsCount';
    }

    if (widget.partyGuest.isVip) {
      title += ' [vip]';
    }

    bool showGuestRemaining = widget.partyGuest.guestsRemaining >= 2 ||
            widget.partyGuest.guestsRemaining == 0
        ? true
        : false;

    String guestNames = '';
    if (widget.partyGuest.guestNames.isNotEmpty) {
      for (String name in widget.partyGuest.guestNames) {
        guestNames += '$name. ';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (ctx) => BoxOfficeGuestConfirmScreen(
                    partyGuestId: widget.partyGuest.id,
                  )),
        );
      },
      onDoubleTap: () {
        if (UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => PartyGuestAddEditManageScreen(
                    partyGuest: widget.partyGuest,
                    party: widget.party,
                    task: 'manage',
                  )));
        }
      },
      child: Hero(
        tag: widget.partyGuest.id,
        child: Card(
          elevation: 1,
          color: Theme.of(context).primaryColorLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SizedBox(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
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
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                    showArrivedOrNotButton(context)
                  ],
                ),
                Text(
                  '+${widget.partyGuest.phone}',
                  style: const TextStyle(fontSize: 16),
                ),
                showGuestRemaining
                    ? widget.partyGuest.guestsRemaining != 0
                        ? Text(
                            '${widget.partyGuest.guestsRemaining} guests ',
                            style: const TextStyle(fontSize: 16),
                          )
                        : Text(
                            '${widget.partyGuest.guestsCount} guests entered',
                            style: const TextStyle(fontSize: 16),
                          )
                    : const SizedBox(),
                guestNames.isNotEmpty ? Text(guestNames) : const SizedBox()
              ],
            ),
          )),
        ),
      ),
    );
  }

  showEditOrTicketButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        ),
        child: Text(
          widget.partyGuest.isApproved ? '🎟 ticket' : '✏️ edit',
          style: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          widget.partyGuest.isApproved
              ? showTicketEntryDialog(context)
              : Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => PartyGuestAddEditManageScreen(
                        partyGuest: widget.partyGuest,
                        party: widget.party,
                        task: 'edit',
                      )));
        },
      ),
    );
  }

  showTicketEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: mq.height * 0.5,
            width: mq.width * 0.75,
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

  showApproveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 5),
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        ),
        child: const Text(
          '✅ approve',
          style: TextStyle(fontSize: 16),
        ),
        onPressed: () {
          widget.partyGuest = widget.partyGuest.copyWith(isApproved: true);
          FirestoreHelper.pushPartyGuest(widget.partyGuest);
        },
      ),
    );
  }

  showUnapproveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 5),
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        ),
        child: const Text(
          '⛔ deny',
          style: TextStyle(fontSize: 16),
        ),
        onPressed: () {
          widget.partyGuest = widget.partyGuest.copyWith(isApproved: false);
          FirestoreHelper.pushPartyGuest(widget.partyGuest);
        },
      ),
    );
  }

  displayBanUserButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 5),
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        ),
        child: const Text(
          '🚫 ban user',
          style: TextStyle(fontSize: 16),
        ),
        onPressed: () {
          widget.partyGuest = widget.partyGuest.copyWith(shouldBanUser: true);
          FirestoreHelper.pushPartyGuest(widget.partyGuest);
          Toaster.longToast('request to ban has been sent');
        },
      ),
    );
  }

  displayFreeUserButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 5),
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: Constants.darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        ),
        child: const Text(
          '🤝 free user',
          style: TextStyle(fontSize: 16),
        ),
        onPressed: () {
          widget.partyGuest = widget.partyGuest.copyWith(shouldBanUser: false);
          FirestoreHelper.pushPartyGuest(widget.partyGuest);
          Toaster.longToast('request to free user has been sent');
        },
      ),
    );
  }

  showArrivedOrNotButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 5),
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        ),
        child: Text(
          widget.partyGuest.guestsRemaining != 0
              ? '👍🏿 arrived'
              : '👎🏿 not arrived',
          style: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => BoxOfficeGuestConfirmScreen(
                      partyGuestId: widget.partyGuest.id,
                    )),
          );

          // if (widget.partyGuest.guestsRemaining != 0) {
          //   widget.partyGuest = widget.partyGuest
          //       .copyWith(guestsRemaining: 0, isApproved: true);
          //   FirestoreHelper.pushPartyGuest(widget.partyGuest);
          //
          //   if(widget.partyGuest.guestStatus == 'promoter'){
          //     FirestoreHelper.pullPromoterGuest(widget.partyGuest.id).then((res) {
          //       if(res.docs.isNotEmpty){
          //         DocumentSnapshot document = res.docs[0];
          //         Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          //         PromoterGuest promoterGuest = Fresh.freshPromoterGuestMap(data, false);
          //         promoterGuest = promoterGuest.copyWith(hasAttended: true);
          //         FirestoreHelper.pushPromoterGuest(promoterGuest);
          //
          //         Logx.i(_TAG, 'promoter guest ${promoterGuest.name} has attended');
          //       } else {
          //         Logx.em(_TAG, 'promoter guest could not be found for the party guest id: ${widget.partyGuest.id}');
          //       }
          //     });
          //   }
          // } else {
          //   widget.partyGuest.guestsRemaining = widget.partyGuest.guestsCount;
          //   FirestoreHelper.pushPartyGuest(widget.partyGuest);
          //
          //   FirestoreHelper.pullPromoterGuest(widget.partyGuest.id).then((res) {
          //     if(res.docs.isNotEmpty){
          //       DocumentSnapshot document = res.docs[0];
          //       Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          //       PromoterGuest promoterGuest = Fresh.freshPromoterGuestMap(data, false);
          //       promoterGuest = promoterGuest.copyWith(hasAttended: false);
          //       FirestoreHelper.pushPromoterGuest(promoterGuest);
          //
          //       Logx.i(_TAG, 'promoter guest ${promoterGuest.name} has not attended');
          //     } else {
          //       Logx.em(_TAG, 'promoter guest could not be found for the party guest id: ${widget.partyGuest.id}');
          //     }
          //   });
          // }
        },
      ),
    );
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
              challenge.dialogAccept2Text.isNotEmpty
                  ? TextButton(
                      child: Text(challenge.dialogAccept2Text),
                      onPressed: () async {
                        Logx.i(_TAG, 'user accepts challenge');
                        Toaster.longToast('thank you for supporting us!');

                        widget.partyGuest = widget.partyGuest
                            .copyWith(isChallengeClicked: true);
                        FirestoreHelper.pushPartyGuest(widget.partyGuest);

                        switch (challenge.level) {
                          case 3:
                            {
                              //android download
                              final uri = Uri.parse(
                                  'https://play.google.com/store/apps/details?id=com.novatech.bloc');
                              NetworkUtils.launchInBrowser(uri);
                              break;
                            }
                          default:
                            {
                              final uri = Uri.parse(
                                  'https://www.instagram.com/bloc.india/');
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

                  widget.partyGuest =
                      widget.partyGuest.copyWith(isChallengeClicked: true);
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
                    case 3:
                      {
                        //ios download
                        final uri = Uri.parse(
                            'https://apps.apple.com/in/app/bloc-community/id1672736309');
                        NetworkUtils.launchInBrowser(uri);
                        break;
                      }
                    case 4:
                      {
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
