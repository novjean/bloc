import 'package:bloc/screens/parties/tix_buy_edit_screen.dart';
import 'package:bloc/utils/dialog_utils.dart';
import 'package:bloc/utils/file_utils.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/parties/venue_banner.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../db/entity/history_music.dart';
import '../../db/entity/organizer.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/party_interest.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../widgets/footer.dart';
import '../../widgets/organizer/organizer_banner.dart';
import '../../widgets/parties/artist_banner.dart';
import '../../widgets/store_badge_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/button_widget.dart';
import '../manager/parties/party_add_edit_screen.dart';
import 'party_guest_add_edit_manage_screen.dart';

class EventScreen extends StatefulWidget {
  final String partyName;
  final String partyChapter;

  const EventScreen(
      {Key? key, required this.partyName, required this.partyChapter})
      : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  static const String _TAG = 'EventScreen';

  late Party mParty;
  var _isPartyLoading = true;

  int mInterestCount = 0;

  bool isGuestListRequested = false;

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

        if (UserPreferences.isUserLoggedIn()) {
          FirestoreHelper.pullPartyGuestByUser(
                  UserPreferences.myUser.id, mParty.id)
              .then((res) {
            if (res.docs.isNotEmpty) {
              setState(() {
                _isPartyLoading = false;
                isGuestListRequested = true;
              });
            } else {
              setState(() {
                _isPartyLoading = false;
              });
            }
          });
        } else {
          setState(() {
            _isPartyLoading = false;
          });
        }

