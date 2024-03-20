import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/screens/parties/party_guest_add_edit_manage_screen.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../../api/apis.dart';
import '../../db/entity/party.dart';
import '../../db/entity/promoter_guest.dart';
import '../../db/entity/user.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../widgets/parties/manage_guest_list_item.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/loading_widget.dart';

class ManageGuestListScreen extends StatefulWidget {
  const ManageGuestListScreen({super.key});

  @override
  State<ManageGuestListScreen> createState() => _ManageGuestListScreenState();
}

class _ManageGuestListScreenState extends State<ManageGuestListScreen> {
  static const String _TAG = 'ManageGuestListScreen';

  var _isPartiesLoading = true;
  List<Party> mParties = [];
  List<Party> sParties = [];

  Party sParty = Dummy.getDummyParty('');
  String sPartyName = 'all';
  String sPartyId = '';
  List<String> mPartyNames = [];

  List<PartyGuest> mPartyGuests = [];
  List<PartyGuest> mUnapprovedPartyGuests = [];
  bool _showAllGuestList = true;

  @override
  void initState() {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    FirestoreHelper.pullActiveGuestListParties(timeNow).then((res) {
      Logx.i(_TAG, "successfully pulled in parties");

      if (res.docs.isNotEmpty) {
        // found parties
        List<Party> parties = [];
        List<String> partyNames = ['all'];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, true);
          parties.add(party);
          partyNames.add('${party.name} ${party.chapter}');
        }
        setState(() {
          mParties = parties;
          mPartyNames = partyNames;
          _isPartiesLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no parties found!');
        const Center(
          child: Text('no parties assigned yet!'),
        );
        setState(() {
          _isPartiesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: 'manage guest list'),
        titleSpacing: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionsDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'actions',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.science,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartiesLoading
        ? const LoadingWidget()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 5.0),
              _displayPartiesDropdown(context),
              const SizedBox(height: 5.0),
              _buildPartyGuestList(context),
              const SizedBox(height: 70.0),
            ],
          );
  }

  _displayPartiesDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            key: const ValueKey('parties_key'),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorStyle: const TextStyle(
                    color: Constants.errorColor, fontSize: 16.0),
                hintText: 'please select party',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Constants.primary),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Constants.primary, width: 0.0),
                )),
            isEmpty: sPartyName == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: const TextStyle(color: Constants.primary),
                dropdownColor: Constants.background,
                value: sPartyName,
                isDense: true,
                onChanged: (String? newValue) {
                  setState(() {
                    sPartyName = newValue!;

                    for (Party party in mParties) {
                      if ('${party.name} ${party.chapter}' == sPartyName) {
                        sPartyId = party.id;
                        sParty = party;
                        break;
                      }
                    }

                    state.didChange(newValue);
                  });
                },
                items: mPartyNames.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  _buildPartyGuestList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: sPartyName == 'all'
            ? FirestoreHelper.getGuestLists()
            : FirestoreHelper.getPartyGuestList(sPartyId),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                mPartyGuests = [];
                mUnapprovedPartyGuests = [];

                if (snapshot.data!.docs.isNotEmpty) {
                  try {
                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      DocumentSnapshot document = snapshot.data!.docs[i];
                      Map<String, dynamic> map =
                          document.data()! as Map<String, dynamic>;
                      final PartyGuest partyGuest =
                          Fresh.freshPartyGuestMap(map, false);
                      mPartyGuests.add(partyGuest);

                      if (!partyGuest.isApproved) {
                        mUnapprovedPartyGuests.add(partyGuest);
                      }
                    }
                    return _showGuestList(context);
                  } on Exception catch (e, s) {
                    Logx.e(_TAG, e, s);
                  } catch (e) {
                    Logx.em(_TAG, 'error loading party guest$e');
                  }
                }
              }
          }
          return const LoadingWidget();
        });
  }

  _showGuestList(BuildContext context) {
    List<PartyGuest> partyGuestList =
        _showAllGuestList ? mPartyGuests : mUnapprovedPartyGuests;

    return Expanded(
      child: ListView.builder(
          itemCount: partyGuestList.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            PartyGuest partyGuest = partyGuestList[index];

            String partyName = '';
            if (sPartyName == 'all') {
              for (Party party in mParties) {
                if (partyGuest.partyId == party.id) {
                  partyName = '${party.name} ${party.chapter}';
                  break;
                }
              }
            } else {
              partyName = '${sParty.name} ${sParty.chapter}';
            }

            return GestureDetector(
                child: ManageGuestListItem(
                  partyGuest: partyGuestList[index],
                  partyName: partyName,
                ),
                onTap: () {
                  PartyGuest sPartyGuest = partyGuestList[index];

                  Party sParty = Dummy.getDummyParty('');

                  for (Party party in mParties) {
                    if (party.id == sPartyGuest.partyId) {
                      sParty = party;
                      break;
                    }
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => PartyGuestAddEditManageScreen(
                            partyGuest: sPartyGuest,
                            party: sParty,
                            task: 'manage',
                          )));
                });
          }),
    );
  }

  _showActionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: _actionsList(ctx),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _actionsList(BuildContext ctx) {
    return SizedBox(
      height: mq.height * 0.5,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'actions',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: mq.height * 0.45,
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('un-approved/all'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () {
                                  Navigator.of(ctx).pop();

                                  setState(() {
                                    _showAllGuestList = !_showAllGuestList;
                                  });
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.people_alt_outlined),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('internal list'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () {
                                  Navigator.of(ctx).pop();

                                  String guestListText = '';
                                  for (PartyGuest partyGuest in mPartyGuests) {
                                    String guests = '';
                                    if (partyGuest.guestNames.isNotEmpty) {
                                      for (String name
                                          in partyGuest.guestNames) {
                                        guests += '$name | ';
                                      }
                                    }

                                    guestListText +=
                                        '${partyGuest.name},${partyGuest.surname},'
                                        '+${partyGuest.phone},${partyGuest.email},${partyGuest.guestsCount} pax,${partyGuest.gender},'
                                        '${partyGuest.guestStatus},$guests,${partyGuest.isApproved ? 'approved' : 'not approved'}\n';
                                  }

                                  String rand = StringUtils.getRandomString(5);
                                  String fileName = '$sPartyName-$rand.csv';
                                  FileUtils.shareCsvFile(
                                      fileName, guestListText, sPartyName);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.share_outlined,
                                        color: Colors.lightBlue),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('share list'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () async {
                                  Navigator.of(ctx).pop();

                                  String guestListText = '';
                                  for (PartyGuest partyGuest in mPartyGuests) {
                                    String guests = '';
                                    if (partyGuest.guestNames.isNotEmpty) {
                                      for (String name
                                          in partyGuest.guestNames) {
                                        guests += '$name | ';
                                      }
                                    }

                                    guestListText +=
                                        '${partyGuest.name},${partyGuest.surname},'
                                        '+${partyGuest.phone},${partyGuest.guestsCount} pax,'
                                        '${partyGuest.guestStatus},$guests,${partyGuest.isApproved ? 'approved' : 'not approved'}\n';
                                  }

                                  String rand = StringUtils.getRandomString(5);
                                  String fileName = '$sPartyName-$rand.csv';
                                  FileUtils.shareCsvFile(
                                      fileName, guestListText, sPartyName);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.share_outlined,
                                        color: Colors.lightBlue),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('no promoter list'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () async {
                                  Navigator.of(ctx).pop();

                                  String guestListText = '';
                                  for (PartyGuest partyGuest in mPartyGuests) {
                                    if (partyGuest.guestStatus != 'promoter') {
                                      String guests = '';
                                      if (partyGuest.guestNames.isNotEmpty) {
                                        for (String name
                                            in partyGuest.guestNames) {
                                          guests += '$name | ';
                                        }
                                      }

                                      guestListText +=
                                          '${partyGuest.name},${partyGuest.surname},'
                                          '+${partyGuest.phone},${partyGuest.guestsCount} pax,'
                                          '${partyGuest.guestStatus},$guests,${partyGuest.isApproved ? 'approved' : 'not approved'}\n';
                                    }
                                  }

                                  String rand = StringUtils.getRandomString(5);
                                  String fileName = '$sPartyName-$rand.csv';
                                  FileUtils.shareCsvFile(
                                      fileName, guestListText, sPartyName);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.share_outlined,
                                      color: Colors.lightBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('move list'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () async {
                                  Navigator.of(ctx).pop();
                                  _showMoveGuestList(context);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.multiple_stop),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('un-approve all'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () async {
                                  Navigator.of(ctx).pop();
                                  _showUnapproveAllGuestList(context);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.cancel_outlined),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('google review'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () async {
                                  Navigator.of(ctx).pop();
                                  _showRequestReviewFromGuests(context);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.reviews),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('google review - whatsapp'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () async {
                                  Navigator.of(ctx).pop();
                                  _showWhatsappRequestGoogleReviews(context);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.reviews),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('app review - whatsapp'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.primary,
                              child: InkWell(
                                splashColor: Constants.darkPrimary,
                                onTap: () async {
                                  Navigator.of(ctx).pop();
                                  _showWhatsappRequestAppReviews(context);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.reviews),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('clean promoter guests'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.darkPrimary,
                              child: InkWell(
                                splashColor: Constants.primary,
                                onTap: () {
                                  Navigator.of(ctx).pop();

                                  for (PartyGuest guest in mPartyGuests) {
                                    if (guest.guestStatus == 'promoter') {
                                      FirestoreHelper.deletePartyGuest(
                                          guest.id);
                                    }
                                  }

                                  FirestoreHelper.pullAllPromoterGuests()
                                      .then((res) {
                                    if (res.docs.isNotEmpty) {
                                      int now = Timestamp.now()
                                          .millisecondsSinceEpoch;
                                      int count = 0;

                                      for (int i = 0;
                                          i < res.docs.length;
                                          i++) {
                                        DocumentSnapshot document = res.docs[i];
                                        Map<String, dynamic> data = document
                                            .data()! as Map<String, dynamic>;
                                        final PromoterGuest pg =
                                            Fresh.freshPromoterGuestMap(
                                                data, false);

                                        FirestoreHelper.deletePromoterGuest(
                                            pg.id);

                                        if (now - pg.createdAt >
                                            2 *
                                                DateTimeUtils
                                                    .millisecondsWeek) {
                                          count++;
                                        }
                                      }
                                      Logx.ist(_TAG,
                                          'cleaned $count promoter guests');
                                    } else {
                                      Logx.ist(_TAG,
                                          'no promoter guests data found');
                                    }
                                  });
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.cleaning_services,
                                        color: Constants.errorColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('clean non app user guests'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.darkPrimary,
                              child: InkWell(
                                splashColor: Constants.primary,
                                onTap: () {
                                  Navigator.of(ctx).pop();

                                  _cleanNonAppUserGuests(context);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.person_add_disabled_sharp,
                                        color: Constants.errorColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('delete list'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.darkPrimary,
                              child: InkWell(
                                splashColor: Constants.primary,
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  _showGoogleReviewDialog(context);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.delete_forever,
                                      color: Constants.errorColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showGoogleReviewDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'request google review from all ${sPartyName == 'all' ? '' : sPartyName} guest lists',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'request for google review from ${mPartyGuests.length} guests. '
                'are you sure you want to ask from those who were approved?'),
            actions: [
              TextButton(
                child: const Text('review bloc'),
                onPressed: () async {
                  _handleReviewBloc();

                  Navigator.of(ctx).pop();
                  _showDeleteAllGuestList(context);
                },
              ),
              TextButton(
                child: const Text('review freq'),
                onPressed: () async {
                  _handleReviewFreq();

                  Navigator.of(ctx).pop();
                  _showDeleteAllGuestList(context);
                },
              ),
              TextButton(
                child: const Text("no"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showDeleteAllGuestList(context);
                },
              )
            ],
          );
        });
  }

  void _handleReviewFreq() {
    for (PartyGuest partyGuest in mPartyGuests) {
      if (partyGuest.guestId.isNotEmpty && partyGuest.isApproved) {
        FirestoreHelper.pullUser(partyGuest.guestId).then((res) {
          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            User user = Fresh.freshUserMap(map, true);

            if (user.fcmToken.isNotEmpty) {
              if (user.lastReviewTime <
                  Timestamp.now().millisecondsSinceEpoch -
                      (2 * DateTimeUtils.millisecondsWeek)) {
                //send a notification
                Apis.sendUrlData(user.fcmToken, Apis.GoogleReviewFreq,
                    Constants.freqGoogleReview);
                Logx.ist(_TAG,
                    '${user.name} ${user.surname} has been notified for a freq google review 🤞');
                user = user.copyWith(
                    lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
                FirestoreHelper.pushUser(user);
              } else {
                Logx.ist(_TAG,
                    '${user.name} ${user.surname} has already google reviewed 🤞');
              }
            }
          }
        });
      }
    }
  }

  void _handleReviewBloc() {
    for (PartyGuest partyGuest in mPartyGuests) {
      if (partyGuest.guestId.isNotEmpty && partyGuest.isApproved) {
        FirestoreHelper.pullUser(partyGuest.guestId).then((res) {
          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            User user = Fresh.freshUserMap(map, true);

            if (user.fcmToken.isNotEmpty) {
              if (user.lastReviewTime <
                  Timestamp.now().millisecondsSinceEpoch -
                      (2 * DateTimeUtils.millisecondsWeek)) {
                Apis.sendUrlData(user.fcmToken, Apis.GoogleReviewBloc,
                    Constants.blocGoogleReview);
                Logx.ist(_TAG,
                    '${user.name} ${user.surname} has been notified for a bloc google review 🤞');

                user = user.copyWith(
                    lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
                FirestoreHelper.pushUser(user);
              } else {
                Logx.ist(_TAG,
                    '${user.name} ${user.surname} has already google reviewed 🤞');
              }
            }
          } else {
            Logx.est(_TAG,
                'user in guest list not found in db : ${partyGuest.guestId}');
          }
        });
      }
    }
  }

  _showDeleteAllGuestList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'delete all ${sPartyName == 'all' ? '' : sPartyName} guest lists',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'deleting ${mPartyGuests.length} guest list requests. are you sure you want to continue?'),
            actions: [
              TextButton(
                child: const Text('yes'),
                onPressed: () async {
                  for (PartyGuest partyGuest in mPartyGuests) {
                    FirestoreHelper.deletePartyGuest(partyGuest.id);
                  }
                  Logx.ist(_TAG,
                      'deleted all ${sPartyName == 'all' ? '' : sPartyName} guest list requests!');
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: const Text("no"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }

  _showMoveGuestList(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 100,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('select move to party'),
                  MultiSelectDialogField(
                    items: mParties
                        .map(
                            (e) => MultiSelectItem(e, '${e.name} ${e.chapter}'))
                        .toList(),
                    initialValue: sParties.map((e) => e).toList(),
                    listType: MultiSelectListType.CHIP,
                    buttonIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade700,
                    ),
                    title: const Text('pick a party'),
                    buttonText: const Text(
                      'select',
                      style: TextStyle(color: Constants.darkPrimary),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        width: 0.0,
                      ),
                    ),
                    searchable: true,
                    onConfirm: (values) {
                      sParties = values;

                      if (sParties.isNotEmpty) {
                        Party sParty = sParties.first;

                        for (PartyGuest pg in mPartyGuests) {
                          pg = pg.copyWith(partyId: sParty.id);
                          FirestoreHelper.pushPartyGuest(pg);

                          FirestoreHelper.pullUser(pg.guestId).then((res) {
                            if (res.docs.isNotEmpty) {
                              DocumentSnapshot document = res.docs[0];
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              final User user = Fresh.freshUserMap(data, false);

                              if (user.fcmToken.isNotEmpty) {
                                String title = sParty.name;
                                String message =
                                    '🥳 yayyy! your guest list for ${sParty.name} has been approved 🎉, see you and your gang soon! 😎🍾';

                                Apis.sendPushNotification(
                                    user.fcmToken, title, message);
                              }
                            } else {
                              Logx.em(
                                  _TAG, 'cant find user for id: ${pg.guestId}');
                            }
                          });
                        }

                        Logx.ist(_TAG,
                            'moved ${mPartyGuests.length} guests to ${sParty.name}');
                        Navigator.of(ctx).pop();
                      } else {
                        Logx.ist(_TAG, 'move to party needs to be selected');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showWhatsappRequestGoogleReviews(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'request google review from all ${sPartyName == 'all' ? '' : sPartyName} guest lists',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'whatsapp request for google review from ${mPartyGuests.length} guests. ask from all those who were approved?'),
            actions: [
              TextButton(
                child: const Text('review bloc'),
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  _handleGoogleReviewBlocWhatsapp();
                },
              ),
              TextButton(
                child: const Text('review freq'),
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  _handleGoogleReviewFreqWhatsapp();
                },
              ),
              TextButton(
                child: const Text("cancel"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }

  void _showWhatsappRequestAppReviews(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'request app review from all ${sPartyName == 'all' ? '' : sPartyName} guest lists',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'whatsapp request for app review from ${mPartyGuests.length} guests. create list?'),
            actions: [
              TextButton(
                child: const Text('confirm'),
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  _handleAppReviewWhatsapp();
                },
              ),
              TextButton(
                child: const Text("cancel"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }

  /** whatsapp notify **/
  void _handleGoogleReviewBlocWhatsapp() async {
    List<User> reviewUsers = [];

    for (int i = 0; i < mPartyGuests.length; i++) {
      PartyGuest partyGuest = mPartyGuests[i];
      if (partyGuest.guestId.isNotEmpty && partyGuest.isApproved) {
        await FirestoreHelper.pullUser(partyGuest.guestId).then((res) {
          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            User user = Fresh.freshUserMap(map, true);
            reviewUsers.add(user);

            if (i == mPartyGuests.length - 1) {
              if (reviewUsers.isNotEmpty) {
                _showWhatsappGoogleRequestList(
                    reviewUsers, Constants.blocGoogleReview);
              } else {
                Logx.ilt(_TAG, 'no users in list to review');
              }
            }
          } else {
            Logx.est(_TAG,
                'user in guest list not found in db : ${partyGuest.guestId}');
          }
        });
      } else {
        if (i == mPartyGuests.length - 1) {
          if (reviewUsers.isNotEmpty) {
            _showWhatsappGoogleRequestList(reviewUsers,
                Constants.blocGoogleReview);
          } else {
            Logx.ilt(_TAG, 'no users in list to review');
          }
        }
      }
    }
  }

  void _handleGoogleReviewFreqWhatsapp() async {
    List<User> reviewUsers = [];

    for (int i = 0; i < mPartyGuests.length; i++) {
      PartyGuest partyGuest = mPartyGuests[i];

      if (partyGuest.guestId.isNotEmpty && partyGuest.isApproved) {
        await FirestoreHelper.pullUser(partyGuest.guestId).then((res) {
          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            User user = Fresh.freshUserMap(map, true);
            reviewUsers.add(user);

            Logx.d(_TAG, 'index $i - ${mPartyGuests.length}');
            if (i == mPartyGuests.length - 1) {
              if (reviewUsers.isNotEmpty) {
                _showWhatsappGoogleRequestList(
                    reviewUsers, Constants.freqGoogleReview);
              } else {
                Logx.ilt(_TAG, 'no users in list to review');
              }
            }
          } else {
            Logx.est(_TAG,
                'user in guest list not found in db : ${partyGuest.guestId}');
          }
        });
      } else {
        if (i == mPartyGuests.length - 1) {
          if (reviewUsers.isNotEmpty) {
            _showWhatsappGoogleRequestList(
                reviewUsers, Constants.freqGoogleReview);
          } else {
            Logx.ilt(_TAG, 'no users in list to review');
          }
        }
      }
    }
  }

  void _showWhatsappGoogleRequestList(List<User> userList, String reviewLink) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('google review - users'),
            content: SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildWhatsappGoogleReviewItem(
                      userList[index], reviewLink);
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text("close"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }

  Widget _buildWhatsappGoogleReviewItem(User user, String reviewLink) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text('+${user.phoneNumber}'),
      trailing: ButtonWidget(
          text: 'send',
          onClicked: () {
            Logx.ist(_TAG, 'launching whatsapp...');

            String day = DateTimeUtils.getDay(sParty.startTime).toLowerCase();

            // Encode the phone number and message for the URL
            String message =
                'Hope you had a wonderful time on $day as a guest in our community! A Google review will help us improve and ensure every night at our bar is an unforgettable experience. Please review us at the following link, thank you 😊 \n\n$reviewLink';
            String url =
                'https://wa.me/+${user.phoneNumber}/?text=${Uri.encodeFull(message)}';
            Uri uri = Uri.parse(url);
            NetworkUtils.launchInBrowser(uri);

            user = user.copyWith(
                lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
            FirestoreHelper.pushUser(user);
          }),
    );
  }

  void _handleAppReviewWhatsapp() async {
    List<User> reviewUsers = [];

    for (int i = 0; i < mPartyGuests.length; i++) {
      PartyGuest partyGuest = mPartyGuests[i];
      if (partyGuest.guestId.isNotEmpty && partyGuest.isApproved) {
        await FirestoreHelper.pullUser(partyGuest.guestId).then((res) {
          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            User user = Fresh.freshUserMap(map, true);
            reviewUsers.add(user);

            if (i == mPartyGuests.length - 1) {
              if (reviewUsers.isNotEmpty) {
                _showWhatsappAppReviewList(reviewUsers);
              } else {
                Logx.ilt(_TAG, 'no users in list to review');
              }
            }
          } else {
            Logx.est(_TAG,
                'user in guest list not found in db : ${partyGuest.guestId}');
          }
        });
      }
    }
  }

  void _showWhatsappAppReviewList(List<User> users) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('app review - users'),
            content: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  User user = users[index];

                  String link = Constants.urlBlocPlayStore;
                  if (user.isIos) {
                    link = Constants.urlBlocAppStore;
                  }

                  return _buildWhatsappAppReviewItem(user, link);
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text("close"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }

  Widget _buildWhatsappAppReviewItem(User user, String reviewLink) {
    return ListTile(
      title: Text(user.name),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('+${user.phoneNumber}'),
          Checkbox(
            value: user.isAppReviewed,
            onChanged: (value) {
              Logx.ist(_TAG,
                  '${user.name} ${user.surname} has reviewed the app: $value');
              user = user.copyWith(isAppReviewed: value);
              FirestoreHelper.pushUser(user);
            },
          )
        ],
      ),
      trailing: ButtonWidget(
          text: 'send',
          onClicked: () {
            Logx.ist(_TAG, 'launching whatsapp...');

            // Encode the phone number and message for the URL
            String message =
                'Having a blast with the app? 🚀 Share the love and leave a review at the link! Your feedback keeps the fun coming for the entire community! 💖 \n\n$reviewLink';
            String url =
                'https://wa.me/+${user.phoneNumber}/?text=${Uri.encodeFull(message)}';
            Uri uri = Uri.parse(url);
            NetworkUtils.launchInBrowser(uri);

            user = user.copyWith(
                lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
            FirestoreHelper.pushUser(user);
          }),
    );
  }

  /** end whatsapp notify **/

  void _showRequestReviewFromGuests(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'request google review from all ${sPartyName == 'all' ? '' : sPartyName} guest lists',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'request for google review from ${mPartyGuests.length} guests. are you sure you want to ask from those who were approved?'),
            actions: [
              TextButton(
                child: const Text('review bloc'),
                onPressed: () async {
                  for (PartyGuest partyGuest in mPartyGuests) {
                    if (partyGuest.guestId.isNotEmpty &&
                        partyGuest.isApproved) {
                      FirestoreHelper.pullUser(partyGuest.guestId).then((res) {
                        if (res.docs.isNotEmpty) {
                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> map =
                              document.data()! as Map<String, dynamic>;
                          User user = Fresh.freshUserMap(map, true);

                          if (user.fcmToken.isNotEmpty) {
                            if (user.lastReviewTime <
                                Timestamp.now().millisecondsSinceEpoch -
                                    (2 * DateTimeUtils.millisecondsWeek)) {
                              Apis.sendUrlData(
                                  user.fcmToken,
                                  Apis.GoogleReviewBloc,
                                  Constants.blocGoogleReview);
                              Logx.ist(_TAG,
                                  '${user.name} ${user.surname} has been notified for a bloc google review 🤞');

                              user = user.copyWith(
                                  lastReviewTime:
                                      Timestamp.now().millisecondsSinceEpoch);
                              FirestoreHelper.pushUser(user);
                            } else {
                              Logx.ist(_TAG,
                                  '${user.name} ${user.surname} has already google reviewed 🤞');
                            }
                          }
                        } else {
                          Logx.est(_TAG,
                              'user in guest list not found in db : ${partyGuest.guestId}');
                        }
                      });
                    }
                  }

                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: const Text('review freq'),
                onPressed: () async {
                  for (PartyGuest partyGuest in mPartyGuests) {
                    if (partyGuest.guestId.isNotEmpty &&
                        partyGuest.isApproved) {
                      FirestoreHelper.pullUser(partyGuest.guestId).then((res) {
                        if (res.docs.isNotEmpty) {
                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> map =
                              document.data()! as Map<String, dynamic>;
                          User user = Fresh.freshUserMap(map, true);

                          if (user.fcmToken.isNotEmpty) {
                            if (user.lastReviewTime <
                                Timestamp.now().millisecondsSinceEpoch -
                                    (2 * DateTimeUtils.millisecondsWeek)) {
                              //send a notification
                              Apis.sendUrlData(
                                  user.fcmToken,
                                  Apis.GoogleReviewFreq,
                                  Constants.freqGoogleReview);
                              Logx.ist(_TAG,
                                  '${user.name} ${user.surname} has been notified for a freq google review 🤞');

                              user = user.copyWith(
                                  lastReviewTime:
                                      Timestamp.now().millisecondsSinceEpoch);
                              FirestoreHelper.pushUser(user);
                            } else {
                              Logx.ist(_TAG,
                                  '${user.name} ${user.surname} has already google reviewed 🤞');
                            }
                          }
                        } else {
                          Logx.est(_TAG,
                              'user in guest list not found in db : ${partyGuest.guestId}');
                        }
                      });
                    }
                  }

                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: const Text("cancel"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }

  void _showUnapproveAllGuestList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'unapprove all ${sPartyName == 'all' ? '' : sPartyName} guest lists',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'unapprove ${mPartyGuests.length} guests for the party. are you sure you want to continue?'),
            actions: [
              TextButton(
                child: const Text('confirm'),
                onPressed: () async {
                  for (PartyGuest partyGuest in mPartyGuests) {
                    partyGuest = partyGuest.copyWith(isApproved: false);
                    FirestoreHelper.pushPartyGuest(partyGuest);
                  }
                  Logx.ist(_TAG, 'unapproved all guests');

                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: const Text("cancel"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }

  void _cleanNonAppUserGuests(BuildContext context) {
    for (PartyGuest guest in mPartyGuests) {
      if (guest.guestStatus != 'promoter') {
        FirestoreHelper.pullUser(guest.guestId).then((res) {
          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            final User user = Fresh.freshUserMap(data, false);

            if (!user.isAppUser) {
              FirestoreHelper.deletePartyGuest(guest.id);
              Logx.ist(
                  _TAG, '${guest.name} ${guest.surname} guest list is deleted');
            } else {
              Logx.ist(_TAG, '${guest.name} ${guest.surname} is an app user');
            }
          } else {
            Logx.est(_TAG,
                '${guest.name} ${guest.surname} account not found. id: ${guest.guestId}');
          }
        });
      }
    }
  }
}
