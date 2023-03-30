import 'package:bloc/db/entity/user.dart';
import 'package:bloc/main.dart';
import 'package:bloc/screens/user/book_table_screen.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/entity/bloc.dart';
import '../db/entity/guest_wifi.dart';
import '../db/entity/party.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../utils/logx.dart';
import '../widgets/home/bloc_slide_item.dart';
import '../widgets/parties/party_banner.dart';
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
  static const String _TAG = 'HomeScreen';

  List<Bloc> mBlocs = [];
  var _isBlocsLoading = true;

  Party mUpcomingParty = Dummy.getDummyParty('');
  var _isUpcomingPartyLoading = true;

  GuestWifi mGuestWifi = Dummy.getDummyWifi(Constants.blocServiceId);
  var _isGuestWifiDetailsLoading = true;

  @override
  void initState() {
    super.initState();

    UserPreferences.myUser.clearanceLevel >= Constants.PROMOTER_LEVEL
        ? FirestoreHelper.pullBlocsPromoter().then((res) {
            Logx.i(_TAG, "successfully pulled in blocs for promoter");

            if (res.docs.isNotEmpty) {
              // found blocs
              List<Bloc> blocs = [];
              for (int i = 0; i < res.docs.length; i++) {
                DocumentSnapshot document = res.docs[i];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                final Bloc bloc = Bloc.fromMap(data);
                blocs.add(bloc);

                setState(() {
                  mBlocs = blocs;
                  _isBlocsLoading = false;
                });
              }
            } else {
              Logx.em(_TAG,' no blocs found!!!');
              //todo: need to re-attempt or check internet connection
              setState(() {
                _isBlocsLoading = false;
              });
            }
          }).catchError((e,s) {
            Logx.ex(_TAG, 'error loading blocs', e, s);
            setState(() {
              _isBlocsLoading = false;
            });
          })
        : FirestoreHelper.pullBlocs().then((res) {
            Logx.i(_TAG, "successfully pulled in blocs");

            if (res.docs.isNotEmpty) {
              // found blocs
              List<Bloc> blocs = [];
              for (int i = 0; i < res.docs.length; i++) {
                DocumentSnapshot document = res.docs[i];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                final Bloc bloc = Bloc.fromMap(data);
                blocs.add(bloc);

                setState(() {
                  mBlocs = blocs;
                  _isBlocsLoading = false;
                });
              }
            } else {
              Logx.em(_TAG, 'no blocs found!!!');
              //todo: need to re-attempt or check internet connection
              setState(() {
                mBlocs = [];
                _isBlocsLoading = false;
              });
            }
          }).catchError((err) {
            Logx.em(_TAG, 'error loading blocs ' + err.toString());
            setState(() {
              _isBlocsLoading = false;
            });
          });

    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    FirestoreHelper.pullUpcomingPartyByEndTime(timeNow).then((res) {
      Logx.i(_TAG,"successfully pulled in parties.");

      if (res.docs.isNotEmpty) {
        try {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(map, true);

          setState(() {
            mUpcomingParty = party;
            _isUpcomingPartyLoading = false;
          });
        } catch (err) {
          Logx.em(_TAG, 'error: ' + err.toString());
        }
      } else {
        Logx.em(_TAG, 'no upcoming party found!');
        setState(() {
          _isUpcomingPartyLoading = false;
        });
      }
    });

    FirestoreHelper.pullGuestWifi(Constants.blocServiceId).then((res) {
      Logx.i(_TAG,"successfully pulled in guest wifi");

      if (res.docs.isNotEmpty) {
        try {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final GuestWifi wifi = GuestWifi.fromMap(data);

          setState(() {
            mGuestWifi = wifi;
            _isGuestWifiDetailsLoading = false;
          });
        } on PlatformException catch (e, s) {
          Logx.e(_TAG, e, s);
        } on Exception catch (e, s) {
          Logx.e(_TAG, e, s);
        } catch (e) {
          Logx.em(_TAG, e.toString());
        }
      } else {
        Logx.i(_TAG,'no guest wifi found!');
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
            const SizedBox(height: 1.0),
            _isBlocsLoading ? const LoadingWidget() : _displayBlocs(context),
            _isUpcomingPartyLoading
                ? const LoadingWidget()
                : _displayUpcomingParty(context),
            const SizedBox(height: 10.0),
            UserPreferences.isUserLoggedIn()
                ? _isGuestWifiDetailsLoading
                    ? const LoadingWidget()
                    : buildWifi(context)
                : const SizedBox(),
            const SizedBox(height: 10.0),
            kIsWeb
                ? const StoreBadgeItem()
                : const SizedBox(),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  _displayBlocs(context) {
    return Container(
      height: 390,
      child: ListView.builder(
          itemCount: mBlocs.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            Bloc bloc = mBlocs[index];

            return GestureDetector(
              child:
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
      child: PartyBanner(
        party: mUpcomingParty,
        isClickable: true,
        shouldShowButton: true,
      ),
    );
  }

  buildWifi(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
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
            padding: const EdgeInsets.only(top: 10, left: 10.0, right: 0.0),
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
  buildSuperstarsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getUsers(Constants.MANAGER_LEVEL),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Logx.i(_TAG, 'loading users...');
          return const LoadingWidget();
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
        return const LoadingWidget();
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