        FirestoreHelper.pullPartyInterest(mParty.id).then((res) {
          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            PartyInterest partyInterest =
                Fresh.freshPartyInterestMap(data, false);

            if (UserPreferences.isUserLoggedIn()) {
              if (!partyInterest.userIds.contains(UserPreferences.myUser.id)) {
                FirestoreHelper.updatePartyInterestCount(partyInterest.id);
              } else {
                Logx.d(_TAG, 'user interest previously recorded for party');
              }
            } else {
              FirestoreHelper.updatePartyInterestCount(partyInterest.id);
            }

            setState(() {
              mInterestCount =
                  partyInterest.initCount + partyInterest.userIds.length;
            });
          } else {
            PartyInterest partyInterest = Dummy.getDummyPartyInterest();
            partyInterest = partyInterest.copyWith(
                partyId: mParty.id,
                userIds: [UserPreferences.myUser.id],
                initCount: 11);
            FirestoreHelper.pushPartyInterest(partyInterest);

            Logx.d(_TAG, 'party interest created for party');
          }
        });
        FirestoreHelper.updatePartyViewCount(mParty.id);
      } else {
        Logx.em(_TAG, 'no party found!');
        setState(() {
          _isPartyLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Constants.background,
            title: AppBarTitle(
              title: widget.partyName.toLowerCase(),
            ),
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary,),
              onPressed: () {
                GoRouter.of(context).goNamed(RouteConstants.landingRouteName);
              },
            ),
          ),
          backgroundColor: Constants.background,
          body: _isPartyLoading ? const LoadingWidget() : _buildBody(context)),
    );
  }

  _buildBody(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    bool isGuestListActive =
        mParty.isGuestListActive & (timeNow < mParty.guestListEndTime);

    bool showGuestListBuyTix = false;
    if (!mParty.isTBA &&
        !mParty.isTicketsDisabled &&
        (mParty.isTix || mParty.ticketUrl.isNotEmpty)) {
      if (isGuestListActive) {
        showGuestListBuyTix = true;
      }
    }

    return _isPartyLoading
        ? const LoadingWidget()
        : ListView(
            shrinkWrap: true,
            children: [
              mParty.imageUrls.length > 1
                  ? CarouselSlider(
                      options: CarouselOptions(
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 1200),
                        // enlargeCenterPage: false,
                        scrollDirection: Axis.horizontal,
                        aspectRatio: mParty.isSquare ? 1.33 : 1.0,
                      ),
                      items: mParty.imageUrls
                          .map((item) => kIsWeb
                              ? SizedBox(
                                  width: double.infinity,
                                  child: Image.network(item,
                                      width: double.infinity,
                                      fit: BoxFit.cover),
                                )
                              : CachedNetworkImage(
                                  imageUrl: item,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      const FadeInImage(
                                    placeholder:
                                        AssetImage('assets/images/logo.png'),
                                    image: AssetImage('assets/images/logo.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ))
                          .toList(),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: FadeInImage(
                        placeholder: const AssetImage('assets/images/logo.png'),
                        image: NetworkImage(mParty.showStoryImageUrl
                            ? mParty.storyImageUrl
                            : mParty.imageUrl),
                        fit: BoxFit.contain,
                      )),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      child: RichText(
                        text: TextSpan(
                            text: '${mParty.name.toLowerCase()} ',
                            style: const TextStyle(
                                fontFamily: Constants.fontDefault,
                                color: Constants.lightPrimary,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                  text: mParty.chapter == 'I'
                                      ? ' '
                                      : mParty.chapter,
                                  style: const TextStyle(
                                      fontFamily: Constants.fontDefault,
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
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0, left: 5),
                        child: showGuestListOrTicketButton(context),
                      )),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mParty.isTBA
                          ? 'tba'
                          : '${DateTimeUtils.getFormattedDate(mParty.startTime)}, ${DateTimeUtils.getFormattedTime(mParty.startTime)}',
                      style: const TextStyle(
                          fontSize: 18, color: Constants.lightPrimary),
                    ),
                    showGuestListBuyTix && !mParty.isGuestListFull
                        ? _showGuestListMiniButton(context)
                        : const SizedBox(),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(mParty.description.toLowerCase(),
                    textAlign: TextAlign.start,
                    softWrap: true,
                    style: const TextStyle(
                      color: Constants.lightPrimary,
                      fontSize: 18,
                    )),
              ),
              const SizedBox(height: 15),
              mInterestCount > 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$mInterestCount members are attending this event.',
                            style: const TextStyle(
                                color: Constants.primary, fontSize: 18),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 10),
              mParty.artistIds.isNotEmpty
                  ? _loadArtists(context)
                  : const SizedBox(),
              SizedBox(height: mParty.organizerIds.isNotEmpty ? 10 : 0),

              mParty.organizerIds.isNotEmpty  ? const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text('organizers',
                        style: TextStyle(
                            color: Constants.lightPrimary,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ) : const SizedBox(),

              mParty.organizerIds.isNotEmpty ?
                  _loadOrganizers(context)
                  : const SizedBox(),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text('venue',
                        style: TextStyle(
                            color: Constants.lightPrimary,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              VenueBanner(blocServiceId: mParty.blocServiceId),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text('share with friends',
                        style: TextStyle(
                            color: Constants.lightPrimary,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonWidget(
                      text: '🎨 poster',
                      onClicked: () async {
                        FirestoreHelper.updatePartyShareCount(mParty.id);

                        final urlImage = mParty.storyImageUrl.isNotEmpty
                            ? mParty.storyImageUrl
                            : mParty.imageUrl;

                        if (kIsWeb) {
                          FileUtils.openFileNewTabForWeb(urlImage);
                        } else {
                          FileUtils.sharePhoto(
                              mParty.id,
                              urlImage,
                              'bloc-${mParty.name}',
                              '${StringUtils.firstFewWords(mParty.description, 15)}... \n\nhey. check out this event on bloc. '
                                  '\n\n🍎 ios:\n${Constants.urlBlocAppStore} \n\n🤖 android:\n${Constants.urlBlocPlayStore} \n\n🌏 web:\n${Constants.urlBlocWeb} \n\n#blocCommunity 💛');
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ButtonWidget(
                        text: '🎯 page',
                        onClicked: () async {
                          FirestoreHelper.updatePartyShareCount(mParty.id);
                          final url =
                              'http://bloc.bar/#/event/${Uri.encodeComponent(widget.partyName)}/${widget.partyChapter}';
                          await Share.share(
                              'Check this party, ${widget.partyName} out on bloc. $url');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              mParty.instagramUrl.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text('links',
                                  style: TextStyle(
                                      color: Constants.lightPrimary,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      InkWell(
                        onTap: () {
                          final uri = Uri.parse(mParty.instagramUrl);
                          NetworkUtils.launchInBrowser(uri);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 2),
                          child: Text(
                            'instagram 🧡',
                            style: TextStyle(
                              fontSize: 18,
                              color: Constants.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : const SizedBox(),
              const SizedBox(height: 15.0),
              kIsWeb ? const StoreBadgeItem() : const SizedBox(),
              const SizedBox(height: 15.0),

              UserPreferences.myUser.clearanceLevel == Constants.ADMIN_LEVEL ?
                  Column(children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text('admin',
                              style: TextStyle(
                                  color: Constants.lightPrimary,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) =>
                                    PartyAddEditScreen(party: mParty, task: 'edit')));                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 2),
                            child: Text(
                              'manage event',
                              style: TextStyle(
                                fontSize: 18,
                                color: Constants.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                  ],)
                  : const SizedBox(),

              Footer(),
            ],
          );
  }

  Widget _loadArtists(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getPartyArtists(mParty.artistIds),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
              List<Party> artists = [];
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                final Party bloc = Fresh.freshPartyMap(data, false);
                artists.add(bloc);
              }
              artists.sort((a, b) => a.name.compareTo(b.name));

              List<Party> lineup = [];
              List<Party> acts = [];
              for(Party artist in artists){
                if(artist.isBigAct){
                  lineup.add(artist);
                } else {
                  acts.add(artist);
                }
              }
              lineup.addAll(acts);

              return _showArtists(context, lineup);
            }
        }
      },
    );
  }

  _showArtists(BuildContext context, List<Party> parties) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: parties.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        Party party = parties[index];

        if (index == 0) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 15, top: 10.0, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('lineup',
                        style: TextStyle(
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
              ),
            ],
          );
        } else {
          return ArtistBanner(
            party: party,
            isClickable: true,
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

    if (!mParty.isTBA && mParty.isTix) {
      return Container(
        height: 50,
        width: 160,
        padding: const EdgeInsets.only(bottom: 1, top: 1),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.primary,
            foregroundColor: Constants.background,
            shadowColor: Colors.white30,
            elevation: 3,
          ),
          onPressed: () {
            if (kIsWeb) {
              if(mParty.isTix){
                Tix tix = Dummy.getDummyTix();
                tix = tix.copyWith(partyId: mParty.id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => TixBuyEditScreen(
                          tix: tix, task: 'buy')),
                );
              } else if (mParty.ticketUrl.isNotEmpty) {
                final uri = Uri.parse(mParty.ticketUrl);
                NetworkUtils.launchInAppBrowser(uri);
              } else {
                Logx.ilt(_TAG, 'bloc app is required to purchase this ticket');
                DialogUtils.showDownloadAppDialog(context, DialogUtils.downloadTixGuestList);
              }
            } else {
              //navigate to purchase tix screen
              Tix tix = Dummy.getDummyTix();
              tix = tix.copyWith(partyId: mParty.id);

              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        TixBuyEditScreen(tix: tix, task: 'buy')),
              );
            }

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
                  if (res.docs.length > 1) {
                    // that means there are multiple, so consolidate
                    HistoryMusic hm = Dummy.getDummyHistoryMusic();
                    int totalCount = 0;

                    for (int i = 0; i < res.docs.length; i++) {
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      final HistoryMusic historyMusic =
                          Fresh.freshHistoryMusicMap(data, false);

                      totalCount += historyMusic.count;
                      if (i == 0) {
                        hm = historyMusic;
                      }
                      FirestoreHelper.deleteHistoryMusic(historyMusic.id);
                    }

                    totalCount = totalCount + 1;
                    hm = hm.copyWith(count: totalCount);
                    FirestoreHelper.pushHistoryMusic(hm);
                  } else {
                    DocumentSnapshot document = res.docs[0];
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    HistoryMusic historyMusic =
                        Fresh.freshHistoryMusicMap(data, false);
                    int newCount = historyMusic.count + 1;

                    historyMusic = historyMusic.copyWith(count: newCount);
                    FirestoreHelper.pushHistoryMusic(historyMusic);
                  }
                }
              });
            }
          },
          label: const Text(
            'ticket',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Constants.darkPrimary),
          ),
          icon: const Icon(
            Icons.star,
            size: 22.0,
          ),
        ),
      );
    } else if (!mParty.isTBA && mParty.ticketUrl.isNotEmpty) {
      return Container(
        height: 50,
        width: 160,
        padding: const EdgeInsets.only(bottom: 1, top: 1),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.primary,
            foregroundColor: Constants.background,
            shadowColor: Colors.white30,
            elevation: 3,
          ),
          onPressed: () {
            final uri = Uri.parse(mParty.ticketUrl);
            NetworkUtils.launchInAppBrowser(uri);

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
                  if (res.docs.length > 1) {
                    // that means there are multiple, so consolidate
                    HistoryMusic hm = Dummy.getDummyHistoryMusic();
                    int totalCount = 0;

                    for (int i = 0; i < res.docs.length; i++) {
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      final HistoryMusic historyMusic =
                          Fresh.freshHistoryMusicMap(data, false);

                      totalCount += historyMusic.count;
                      if (i == 0) {
                        hm = historyMusic;
                      }
                      FirestoreHelper.deleteHistoryMusic(historyMusic.id);
                    }

                    totalCount = totalCount + 1;
                    hm = hm.copyWith(count: totalCount);
                    FirestoreHelper.pushHistoryMusic(hm);
                  } else {
                    DocumentSnapshot document = res.docs[0];
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    HistoryMusic historyMusic =
                        Fresh.freshHistoryMusicMap(data, false);
                    int newCount = historyMusic.count + 1;

                    historyMusic = historyMusic.copyWith(count: newCount);
                    FirestoreHelper.pushHistoryMusic(historyMusic);
                  }
                }
              });
            }
          },
          label: const Text(
            'ticket',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Constants.darkPrimary),
          ),
          icon: const Icon(
            Icons.star_half,
            size: 22.0,
          ),
        ),
      );
    } else if (isGuestListActive) {
      if (isGuestListRequested) {
        return Container(
          height: 50,
          width: 160,
          padding: const EdgeInsets.only(bottom: 1, top: 1),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primary,
              foregroundColor: Constants.background,
              shadowColor: Colors.white30,
              elevation: 3,
              // minimumSize: const Size.fromHeight(60),
            ),
            onPressed: () {
              GoRouter.of(context).pushNamed(RouteConstants.boxOfficeRouteName);
            },
            icon: const Icon(
              Icons.keyboard_command_key_sharp,
              size: 22.0,
            ),
            label: const Text(
              'box office',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Constants.darkPrimary),
            ),
          ),
        );
      } else {
        return Container(
          height: 50,
          width: 160,
          padding: const EdgeInsets.only(bottom: 1, top: 1),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primary,
              foregroundColor: Constants.background,
              shadowColor: Colors.white30,
              elevation: 3,
              // minimumSize: const Size.fromHeight(60),
            ),
            onPressed: () {
              PartyGuest partyGuest = Dummy.getDummyPartyGuest(true);
              partyGuest.partyId = mParty.id;

              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => PartyGuestAddEditManageScreen(
                        partyGuest: partyGuest, party: mParty, task: 'add')),
              );
            },
            icon: const Icon(
              Icons.app_registration,
              size: 22.0,
            ),
            label: const Text(
              'guest list',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Constants.darkPrimary),
            ),
          ),
        );
      }
    } else {
      return const SizedBox();
    }
  }

  _showGuestListMiniButton(BuildContext context) {
    return Container(
      height: 40,
      width: 100,
      padding: const EdgeInsets.only(left: 5),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.primary,
          foregroundColor: Constants.background,
          shadowColor: Colors.white30,
          elevation: 3,
          padding: EdgeInsets.only(left: 5, right: 5)
        ),
        onPressed: () {
          PartyGuest partyGuest = Dummy.getDummyPartyGuest(true);
          partyGuest.partyId = mParty.id;

          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => PartyGuestAddEditManageScreen(
                    partyGuest: partyGuest, party: mParty, task: 'add')),
          );
        },
        icon: const Icon(Icons.app_registration, size: 19,),
        label: const Text(
          'guest',
          maxLines: 1,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Constants.darkPrimary),
        ),
      ),
    );
  }

  Widget _loadOrganizers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getPartyOrganizers(mParty.organizerIds),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
              List<Organizer> organizers = [];
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
                final Organizer organizer = Fresh.freshOrganizerMap(data, false);
                organizers.add(organizer);
              }
              organizers.sort((a, b) => a.name.compareTo(b.name));

              return _showOrganizers(context, organizers);
            }
        }
      },
    );
  }

  _showOrganizers(BuildContext context, List<Organizer> organizers) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 2),
      height: 83,
      child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        itemCount: organizers.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          Organizer organizer = organizers[index];

          return OrganizerBanner(
            organizer: organizer,
            isClickable: true,
          );
        },
      ),
    );
  }

}
