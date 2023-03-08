import 'package:bloc/db/entity/user.dart';
import 'package:bloc/main.dart';
import 'package:bloc/screens/user/book_table_screen.dart';
import 'package:bloc/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/entity/bloc.dart';
import '../db/entity/guest_wifi.dart';
import '../db/entity/party.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/token_monitor.dart';
import '../widgets/home/bloc_slide_item.dart';
import '../widgets/parties/party_home_item.dart';
import '../widgets/search_card.dart';
import '../widgets/store_badge_item.dart';
import '../widgets/ui/button_widget.dart';
import '../widgets/ui/dark_button_widget.dart';
import '../widgets/ui/toaster.dart';
import 'experimental/trending.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isUserLoggedIn = false;

  late List<Bloc> mBlocs;
  var _isBlocsLoading = true;

  Party mUpcomingParty = Dummy.getDummyParty('');
  var _isUpcomingPartyLoading = true;

  GuestWifi mGuestWifi = Dummy.getDummyWifi(Constants.blocServiceId);
  var _isGuestWifiDetailsLoading = true;

  @override
  void initState() {
    super.initState();

    _isUserLoggedIn =
        UserPreferences.myUser.phoneNumber == 911234567890 ? false : true;

    FirestoreHelper.pullBlocs().then((res) {
      print("successfully pulled in blocs");

      if (res.docs.isNotEmpty) {
        // found blocs
        List<Bloc> blocs = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Bloc bloc = Bloc.fromMap(data);
          blocs.add(bloc);

          setState(() {
            mBlocs = blocs;
            _isBlocsLoading = false;
          });
        }
      } else {
        print('no blocs found!!!');
        //todo: need to re-attempt or check internet connection
        setState(() {
          _isBlocsLoading = false;
        });
      }
    }).catchError((err) {
      print('error ' + err);
    });

    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    FirestoreHelper.pullUpcomingPartyByEndTime(timeNow).then((res) {
      print("successfully pulled in parties.");

      if (res.docs.isNotEmpty) {
        try {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Party.fromMap(data);

          setState(() {
            mUpcomingParty = party;
            _isUpcomingPartyLoading = false;
          });
        } catch (err) {
          print('error: ' + err.toString());
        }
      } else {
        print('no upcoming party found!');

        //should not display the events module
      }
    });

    FirestoreHelper.pullGuestWifi(Constants.blocServiceId).then((res) {
      print("successfully pulled in guest wifi");

      if (res.docs.isNotEmpty) {
        try {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final GuestWifi wifi = GuestWifi.fromMap(data);

          setState(() {
            mGuestWifi = wifi;
            _isGuestWifiDetailsLoading = false;
          });
        } catch (err) {
          print('error: ' + err.toString());
        }
      } else {
        print('no guest wifi found!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            // buildSearchBar(context),
            const SizedBox(height: 1.0),
            _isBlocsLoading
                ? const SizedBox(height: 0)
                : _displayBlocs(context),
            _isUpcomingPartyLoading
                ? const SizedBox(height: 0)
                : _displayUpcomingParty(context),
            const SizedBox(height: 10.0),
            UserPreferences.isUserLoggedIn()
                ? _isGuestWifiDetailsLoading
                    ? const SizedBox()
                    : buildWifi(context)
                : const SizedBox(),
            const SizedBox(height: 10.0),
            kIsWeb ? StoreBadgeItem() : const SizedBox(),

            // buildBookTableRow(context),
            // buildRestaurantRow('Trending Restaurants', context),
            // SizedBox(height: 10.0),
            // buildSuperstarsTitleRow('Superstars', context),
            // SizedBox(height: 10.0),
            // buildSuperstarsList(context),
            !kIsWeb
                ? TokenMonitor((token) {
                    if (token != null) {
                      User user = UserPreferences.myUser;
                      if (user.id.isNotEmpty) {
                        if (UserPreferences.myUser.fcmToken.isEmpty ||
                            UserPreferences.myUser.fcmToken != token) {
                          UserPreferences.setUserFcmToken(token);
                          FirestoreHelper.updateUserFcmToken(
                              UserPreferences.myUser.id, token);
                        } else {
                          print('fcm token has not changed: ' + token);
                        }
                      }
                    }
                    return const Spacer();
                  })
                : const SizedBox(height: 0),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  _displayBlocs(context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      height: 390,
      child: ListView.builder(
          itemCount: mBlocs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            Bloc bloc = mBlocs[index];

            return GestureDetector(
              child:
                  // BlocSlideItem(
                  //   bloc: bloc,
                  //   rating: '5',
                  // )
                  BlocSlideItem(
                bloc: bloc,
              ),
            );
          }),
    );
  }

  _displayUpcomingParty(context) {
    return Container(
      color: Theme.of(context).primaryColorLight,
      height: 190,
      child: GestureDetector(
        child: PartyHomeItem(party: mUpcomingParty),
        onTap: () {
          Party _sParty = mUpcomingParty;
          print(_sParty.name + ' is selected.');
        },
      ),
    );
  }

  buildWifi(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(),
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 10, left: 10.0, right: 0.0),
            child: Text(
              "connect",
              style: TextStyle(
                fontSize: 24.0,
                color: Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.left,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    'wifi: ${mGuestWifi.name.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
                flex: 1,
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: DarkButtonWidget(
                    text: 'copy password',
                    onClicked: () {
                      Clipboard.setData(
                              ClipboardData(text: mGuestWifi.password))
                          .then((value) {
                        //only if ->
                        Toaster.shortToast('wifi password copied');
                      });
                    },
                  ),
                ),
                flex: 1,
              )
            ],
          ),
          // showCopyPasswordDialog(context),
        ],
      ),
    );
  }

  displayStoreBadge(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(0)),
              image: DecorationImage(
                image: AssetImage('assets/images/google-play-badge.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(0)),
              image: DecorationImage(
                image: AssetImage('assets/images/google-play-badge.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /** Optional **/
  buildSuperstarsTitleRow(String category, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "$category",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          // FlatButton(
          //   child: Text(
          //     "See all",
          //     style: TextStyle(
          //       color: Theme.of(context).accentColor,
          //     ),
          //   ),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (BuildContext context) {
          //todo: need to navigate to show list of users or friends
          //           return Categories();
          //         },
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  buildSuperstarsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getUsers(Constants.MANAGER_LEVEL),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('loading users...');
          return SizedBox();
        }

        List<User> _users = [];
        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final User user = User.fromMap(data);
          if (user.imageUrl.isNotEmpty) {
            _users.add(user);
          }

          if (i == snapshot.data!.docs.length - 1) {
            return _displaySuperstarsList(context, _users);
          }
        }
        return Text('Loading users...');
      },
    );
  }

  _displaySuperstarsList(BuildContext context, List<User> users) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      height: 50.0,
      child: ListView.builder(
        primary: false,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          String img = users[index].imageUrl;

          return Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                img,
              ),
              radius: 25.0,
            ),
          );
        },
      ),
    );
  }

  /** Non functional **/
  buildBookTableRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // NumbersWidget(),
        ButtonWidget(
            text: 'book a table',
            onClicked: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => BookTableScreen(
                          blocs: mBlocs,
                        )),
              );
            }),
      ],
    );
  }

  /** Unimplemented **/
  buildRestaurantRow(String restaurant, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "$restaurant",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        ElevatedButton(
          child: Text(
            "See all (9)",
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return Trending();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  buildSearchBar(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 0), child: SearchCard());
  }
}
