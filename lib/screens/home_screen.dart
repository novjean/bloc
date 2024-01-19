import 'package:bloc/helpers/bloc_helper.dart';
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
import '../db/entity/user_bloc.dart';
import '../db/shared_preferences/table_preferences.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
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

  List<Party> mParties = [];
  var _isPartiesLoading = true;

  List<PartyGuest> mPartyGuestRequests = [];

  final ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 45), curve: Curves.linear);
  }

  AdCampaign mAdCampaign = Dummy.getDummyAdCampaign();
  var _isAdCampaignLoading = true;

  @override
  void initState() {
    Logx.d(_TAG, 'HomeScreen');

    super.initState();

    _loadBlocsAndUserBlocs();

    _loadPartiesAndGuestList();

    FirestoreHelper.pullAdCampaignByStorySize(false).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mAdCampaign = Fresh.freshAdCampaignMap(data, false);
        _isAdCampaignLoading = false;

        if (mounted) {
          setState(() {});
        }
      }
    });

    FirestoreHelper.pullGuestWifi(Constants.blocServiceId).then((res) {
      if (res.docs.isNotEmpty) {
        try {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          mGuestWifi = GuestWifi.fromMap(data);
          _isGuestWifiDetailsLoading = false;

          if (mounted) {
            setState(() {});
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _isBlocsLoading ? const LoadingWidget() : _displayBlocs(context),
          _isPartiesLoading
              ? const LoadingWidget()
              : _displayPartiesFooter(context),
        ],
      ),
    );
  }

  _displayBlocs(context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.30,
      width: MediaQuery.of(context).size.width * 0.99,
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

  _displayPartiesFooter(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: mParties.length,
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          Party party = mParties[index];

          bool isGuestListRequested = false;
          for (PartyGuest partyGuest in mPartyGuestRequests) {
            if (partyGuest.partyId == party.id) {
              isGuestListRequested = true;
              break;
            }
          }

          if (mParties.length == 1) {
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
                _isAdCampaignLoading
                    ? const SizedBox()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: AdCampaignSlideItem(adCampaign: mAdCampaign)),
                const SizedBox(height: 10.0),
                UserPreferences.isUserLoggedIn()
                    ? _isGuestWifiDetailsLoading
                        ? const LoadingWidget()
                        : _buildWifi(context)
                    : const SizedBox(),
                const SizedBox(height: 10.0),
                kIsWeb ? const StoreBadgeItem() : const SizedBox(),
                const SizedBox(height: 10.0),
                Footer(),
              ],
            );
          } else {
            if (index == mParties.length - 1) {
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
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: 300,
                      child: AdCampaignSlideItem(adCampaign: mAdCampaign)),
                  const SizedBox(height: 10.0),
                  _isGuestWifiDetailsLoading
                      ? const LoadingWidget()
                      : _buildWifi(context),
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

  _buildWifi(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(),
        color: Constants.primary,
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
                      if (UserPreferences.isUserLoggedIn()) {
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
                UserPreferences.resetUser(0);
                TablePreferences.resetQuickTable();

                await FirebaseAuth.instance.signOut();

                GoRouter.of(context).go('/login/false');
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

  void _loadBlocsAndUserBlocs() async {
    UserPreferences.myUser.clearanceLevel >= Constants.PROMOTER_LEVEL
        ? await FirestoreHelper.pullBlocsPromoter().then((res) async {
            if (res.docs.isNotEmpty) {
              Logx.i(_TAG,
                  "successfully pulled in all power and superpower blocs");

              mBlocs.clear();

              for (int i = 0; i < res.docs.length; i++) {
                DocumentSnapshot document = res.docs[i];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                final Bloc bloc = Fresh.freshBlocMap(data, false);

                if (bloc.powerBloc || bloc.superPowerBloc) {
                  mBlocs.add(bloc);
                }

                await FirestoreHelper.pullUserBlocs(UserPreferences.myUser.id)
                    .then((res) {
                  if (res.docs.isNotEmpty) {
                    List<String> userBlocServiceIds = [];
                    for (int i = 0; i < res.docs.length; i++) {
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      UserBloc userBloc = Fresh.freshUserBlocMap(data, true);
                      userBlocServiceIds.add(userBloc.blocServiceId);
                    }

                    UserPreferences.setUserBlocs(userBlocServiceIds);
                  } else {
                    Logx.em(_TAG, 'no blocs selected by the user ');

                    BlocHelper.setDefaultBlocs(UserPreferences.myUser.id);
                  }
                });

                if (mounted) {
                  setState(() {
                    _isBlocsLoading = false;
                  });
                }
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
        : await FirestoreHelper.pullBlocs().then((res) async {
            if (res.docs.isNotEmpty) {
              Logx.i(_TAG, "successfully pulled in blocs");

              mBlocs.clear();

              for (int i = 0; i < res.docs.length; i++) {
                DocumentSnapshot document = res.docs[i];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                final Bloc bloc = Fresh.freshBlocMap(data, false);

                if (bloc.powerBloc || bloc.superPowerBloc) {
                  mBlocs.add(bloc);
                }

                await FirestoreHelper.pullUserBlocs(UserPreferences.myUser.id)
                    .then((res) {
                  if (res.docs.isNotEmpty) {
                    List<String> userBlocServiceIds = [];
                    for (int i = 0; i < res.docs.length; i++) {
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      UserBloc userBloc = Fresh.freshUserBlocMap(data, true);

                      if (!userBlocServiceIds
                          .contains(userBloc.blocServiceId)) {
                        userBlocServiceIds.add(userBloc.blocServiceId);
                      } else {
                        Logx.d(_TAG, 'duplicate user bloc found, deleting...');
                        FirestoreHelper.deleteUserBloc(userBloc.id);
                      }
                    }

                    UserPreferences.setUserBlocs(userBlocServiceIds);
                  } else {
                    Logx.em(_TAG,
                        'no blocs found for the user, setting default...');

                    BlocHelper.setDefaultBlocs(UserPreferences.myUser.id);
                  }
                });

                if(mounted){
                  setState(() {
                    _isBlocsLoading = false;
                  });
                }
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
            Logx.em(_TAG, 'error loading blocs $err');
          });
  }

  void _loadPartiesAndGuestList() async {
    await FirestoreHelper.pullUpcomingParties(Timestamp.now().millisecondsSinceEpoch).then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);

          if(UserPreferences.getUserBlocs().contains(party.blocServiceId)){
            mParties.add(party);
          }
        }

        if(mounted){
          setState(() {
            _isPartiesLoading = false;
          });
        } else {
          Logx.dst(_TAG, 'not mounted. parties cannot be shown!');
        }
      } else {
        // no parties, long live bloc!
      }
    });

    await FirestoreHelper.pullGuestListRequested(UserPreferences.myUser.id)
        .then((res) {
      if (res.docs.isNotEmpty) {
        Logx.i(_TAG, "successfully pulled in requested guest list");

        List<PartyGuest> partyGuestRequests = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyGuest partyGuest = Fresh.freshPartyGuestMap(data, false);
          partyGuestRequests.add(partyGuest);
        }
        if(mounted){
          setState(() {
            mPartyGuestRequests = partyGuestRequests;
          });
        }
      } else {
        Logx.i(_TAG, 'no party guest requests found!');
      }
    });
  }
}
