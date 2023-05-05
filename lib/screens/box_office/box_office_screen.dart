import 'package:bloc/main.dart';
import 'package:bloc/screens/user/reservation_add_edit_screen.dart';
import 'package:bloc/utils/scan_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/reservation.dart';
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/box_office/box_office_item.dart';
import '../../widgets/parties/party_guest_list_banner.dart';
import '../../widgets/reservations/reservation_banner.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../promoter/promoter_guests_screen.dart';

class BoxOfficeScreen extends StatefulWidget {
  @override
  State<BoxOfficeScreen> createState() => _BoxOfficeScreenState();
}

class _BoxOfficeScreenState extends State<BoxOfficeScreen> {
  static const String _TAG = 'BoxOfficeScreen';

  List<Party> mParties = [];
  List<Party> mGuestListParties = [];
  var _isPartiesLoading = true;

  late List<String> mOptions;
  String sOption = '';

  @override
  void initState() {
    mOptions = ['guest list', 'reservations'];
    sOption = mOptions.first;

    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    FirestoreHelper.pullPartiesByEndTime(timeNow, true).then((res) {
      Logx.i(_TAG, "successfully pulled in parties");

      if (res.docs.isNotEmpty) {
        List<Party> parties = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          parties.add(party);
          if (party.isGuestListActive) {
            mGuestListParties.add(party);
          }

          setState(() {
            mParties = parties;
            _isPartiesLoading = false;
          });
        }
      } else {
        Logx.i(_TAG, 'no parties found!');
        setState(() {
          _isPartiesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = UserPreferences.myUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('bloc | box office'),
      ),
      floatingActionButton:
          (user.clearanceLevel >= Constants.PROMOTER_LEVEL && !kIsWeb)
              ? FloatingActionButton(
                  onPressed: () {
                    ScanUtils.scanCode(context);
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  tooltip: 'scan code',
                  elevation: 5,
                  splashColor: Colors.grey,
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Theme.of(context).primaryColorDark,
                    size: 29,
                  ),
                )
              : const SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartiesLoading
        ? const LoadingWidget()
        : Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                displayBoxOfficeOptions(context),
                const Divider(),
                UserPreferences.myUser.clearanceLevel >=
                        Constants.PROMOTER_LEVEL
                    ? switchPromoterOptions(context)
                    : switchUserOptions(context)
              ],
            ),
          );
  }

  switchPromoterOptions(BuildContext context) {
    if (sOption == 'guest list') {
      return displayGuestListParties(context);
    } else if (sOption == 'reservations') {
      return buildReservations(context);
    } else {
      // unsupported
    }
  }

  switchUserOptions(BuildContext context) {
    if (sOption == 'guest list') {
      return buildUserPartyGuestList(context);
    } else if (sOption == 'reservations') {
      return buildUserReservations(context);
    } else {
      // unsupported
    }
  }

  displayBoxOfficeOptions(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 15,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 3,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                    Logx.i(_TAG, sOption + ' at box office is selected');
                  });
                });
          }),
    );
  }

  buildReservations(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getReservations(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (snapshot.hasData) {
          List<Reservation> reservations = [];
          if (snapshot.data!.docs.isEmpty) {
            return const Expanded(
                child: Center(child: Text('no reservations found!')));
          } else {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map =
                  document.data()! as Map<String, dynamic>;
              final Reservation reservation =
                  Fresh.freshReservationMap(map, false);
              reservations.add(reservation);

              if (i == snapshot.data!.docs.length - 1) {
                return displayReservations(context, reservations);
              }
            }
          }
        } else {
          return const Expanded(
              child: Center(child: Text('no reservations found!')));
        }
        return const LoadingWidget();
      },
    );
  }

  buildUserReservations(BuildContext context) {
    Logx.i(_TAG, 'searching for reservations for user ${UserPreferences.myUser.id}');

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getReservationsByUser(UserPreferences.myUser.id),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasData) {
          List<Reservation> reservations = [];
          if (snapshot.data!.docs.isEmpty) {
            return const Expanded(
                child: Center(child: Text('no reservations found!')));
          } else {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map =
              document.data()! as Map<String, dynamic>;
              final Reservation reservation =
              Fresh.freshReservationMap(map, false);
              reservations.add(reservation);

              if (i == snapshot.data!.docs.length - 1) {
                return displayReservations(context, reservations);
              }
            }
          }
        } else {
          return const Expanded(
              child: Center(child: Text('no reservations found!')));
        }
        return const LoadingWidget();
      },
    );
  }

  buildUserPartyGuestList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirestoreHelper.getPartyGuestListByUser(UserPreferences.getUser().id),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasData) {
          List<PartyGuest> partyGuestRequests = [];
          if (snapshot.data!.docs.isEmpty) {
            return const Expanded(
                child: Center(child: Text('no guest list requests found!')));
          } else {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map =
                  document.data()! as Map<String, dynamic>;
              final PartyGuest partyGuest =
                  Fresh.freshPartyGuestMap(map, false);
              partyGuestRequests.add(partyGuest);

              if (i == snapshot.data!.docs.length - 1) {
                return _displayPartyGuestListRequests(
                    context, partyGuestRequests);
              }
            }
          }
        } else {
          return const Expanded(
              child: Center(child: Text('no guest list requests found!')));
        }
        return const LoadingWidget();
      },
    );
  }

  _displayPartyGuestListRequests(
      BuildContext context, List<PartyGuest> requests) {
    return Expanded(
      child: ListView.builder(
        itemCount: requests.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          PartyGuest sPartyGuest = requests[index];
          Party sParty = Dummy.getDummyParty('');

          bool foundParty = false;
          for (Party party in mParties) {
            if (party.id == sPartyGuest.partyId) {
              sParty = party;
              foundParty = true;
              break;
            }
          }

          if (!foundParty) {
            // the party is ended, house cleaning logic will be needed
            return const SizedBox();
          } else {
            return BoxOfficeItem(
              partyGuest: sPartyGuest,
              party: sParty,
              isClickable: true,
            );
          }
        },
      ),
    );
  }

  displayGuestListParties(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: mGuestListParties.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: PartyGuestListBanner(
                  party: mGuestListParties[index],
                ),
                onTap: () {
                  Party _sParty = mGuestListParties[index];
                  Logx.i(_TAG, _sParty.name + ' is selected');

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => PromoterGuestsScreen(party: _sParty)));
                });
          }),
    );
  }

  displayReservations(BuildContext context, List<Reservation> reservations) {
    return Expanded(
      child: ListView.builder(
          itemCount: reservations.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ReservationBanner(
                  reservation: reservations[index],
                  isPromoter: UserPreferences.myUser.clearanceLevel >= Constants.PROMOTER_LEVEL,
                ),
                onTap: () {
                  Reservation _sReservation = reservations[index];
                  Logx.i(
                      _TAG, _sReservation.name + '\'s reservation is selected');

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ReservationAddEditScreen(
                            reservation: _sReservation,
                            task: 'edit',
                          )));
                });
          }),
    );
  }
}
