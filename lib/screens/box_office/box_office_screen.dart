import 'package:bloc/main.dart';
import 'package:bloc/screens/user/reservation_add_edit_screen.dart';
import 'package:bloc/utils/scan_utils.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/challenge.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/reservation.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/box_office/box_office_guest_list_item.dart';
import '../../widgets/parties/party_guest_list_banner.dart';
import '../../widgets/reservations/reservation_banner.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../promoter/promoter_guests_screen.dart';

class BoxOfficeScreen extends StatefulWidget {
  const BoxOfficeScreen({super.key});

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

  List<Challenge> challenges = [];
  bool isChallengesLoading = true;

  bool showPromoterView = false;

  @override
  void initState() {
    showPromoterView = UserPreferences.myUser.clearanceLevel >= Constants.PROMOTER_LEVEL;

    mOptions = ['guest list', 'tickets'];
    sOption = mOptions.first;

    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    FirestoreHelper.pullPartiesByEndTime(timeNow, true).then((res) {
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

    FirestoreHelper.pullChallenges().then((res) {
      if (res.docs.isNotEmpty) {
        Logx.i(_TAG, "successfully pulled in all challenges");

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Challenge challenge = Fresh.freshChallengeMap(data, false);
          challenges.add(challenge);
        }

        setState(() {
          isChallengesLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no challenges found, setting default');
        setState(() {
          isChallengesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,
        title: AppBarTitle(
          title: 'box office',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (kIsWeb) {
              GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      backgroundColor: Constants.background,
      floatingActionButton:
          (showPromoterView && !kIsWeb)
              ? FloatingActionButton(
                  onPressed: () {
                    ScanUtils.scanCode(context);
                  },
                  backgroundColor: Constants.primary,
                  tooltip: 'scan code',
                  elevation: 5,
                  splashColor: Colors.grey,
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Constants.darkPrimary,
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
                showPromoterView?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('switch view', style: TextStyle(fontSize:18, color: Constants.primary),),
                          const Divider(),
                          ButtonWidget(text: 'promoter -> user',
                          onClicked: () {
                            setState(() {
                              showPromoterView = !showPromoterView;
                              Logx.ist(_TAG, 'promoter view $showPromoterView');
                            });
                          },)
                        ],
                      ),
                    )
                    : const SizedBox(),
                _showBoxOfficeOptions(context),
                const Divider(),
                showPromoterView
                    ? switchPromoterOptions(context)
                    : switchUserOptions(context)
              ],
            ),
          );
  }

  switchPromoterOptions(BuildContext context  ) {
    if (sOption == 'guest list') {
      return displayGuestListParties(context);
    } else if (sOption == 'tickets') {
      return buildTickets(context);
    } else {
      // unsupported
    }
  }

  switchUserOptions(BuildContext context) {
    if (sOption == 'guest list') {
      return buildUserPartyGuestList(context);
    } else if (sOption == 'tickets') {
      return buildUserTickets(context);
    } else {
      // unsupported
    }
  }

  _showBoxOfficeOptions(BuildContext context) {
    double containerHeight = mq.height * 0.2;

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
                  width: MediaQuery.of(context).size.width / 2,
                  color: Constants.primary,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                    Logx.i(_TAG, '$sOption at box office is selected');
                  });
                });
          }),
    );
  }

  buildTickets(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getReservations(),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:{
          if (snapshot.hasData) {
            List<Reservation> reservations = [];
            if (snapshot.data!.docs.isEmpty) {
              return showReserveTableButton();
            } else {
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> map =
                document.data()! as Map<String, dynamic>;
                final Reservation reservation =
                Fresh.freshReservationMap(map, false);
                reservations.add(reservation);
              }
              return displayReservations(context, reservations);
            }
          } else {
            return showReserveTableButton();
          }
        }
        }},
    );
  }

  buildUserTickets(BuildContext context) {
    Logx.i(_TAG,
        'searching for tickets for user ${UserPreferences.myUser.id}');

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getReservationsByUser(UserPreferences.myUser.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
          if (snapshot.hasData) {
            List<Reservation> reservations = [];
            if (snapshot.data!.docs.isEmpty) {
              return showReserveTableButton();
            } else {
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> map =
                document.data()! as Map<String, dynamic>;
                final Reservation reservation =
                Fresh.freshReservationMap(map, false);
                reservations.add(reservation);
              }
              return displayReservations(context, reservations);
            }
          } else {
            return showReserveTableButton();
          }
        }
        },
    );
  }

  buildUserPartyGuestList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirestoreHelper.getPartyGuestListByUser(UserPreferences.getUser().id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:{
          if (snapshot.hasData) {
            List<PartyGuest> partyGuestRequests = [];
            if (snapshot.data!.docs.isEmpty) {
              return showPartiesButton();
            } else {
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
                final PartyGuest partyGuest = Fresh.freshPartyGuestMap(map, false);
                partyGuestRequests.add(partyGuest);
              }
              return _showGuestListRequests(context, partyGuestRequests);
            }
          } else {
            return showPartiesButton();
          }
          }
        }
        },
    );
  }

  _showGuestListRequests(
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
            return BoxOfficeGuestListItem(
              partyGuest: sPartyGuest,
              party: sParty,
              isClickable: true,
              challenges: challenges,
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
                  Party sParty = mGuestListParties[index];

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => PromoterGuestsScreen(party: sParty)));
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
                  isPromoter: UserPreferences.myUser.clearanceLevel >=
                      Constants.PROMOTER_LEVEL,
                ),
                onTap: () {
                  Reservation _sReservation = reservations[index];
                  Logx.i(
                      _TAG, '${_sReservation.name}\'s reservation is selected');

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ReservationAddEditScreen(
                            reservation: _sReservation,
                            task: 'edit',
                          )));
                });
          }),
    );
  }

  showPartiesButton() {
    return Expanded(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '⚡ Warning: FOMO alert! Our party radar is buzzing, and it seems like you\'re missing out on the hottest 🔥🔥🔥 gathering in town. Hurry up, grab your spot, and prepare for an unforgettable experience! 🪩'
                .toLowerCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'click to check out our parties!'.toLowerCase(),
            style: const TextStyle(fontSize: 16, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          ButtonWidget(
            text: 'parties',
            height: 50,
            onClicked: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      )),
    );
  }

  showReserveTableButton() {
    return Expanded(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Family and food, the perfect recipe for love! Reserve a table, lay a foundation of laughter and good food, and watch your beautiful memories take shape! 💛'
                .toLowerCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'click to reserve your table!'.toLowerCase(),
            style: const TextStyle(fontSize: 16, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          ButtonWidget(
            text: 'reserve',
            height: 50,
            onClicked: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => ReservationAddEditScreen(
                        reservation: Dummy.getDummyReservation(''),
                        task: 'add')),
              );
            },
          ),
        ],
      )),
    );
  }

}
