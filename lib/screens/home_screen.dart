import 'package:bloc/main.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../db/entity/ad_campaign.dart';
import '../db/entity/bloc.dart';
import '../db/entity/guest_wifi.dart';
import '../db/entity/party.dart';
import '../db/entity/party_guest.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../routes/route_constants.dart';
import '../utils/logx.dart';
import '../widgets/ad_campaign_slide_item.dart';
import '../widgets/footer.dart';
import '../widgets/home/bloc_slide_item.dart';
import '../widgets/parties/party_banner.dart';
import '../widgets/store_badge_item.dart';
import '../widgets/ui/dark_button_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _TAG = 'HomeScreen';

  List<Bloc> mBlocs = [];
  var _isBlocsLoading = true;

  GuestWifi mGuestWifi = Dummy.getDummyGuestWifi(Constants.blocServiceId);
  var _isGuestWifiDetailsLoading = true;

  List<PartyGuest> mPartyGuestRequests = [];
  var _isPartyGuestsLoading = true;

  final ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 45),
        curve: Curves.linear);
  }

  AdCampaign mAdCampaign = Dummy.getDummyAdCampaign();
  var _isAdCampaignLoading = true;

  @override
  void initState() {
    Logx.d(_TAG, 'HomeScreen');

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

                if(mounted) {
                  setState(() {
                    mBlocs = blocs;
                    _isBlocsLoading = false;
                  });
                }
              }
            } else {
              Logx.em(_TAG, 'no blocs found!!!');
              //todo: need to re-attempt or check internet connection
              if (mounted) {
                setState(() {
                  mBlocs = [];
                  _isBlocsLoading = false;
                });
              }
            }
          }).catchError((err) {
            Logx.em(_TAG, 'error loading blocs $err');
            if (mounted) {
              setState(() {
                _isBlocsLoading = false;
              });
            }
          });


    FirestoreHelper.pullGuestListRequested(UserPreferences.myUser.id)
        .then((res) {
      Logx.i(_TAG, "successfully pulled in requested guest list");

      if (res.docs.isNotEmpty) {
        List<PartyGuest> partyGuestRequests = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyGuest partyGuest = Fresh.freshPartyGuestMap(data, false);
          partyGuestRequests.add(partyGuest);
        }
        if(mounted) {
          setState(() {
            mPartyGuestRequests = partyGuestRequests;
            _isPartyGuestsLoading = false;
          });
        }
      } else {
        Logx.i(_TAG, 'no party guest requests found!');
        const SizedBox();
        if(mounted){
          setState(() {
            _isPartyGuestsLoading = false;
          });
        }
      }
    });

    FirestoreHelper.pullGuestWifi(Constants.blocServiceId).then((res) {
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
        if (mounted) {
          setState(() {
            _isGuestWifiDetailsLoading = false;
          });
        }
      }
    });

    super.initState();

    FirestoreHelper.pullAdCampaignByStorySize(false).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        setState(() {
          mAdCampaign = Fresh.freshAdCampaignMap(data, false);
          _isAdCampaignLoading = false;
        });
      } else {
        setState(() {
          _isAdCampaignLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      resizeToAvoidBottomInset: false,
      body: _isBlocsLoading && _isPartyGuestsLoading ? const LoadingWidget():
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _showBlocs(context),
          _showPartiesAndFooter(context),
        ],
      ),
    );
  }

  _showBlocs(context) {
    return SizedBox(
      height: mq.height * 0.30,
      width: mq.width * 0.99,
      child: ListView.builder(
          padding: EdgeInsets.zero,
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

  _showPartiesAndFooter(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getUpcomingParties(timeNow),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:{
          if (snapshot.hasData) {
            List<Party> parties = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              final Party bloc = Fresh.freshPartyMap(data, false);
              parties.add(bloc);
            }
            return _displayPartiesList(context, parties);

          }
          return Expanded(
            child: Column(
              children: [
                UserPreferences.isUserLoggedIn()
                    ? _isGuestWifiDetailsLoading
                    ? const LoadingWidget()
                    : buildWifi(context)
                    : const SizedBox(),
                const SizedBox(height: 15.0),
                kIsWeb ? const StoreBadgeItem() : const SizedBox(),
                const SizedBox(height: 10.0),
                Footer(),
              ],
            ),
          );
          }
        }
      },
    );
  }

  _displayPartiesList(BuildContext context, List<Party> parties) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: parties.length,
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          Party party = parties[index];

          bool isGuestListRequested = false;
          for (PartyGuest partyGuest in mPartyGuestRequests) {
            if (partyGuest.partyId == party.id) {
              isGuestListRequested = true;
              break;
            }
          }

          if (parties.length == 1) {
            return Column(
              children: [
                PartyBanner(
                  party: party,
                  isClickable: true,
                  shouldShowButton: true,
                  isGuestListRequested: isGuestListRequested,
                  shouldShowInterestCount: true,
                ),
                const SizedBox(height: 10.0),

                _isAdCampaignLoading?const SizedBox():
                SizedBox(
                    width: mq.width * 0.95,
                    height: mq.height * 0.25,
                    child: AdCampaignSlideItem(adCampaign: mAdCampaign)),
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
              return Column(
                children: [
                  PartyBanner(
                    party: party,
                    isClickable: true,
                    shouldShowButton: true,
                    isGuestListRequested: isGuestListRequested,
                    shouldShowInterestCount: true,
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                      width: mq.width * 0.95,
                      height: 300,
                      child: AdCampaignSlideItem(adCampaign: mAdCampaign)),
                  const SizedBox(height: 10.0),
                  _isGuestWifiDetailsLoading
                      ? const LoadingWidget()
                      : buildWifi(context),
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
                isGuestListRequested: isGuestListRequested,
                shouldShowInterestCount: true,
              );
            }
          }
        },
      ),
    );
  }

  buildWifi(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(),
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10, left: 10.0),
            child: Text(
              "🌀 free wifi  🛰️",
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
                    mGuestWifi.name.toLowerCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Constants.darkPrimary,
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
                      if(UserPreferences.isUserLoggedIn()){
                        Clipboard.setData(
                            ClipboardData(text: mGuestWifi.password))
                            .then((value) {
                          Logx.ist(_TAG, 'wifi password is copied 💫');
                        });
                      } else {
                        _showLoginDialog(context);
                      }
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

  _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            '🪵 login for free wifi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: const Text(
              "ain't no web without the key, so tap that login flow. once you're connected, the wifi's yours to move and groove. would you like to login?"),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                GoRouter.of(context)
                    .pushNamed(RouteConstants.loginRouteName, params: {
                  'skip': 'false',
                });
              },
              child: const Text("yes"),
            ),
            TextButton(
              child: const Text("no"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
