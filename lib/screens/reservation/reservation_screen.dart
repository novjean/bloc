import 'package:bloc/main.dart';
import 'package:bloc/screens/user/reservation_add_edit_screen.dart';
import 'package:bloc/utils/scan_utils.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/celebration.dart';
import '../../db/entity/challenge.dart';
import '../../db/entity/reservation.dart';
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/celebrations/celebration_banner.dart';
import '../../widgets/reservations/reservation_banner.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../user/celebration_add_edit_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  static const String _TAG = 'ReservationScreen';

  late List<String> mOptions;
  String sOption = '';

  List<Challenge> challenges = [];
  bool isChallengesLoading = true;

  bool showPromoterView = false;

  @override
  void initState() {
    showPromoterView =
        UserPreferences.myUser.clearanceLevel >= Constants.PROMOTER_LEVEL;

    mOptions = ['reservations', 'celebrations'];
    sOption = mOptions.first;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = UserPreferences.myUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,
        title: AppBarTitle(
          title: 'reservations',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            if (kIsWeb) {
              GoRouter.of(context).pushReplacementNamed(RouteConstants.landingRouteName);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      backgroundColor: Constants.background,
      floatingActionButton: (showPromoterView && !kIsWeb)
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          showPromoterView
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'switch',
                  style: TextStyle(
                      fontSize: 18, color: Constants.primary),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
                  child: ButtonWidget(
                    text: 'user view',
                    onClicked: () {
                      setState(() {
                        showPromoterView = !showPromoterView;
                      });
                    },
                  ),
                )
              ],
            ),
          )
              : const SizedBox(),
          _showBoxOfficeOptions(context),
          const Divider(color: Constants.darkPrimary,),
          showPromoterView
              ? switchPromoterOptions(context)
              : switchUserOptions(context)
        ],
      ),
    );
  }

  switchPromoterOptions(BuildContext context) {
    if (sOption == 'reservations') {
      return buildReservations(context);
    } else if (sOption == 'celebrations') {
      return buildCelebrations(context);
    } else {
      // unsupported
    }
  }

  switchUserOptions(BuildContext context) {
    if (sOption == 'reservations') {
      return buildUserReservations(context);
    } else if (sOption == 'celebrations') {
      return buildUserCelebrations(context);
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
                  });
                });
          }),
    );
  }

  buildReservations(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getReservations(),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
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
        }
      },
    );
  }

  buildUserReservations(BuildContext context) {
    Logx.i(_TAG, 'buildUserReservations user ${UserPreferences.myUser.id}');

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getReservationsByUser(UserPreferences.myUser.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
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
        }
      },
    );
  }

  buildCelebrations(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getCelebrations(),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
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
                  }
                  return displayCelebrations(context, celebrations);
                }
              } else {
                return showCelebrateButton();
              }
            }
        }
      },
    );
  }

  buildUserCelebrations(BuildContext context) {
    Logx.i(_TAG,
        'searching for celebrations for user ${UserPreferences.myUser.id}');

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getCelebrationsByUser(UserPreferences.myUser.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
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
                  }
                  return displayCelebrations(context, celebrations);
                }
              } else {
                return showCelebrateButton();
              }
            }
        }
      },
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
                  Reservation sReservation = reservations[index];
                  Logx.i(
                      _TAG, '${sReservation.name}\'s reservation is selected');

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ReservationAddEditScreen(
                            reservation: sReservation,
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
                  isPromoter: UserPreferences.myUser.clearanceLevel >=
                      Constants.PROMOTER_LEVEL,
                ),
                onTap: () {
                  Celebration sCelebration = celebrations[index];
                  Logx.i(
                      _TAG, '${sCelebration.name}\'s celebration is selected');

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => CelebrationAddEditScreen(
                            celebration: sCelebration,
                            task: 'edit',
                          )));
                });
          }),
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

  showCelebrateButton() {
    return Expanded(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Step into a world of celebration and sophistication at our cocktail rooftop bar. Whether it\'s your anniversary, birthday, or a corporate event, our venue is tailor-made to accommodate large groups, ensuring a night to remember. Come and indulge in the magic of elevated celebrations! 🍾'
                .toLowerCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'click to celebrate with us!'.toLowerCase(),
            style: const TextStyle(fontSize: 16, color: Constants.primary),
          ),
          const SizedBox(height: 16),
          ButtonWidget(
            text: 'celebrate',
            height: 50,
            onClicked: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => CelebrationAddEditScreen(
                        celebration:
                            Dummy.getDummyCelebration(Constants.blocServiceId),
                        task: 'add')),
              );
            },
          ),
        ],
      )),
    );
  }
}
