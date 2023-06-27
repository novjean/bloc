import 'package:bloc/main.dart';
import 'package:bloc/screens/user/reservation_add_edit_screen.dart';
import 'package:bloc/utils/scan_utils.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/celebration.dart';
import '../../db/entity/challenge.dart';
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
import '../../widgets/celebrations/celebration_banner.dart';
import '../../widgets/parties/party_guest_list_banner.dart';
import '../../widgets/reservations/reservation_banner.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../promoter/promoter_guests_screen.dart';
import '../user/celebration_add_edit_screen.dart';

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

  List<Challenge> challenges = [];
  bool isChallengesLoading = true;

  @override
  void initState() {
    mOptions = ['guest list', 'reservations', 'celebrations'];
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
    User user = UserPreferences.myUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'box office',)
      ),
      backgroundColor: Constants.background,
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
    }  else if (sOption == 'celebrations') {
      return buildCelebrations(context);
    }
    else {
      // unsupported
    }
  }

  switchUserOptions(BuildContext context) {
    if (sOption == 'guest list') {
      return buildUserPartyGuestList(context);
    } else if (sOption == 'reservations') {
      return buildUserReservations(context);
    }  else if (sOption == 'celebrations') {
      return buildUserCelebrations(context);
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
                    Logx.i(_TAG, '$sOption at box office is selected');
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
            return showReserveTableButton();
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
          return showReserveTableButton();
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
            return showReserveTableButton();
          } else {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
              final Reservation reservation = Fresh.freshReservationMap(map, false);
              reservations.add(reservation);

              if (i == snapshot.data!.docs.length - 1) {
                return displayReservations(context, reservations);
              }
            }
          }
        } else {
          return showReserveTableButton();
        }
        return const LoadingWidget();
      },
    );
  }

  buildCelebrations(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getCelebrations(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (snapshot.hasData) {
          List<Celebration> celebrations = [];
          if (snapshot.data!.docs.isEmpty) {
            return showCelebrateButton();
          } else {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map =
              document.data()! as Map<String, dynamic>;
              final Celebration celebration =
              Fresh.freshCelebrationMap(map, false);
              celebrations.add(celebration);

              if (i == snapshot.data!.docs.length - 1) {
                return displayCelebrations(context, celebrations);
              }
            }
          }
        } else {
          return showCelebrateButton();
        }
        return const LoadingWidget();
      },
    );
  }

  buildUserCelebrations(BuildContext context) {
    Logx.i(_TAG, 'searching for celebrations for user ${UserPreferences.myUser.id}');

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getCelebrationsByUser(UserPreferences.myUser.id),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasData) {
          List<Celebration> celebrations = [];
          if (snapshot.data!.docs.isEmpty) {
            return showCelebrateButton();
          } else {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
              final Celebration celebration = Fresh.freshCelebrationMap(map, false);
              celebrations.add(celebration);

              if (i == snapshot.data!.docs.length - 1) {
                return displayCelebrations(context, celebrations);
              }
            }
          }
        } else {
          return showCelebrateButton();
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
            return showPartiesButton();
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
          return showPartiesButton();
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
                  Party _sParty = mGuestListParties[index];
                  Logx.i(_TAG, '${_sParty.name} is selected');

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

  displayCelebrations(BuildContext context, List<Celebration> celebrations) {
    return Expanded(
      child: ListView.builder(
          itemCount: celebrations.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: CelebrationBanner(
                  celebration: celebrations[index],
                  isPromoter: UserPreferences.myUser.clearanceLevel >= Constants.PROMOTER_LEVEL,
                ),
                onTap: () {
                  Celebration _sCelebration = celebrations[index];
                  Logx.i(
                      _TAG, _sCelebration.name + '\'s celebration is selected');

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => CelebrationAddEditScreen(
                        celebration: _sCelebration,
                        task: 'edit',
                      )));
                });
          }),
    );
  }

  showPartiesButton() {
    return Expanded(
      child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '⚡ Warning: FOMO alert! Our party radar is buzzing, and it seems like you\'re missing out on the hottest 🔥🔥🔥 gathering in town. Hurry up, grab your spot, and prepare for an unforgettable experience! 🪩'.toLowerCase(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'click to check out our parties!'.toLowerCase(),
            style: TextStyle(fontSize: 16, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          ButtonWidget(text: 'parties', height: 50, onClicked: () {
            Navigator.of(context).pop();
          },),
        ],
      )),
    );
  }

  showReserveTableButton() {
    return Expanded(
      child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Family and food, the perfect recipe for love! Reserve a table, lay a foundation of laughter and good food, and watch your beautiful memories take shape! 💛'.toLowerCase(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'click to reserve your table!'.toLowerCase(),
            style: TextStyle(fontSize: 16, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          ButtonWidget(text: 'reserve', height: 50, onClicked: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) =>
                      ReservationAddEditScreen(
                          reservation:
                          Dummy.getDummyReservation(
                             ''),
                          task: 'add')),
            );
          },),
        ],
      )),
    );
  }

  showCelebrateButton() {
    return Expanded(
      child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Step into a world of celebration and sophistication at our cocktail rooftop bar. Whether it\'s your anniversary, birthday, or a corporate event, our venue is tailor-made to accommodate large groups, ensuring a night to remember. Come and indulge in the magic of elevated celebrations! 🍾'.toLowerCase(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'click to celebrate with us!'.toLowerCase(),
            style: TextStyle(fontSize: 16, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          ButtonWidget(text: 'celebrate', height: 50, onClicked: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) =>
                      CelebrationAddEditScreen(
                          celebration:
                          Dummy.getDummyCelebration(
                              ''),
                          task: 'add')),
            );
          },),
        ],
      )),
    );
  }

}
