import 'package:bloc/db/entity/user.dart';
import 'package:bloc/main.dart';
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
import '../widgets/footer.dart';
import '../widgets/home/bloc_slide_item.dart';
import '../widgets/parties/party_banner.dart';
import '../widgets/search_card.dart';
import '../widgets/store_badge_item.dart';
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

  GuestWifi mGuestWifi = Dummy.getDummyWifi(Constants.blocServiceId);
  var _isGuestWifiDetailsLoading = true;

  @override
  void initState() {
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
                final Bloc bloc = Fresh.freshBlocMap(data, false);
                blocs.add(bloc);

                setState(() {
                  mBlocs = blocs;
                  _isBlocsLoading = false;
                });
              }
            } else {
              Logx.em(_TAG, ' no blocs found!!!');
              //todo: need to re-attempt or check internet connection
              setState(() {
                _isBlocsLoading = false;
              });
            }
          }).catchError((e, s) {
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
                final Bloc bloc = Fresh.freshBlocMap(data, false);
                blocs.add(bloc);

                setState(() {
                  mBlocs = blocs;
                  _isBlocsLoading = false;
                });
              }
            } else {
              Logx.em(_TAG, 'no blocs found!!!');
              //todo: need to re-attempt or check internet connection
              if(mounted){
                setState(() {
                  mBlocs = [];
                  _isBlocsLoading = false;
                });
              }
            }
          }).catchError((err) {
            Logx.em(_TAG, 'error loading blocs ' + err.toString());
            if(mounted){
              setState(() {
                _isBlocsLoading = false;
              });
            }
          });

    FirestoreHelper.pullGuestWifi(Constants.blocServiceId).then((res) {
      Logx.i(_TAG, "successfully pulled in guest wifi");

      if (res.docs.isNotEmpty) {
        try {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final GuestWifi wifi = GuestWifi.fromMap(data);

          if (mounted) {
            setState(() {
              mGuestWifi = wifi;
              _isGuestWifiDetailsLoading = false;
            });
          }
        } on PlatformException catch (e, s) {
          Logx.e(_TAG, e, s);
        } on Exception catch (e, s) {
          Logx.e(_TAG, e, s);
        } catch (e) {
          Logx.em(_TAG, e.toString());
        }
      } else {
        Logx.i(_TAG, 'no guest wifi found!');
      }
    });
    super.initState();
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
        resizeToAvoidBottomInset : false,
        body: Column(
          children: <Widget>[
            _isBlocsLoading ? const LoadingWidget() : _displayBlocs(context),
            _displayPartiesNFooter(context),
          ],
        ),
      ),
    );
  }

  _displayBlocs(context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
          itemCount: mBlocs.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            Bloc bloc = mBlocs[index];

            return BlocSlideItem(
              bloc: bloc,
            );
          }),
    );
  }

  buildWifi(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(),
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                flex: 1,
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
              ),
              Flexible(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: DarkButtonWidget(
                    text: 'copy password',
                    onClicked: () {
                      Clipboard.setData(
                              ClipboardData(text: mGuestWifi.password))
                          .then((value) {
                        Toaster.shortToast('wifi password copied');
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  displayStoreBadge(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: const BorderRadius.all(Radius.circular(0)),
              image: const DecorationImage(
                image: AssetImage('assets/images/google-play-badge.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: const BorderRadius.all(Radius.circular(0)),
              image: const DecorationImage(
                image: AssetImage('assets/images/google-play-badge.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _displayPartiesNFooter(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getUpcomingParties(timeNow),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasData) {
          List<Party> parties = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final Party bloc = Fresh.freshPartyMap(data, true);
            parties.add(bloc);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayPartiesList(context, parties);
            }
          }
        }

        return Expanded(
          child: Column(
            children: [
              UserPreferences.isUserLoggedIn()
                  ? _isGuestWifiDetailsLoading
                      ? const LoadingWidget()
                      : buildWifi(context)
                  : const SizedBox(),
              const SizedBox(height: 10.0),
              kIsWeb ? const StoreBadgeItem() : const SizedBox(),
              const SizedBox(height: 10.0),
              Footer(),
            ],
          ),
        );
      },
    );
  }

  _displayPartiesList(BuildContext context, List<Party> parties) {
    return Expanded(
      child: ListView.builder(
        itemCount: parties.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          Party party = parties[index];

          if (parties.length == 1) {
            _displayLastParty(party);
            return Column(
              children: [
                PartyBanner(
                  party: party,
                  isClickable: true,
                  shouldShowButton: true,
                ),
                const SizedBox(height: 10.0),
                UserPreferences.isUserLoggedIn()
                    ? _isGuestWifiDetailsLoading
                        ? const LoadingWidget()
                        : buildWifi(context)
                    : const SizedBox(),
                const SizedBox(height: 10.0),
                kIsWeb ? const StoreBadgeItem() : const SizedBox(),
                const SizedBox(height: 10.0),
                Footer(),
              ],
            );
          } else {
            if (index == parties.length - 1) {
              // _displayLastParty(party);
              return Column(
                children: [
                  PartyBanner(
                    party: party,
                    isClickable: true,
                    shouldShowButton: true,
                  ),
                  const SizedBox(height: 10.0),
                  UserPreferences.isUserLoggedIn()
                      ? _isGuestWifiDetailsLoading
                          ? const LoadingWidget()
                          : buildWifi(context)
                      : const SizedBox(),
                  const SizedBox(height: 10.0),
                  kIsWeb ? const StoreBadgeItem() : const SizedBox(),
                  const SizedBox(height: 10.0),
                  Footer(),
                ],
              );
            } else {
              return PartyBanner(
                party: party,
                isClickable: true,
                shouldShowButton: true,
              );
            }
          }
        },
      ),
    );
  }

  _displayLastParty(Party party) {
    return Column(
      children: [
        PartyBanner(
          party: party,
          isClickable: true,
          shouldShowButton: true,
        ),
        const SizedBox(height: 10.0),
        UserPreferences.isUserLoggedIn()
            ? _isGuestWifiDetailsLoading
                ? const LoadingWidget()
                : buildWifi(context)
            : const SizedBox(),
        const SizedBox(height: 10.0),
        kIsWeb ? const StoreBadgeItem() : const SizedBox(),
        const SizedBox(height: 10.0),
        Footer(),
      ],
    );
  }

  /** optional **/
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
  // buildBookTableRow(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       // NumbersWidget(),
  //       ButtonWidget(
  //           text: 'book a table',
  //           onClicked: () async {
  //             await Navigator.of(context).push(
  //               MaterialPageRoute(
  //                   builder: (context) => ReservationAddEditScreen(
  //                          reservation: null, task: 'add',
  //                       )),
  //             );
  //           }),
  //     ],
  //   );
  // }

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
