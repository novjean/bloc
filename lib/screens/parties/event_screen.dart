import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/history_music.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/app_route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../widgets/footer.dart';
import '../../widgets/parties/artist_banner.dart';
import '../../widgets/store_badge_item.dart';
import '../../widgets/ui/button_widget.dart';
import 'party_guest_add_edit_manage_screen.dart';

class EventScreen extends StatefulWidget {
  final String partyName;
  final String partyChapter;

  const EventScreen({required this.partyName, required this.partyChapter});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  static const String _TAG = 'EventScreen';

  Party mParty = Dummy.getDummyParty('');
  var _isPartyLoading = true;
  List<Party> mArtists = [];
  var _isArtistsLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullPartyByNameChapter(
            widget.partyName, widget.partyChapter)
        .then((res) {
      Logx.i(_TAG, "successfully pulled in party");

      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          mParty = party;
        }

        if(mParty.artistIds.isNotEmpty){
          FirestoreHelper.pullPartyArtistsByIds(mParty.artistIds).then((res) {
            if(res.docs.isNotEmpty){
              for (int i = 0; i < res.docs.length; i++) {
                DocumentSnapshot document = res.docs[i];
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                final Party artist = Fresh.freshPartyMap(data, false);
                mArtists.add(artist);
              }

              setState(() {
                _isArtistsLoading = false;
                _isPartyLoading = false;
              });
            } else {
              setState(() {
                _isArtistsLoading = false;
                _isPartyLoading = false;
              });
            }
          });
        } else {
          setState(() {
            _isArtistsLoading = false;
            _isPartyLoading = false;
          });
        }
      } else {
        Logx.i(_TAG, 'no party found!');
        setState(() {
          _isArtistsLoading = false;
          _isPartyLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.background,
          title: Text('bloc | ${mParty.name.toLowerCase()}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              GoRouter.of(context)
                  .pushNamed(MyAppRouteConstants.landingRouteName);
            },
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return _isPartyLoading && _isArtistsLoading
        ? const LoadingWidget()
        : SingleChildScrollView(
      physics: ScrollPhysics(),
          child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Hero(
                    tag: mParty.id,
                    child: Image.network(
                      mParty.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: RichText(
                          text: TextSpan(
                              text: '${mParty.name.toLowerCase()} ',
                              style: const TextStyle(
                                  color: Constants.lightPrimary,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                    text: mParty.chapter == 'I'
                                        ? ''
                                        : mParty.chapter,
                                    style: const TextStyle(
                                        color: Constants.lightPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FontStyle.italic)),
                              ]),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: showGuestListOrTicketButton(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    mParty.isTBA
                        ? 'tba'
                        : '${DateTimeUtils.getFormattedDate(mParty.startTime)}, ${DateTimeUtils.getFormattedTime(mParty.startTime)}',
                    style: const TextStyle(fontSize: 18, color: Constants.lightPrimary),
                  )
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(mParty.description.toLowerCase(),
                      textAlign: TextAlign.start,
                      softWrap: true,
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 18,
                      )),
                ),
                const SizedBox(height: 10),

                mParty.artistIds.isNotEmpty?

                _loadArtists(context): const SizedBox(),

                const SizedBox(height: 15.0),
                kIsWeb ? const StoreBadgeItem() : const SizedBox(),
                const SizedBox(height: 10.0),
                Footer(),
              ],
            ),
        );
  }

  Widget _loadArtists(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getPartyArtists(mParty.artistIds),
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
            final Party bloc = Fresh.freshPartyMap(data, false);
            parties.add(bloc);

            if (i == snapshot.data!.docs.length - 1) {
              return _showArtists(context, parties);
            }
          }
        }
        return LoadingWidget();
      },
    );
  }

  _showArtists(BuildContext context, List<Party> parties) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: parties.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        Party party = parties[index];

        if(index == 0){
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15, top: 10.0, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('lineup',
                        style: const TextStyle(
                        color: Constants.lightPrimary,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ArtistBanner(
                party: party,
                isClickable: true,
                shouldShowButton: true,
              ),
            ],
          );
        } else {
          return ArtistBanner(
            party: party,
            isClickable: false,
            shouldShowButton: false,
          );
        }
      },
    );
  }

  String findListenSource(String listenUrl) {
    if (listenUrl.contains('spotify')) {
      return ' on spotify';
    } else if (listenUrl.contains('soundcloud')) {
      return ' on soundcloud';
    } else if (listenUrl.contains('youtube')) {
      return ' on youtube';
    } else {
      return '';
    }
  }

  showGuestListOrTicketButton(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    bool isGuestListActive =
        mParty.isGuestListActive & (timeNow < mParty.guestListEndTime);

    if (!mParty.isTBA && mParty.ticketUrl.isNotEmpty) {
      return Container(
        height: 50,
        width: 150,
        padding: const EdgeInsets.only(left: 5, right: 10, bottom: 1, top: 1),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.primary,
            foregroundColor: Constants.background,
            shadowColor: Colors.white30,
            elevation: 3,
          ),
          onPressed: () {
            final uri = Uri.parse(mParty.ticketUrl);
            NetworkUtils.launchInBrowser(uri);

            if (UserPreferences.isUserLoggedIn()) {
              User user = UserPreferences.myUser;

              FirestoreHelper.pullHistoryMusic(user.id, mParty.genre)
                  .then((res) {
                if (res.docs.isEmpty) {
                  // no history, add new one
                  HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
                  historyMusic.userId = user.id;
                  historyMusic.genre = mParty.genre;
                  historyMusic.count = 1;
                  FirestoreHelper.pushHistoryMusic(historyMusic);
                } else {
                  for (int i = 0; i < res.docs.length; i++) {
                    DocumentSnapshot document = res.docs[i];
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    final HistoryMusic historyMusic =
                        Fresh.freshHistoryMusicMap(data, false);
                    historyMusic.count++;
                    FirestoreHelper.pushHistoryMusic(historyMusic);
                  }
                }
              });
            }
          },
          label: const Text(
            'buy ticket',
            style: TextStyle(fontSize: 18, color: Constants.darkPrimary),
          ),
          icon: const Icon(
            Icons.star_half,
            size: 24.0,
          ),
        ),
      );
    } else if (isGuestListActive) {
      return Container(
        height: 50,
        width: 150,
        padding: const EdgeInsets.only(left: 5, right: 10, bottom: 1, top: 1),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.primary,
            foregroundColor: Constants.background,
            shadowColor: Colors.white30,
            elevation: 3,
            // minimumSize: const Size.fromHeight(60),
          ),
          onPressed: () {
            PartyGuest partyGuest = Dummy.getDummyPartyGuest();
            partyGuest.partyId = mParty.id;

            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => PartyGuestAddEditManageScreen(
                      partyGuest: partyGuest, party: mParty, task: 'add')),
            );
          },
          icon: const Icon(
            Icons.app_registration,
            size: 24.0,
          ),
          label: const Text(
            'guest list',
            style: TextStyle(fontSize: 18, color: Constants.darkPrimary),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
