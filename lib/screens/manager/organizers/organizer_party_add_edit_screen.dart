import 'package:bloc/screens/parties/tix_buy_edit_screen.dart';
import 'package:bloc/utils/dialog_utils.dart';
import 'package:bloc/utils/file_utils.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/parties/venue_banner.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:bloc/widgets/ui/textfield_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../db/entity/party.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/logx.dart';
import '../../../utils/network_utils.dart';
import '../../../widgets/footer.dart';
import '../../../widgets/parties/artist_banner.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_textfield_widget.dart';

class OrganizerPartyAddEditScreen extends StatefulWidget {
  Party party;
  final String task;

  OrganizerPartyAddEditScreen(
      {Key? key, required this.party, required this.task})
      : super(key: key);

  @override
  State<OrganizerPartyAddEditScreen> createState() =>
      _OrganizerPartyAddEditScreenState();
}

class _OrganizerPartyAddEditScreenState
    extends State<OrganizerPartyAddEditScreen> {
  static const String _TAG = 'OrganizerEventAddEditScreen';

  DateTime sStartDateTime = DateTime.now();
  DateTime sEndDateTime = DateTime.now();
  DateTime sEndGuestListDateTime = DateTime.now();
  bool _isGuestListDateBeingSet = true;

  DateTime sDate = DateTime.now();

  TimeOfDay sTimeOfDay = TimeOfDay.now();
  bool _isStartDateBeingSet = true;
  bool _isEndDateBeingSet = true;

  bool isGuestListRequested = false;

  @override
  void initState() {
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
              title: widget.party.name.toLowerCase(),
            ),
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Constants.lightPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          backgroundColor: Constants.background,
          body: _buildBody(context)),
    );
  }

  _buildBody(BuildContext context) {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;
    bool isGuestListActive = widget.party.isGuestListActive &
        (timeNow < widget.party.guestListEndTime);

    bool showGuestListBuyTix = false;
    if (!widget.party.isTBA &&
        !widget.party.isTicketsDisabled &&
        (widget.party.isTix || widget.party.ticketUrl.isNotEmpty)) {
      if (isGuestListActive) {
        showGuestListBuyTix = true;
      }
    }

    return ListView(
      shrinkWrap: true,
      children: [
        widget.party.imageUrls.length > 1
            ? CarouselSlider(
                options: CarouselOptions(
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1200),
                  // enlargeCenterPage: false,
                  scrollDirection: Axis.horizontal,
                  aspectRatio: widget.party.isSquare ? 1.33 : 1.0,
                ),
                items: widget.party.imageUrls
                    .map((item) => GestureDetector(
                          onTap: () {
                            Logx.ist(_TAG, 'image clicked');
                          },
                          child: CachedNetworkImage(
                            imageUrl: item,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const FadeInImage(
                              placeholder: AssetImage('assets/images/logo.png'),
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ))
                    .toList(),
              )
            : SizedBox(
                width: double.infinity,
                child: FadeInImage(
                  placeholder: const AssetImage('assets/images/logo.png'),
                  image: NetworkImage(widget.party.showStoryImageUrl
                      ? widget.party.storyImageUrl
                      : widget.party.imageUrl),
                  fit: BoxFit.contain,
                )),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  Logx.ist(_TAG, 'edit name and chapter');
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  child: DarkTextFieldWidget(
                    label: 'name *',
                    text: widget.party.name,
                    onChanged: (name) =>
                        widget.party = widget.party.copyWith(name: name),
                  ),

                  // RichText(
                  //   text: TextSpan(
                  //       text: widget.party.name.isNotEmpty ? '${widget.party.name.toLowerCase()}' : 'event name',
                  //       style: const TextStyle(
                  //           fontFamily: Constants.fontDefault,
                  //           color: Constants.lightPrimary,
                  //           overflow: TextOverflow.ellipsis,
                  //           fontSize: 22,
                  //           fontWeight: FontWeight.bold),
                  //       children: <TextSpan>[
                  //         TextSpan(
                  //             text: widget.party.chapter == 'I'
                  //                 ? ' '
                  //                 : widget.party.chapter,
                  //             style: const TextStyle(
                  //                 fontFamily: Constants.fontDefault,
                  //                 color: Constants.lightPrimary,
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.normal,
                  //                 fontStyle: FontStyle.italic)),
                  //       ]),
                  // ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 5),
                child: DarkTextFieldWidget(
                  label: 'chapter *',
                  text: widget.party.chapter,
                  onChanged: (text) =>
                      widget.party = widget.party.copyWith(chapter: text),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'start time *',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Constants.lightPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              _dateTimeContainer(context, 'start'),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'end time *',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Constants.lightPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              _dateTimeContainer(context, 'end'),
            ],
          ),
        ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Flexible(
        //       flex: 2,
        //       child: Padding(
        //         padding: const EdgeInsets.only(left: 10 ,right: 5.0),
        //         child: DarkTextFieldWidget(
        //             label: 'start date',
        //             text: DateTimeUtils.getFormattedDate(widget.party.startTime),
        //             onChanged: (text) {},
        //             isReadOnly: true,
        //             onTap: () {
        //               Logx.ist(_TAG, 'date selected');
        //               dateTimeContainer(context, 'start');
        //             }
        //         ),
        //       ),
        //     ),
        //     Flexible(
        //       flex: 1,
        //       child: Padding(
        //         padding: const EdgeInsets.only(left: 5.0, right: 10),
        //         child: DarkTextFieldWidget(
        //             label: 'start time',
        //             text: DateTimeUtils.getFormattedTime(widget.party.startTime),
        //             onChanged: (text) {},
        //             isReadOnly: true,
        //             onTap: () {
        //               Logx.ist(_TAG, 'time selected');
        //             }
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: DarkTextFieldWidget(
            label: 'description *',
            text: widget.party.description,
            maxLines: 10,
            onChanged: (text) => widget.party = widget.party.copyWith(description: text),
            ),

          // Text(widget.party.description.toLowerCase(),
          //     textAlign: TextAlign.start,
          //     softWrap: true,
          //     style: const TextStyle(
          //       color: Constants.lightPrimary,
          //       fontSize: 18,
          //     )),
        ),
        const SizedBox(height: 15),

        // const SizedBox(height: 10),
        // widget.party.artistIds.isNotEmpty
        //     ? _loadArtists(context)
        //     : const SizedBox(),
        // const SizedBox(height: 10),
        // const Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 15.0),
        //       child: Text('venue',
        //           style: TextStyle(
        //               color: Constants.lightPrimary,
        //               overflow: TextOverflow.ellipsis,
        //               fontSize: 22,
        //               fontWeight: FontWeight.bold)),
        //     ),
        //   ],
        // ),
        // VenueBanner(blocServiceId: widget.party.blocServiceId),

        const SizedBox(height: 10),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       ButtonWidget(
        //         text: '🎨 poster',
        //         onClicked: () async {
        //           FirestoreHelper.updatePartyShareCount(widget.party.id);
        //
        //           final urlImage = widget.party.storyImageUrl.isNotEmpty
        //               ? widget.party.storyImageUrl
        //               : widget.party.imageUrl;
        //
        //           if (kIsWeb) {
        //             FileUtils.openFileNewTabForWeb(urlImage);
        //           } else {
        //             FileUtils.sharePhoto(
        //                 widget.party.id,
        //                 urlImage,
        //                 'bloc-${widget.party.name}',
        //                 '${StringUtils.firstFewWords(widget.party.description, 15)}... \n\nhey. check out this event on bloc. '
        //                     '\n\n🍎 ios:\n${Constants.urlBlocAppStore} \n\n🤖 android:\n${Constants.urlBlocPlayStore} \n\n🌏 web:\n${Constants.urlBlocWeb} \n\n#blocCommunity 💛');
        //           }
        //         },
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(left: 10.0),
        //         child: ButtonWidget(
        //           text: '🎯 page',
        //           onClicked: () async {
        //             FirestoreHelper.updatePartyShareCount(widget.party.id);
        //             final url =
        //                 'http://bloc.bar/#/event/${Uri.encodeComponent(widget.partyName)}/${widget.partyChapter}';
        //             await Share.share(
        //                 'Check this party, ${widget.partyName} out on bloc. $url');
        //           },
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 10),

        Column(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: DarkTextFieldWidget(
                label: 'instagram event url',
                text: widget.party.instagramUrl,
                onChanged: (text) => widget.party =
                    widget.party.copyWith(instagramUrl: text),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32,),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ButtonWidget(
            height: 50,
              text: 'save',
              onClicked: () {
            FirestoreHelper.pushParty(widget.party);
            Logx.ist(_TAG, 'event saved');
            Navigator.of(context).pop();
          }),
        ),

        const SizedBox(height: 32.0),
        Footer(),
      ],
    );
  }

  Widget _loadArtists(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getPartyArtists(widget.party.artistIds),
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
              for (Party artist in artists) {
                if (artist.isBigAct) {
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

  Widget _dateTimeContainer(BuildContext context, String type) {
    sStartDateTime = DateTimeUtils.getDate(widget.party.startTime);
    sEndDateTime = DateTimeUtils.getDate(widget.party.endTime);
    sEndGuestListDateTime =
        DateTimeUtils.getDate(widget.party.guestListEndTime);

    DateTime dateTime;
    if (type == 'start') {
      dateTime = sStartDateTime;
    } else if (type == 'end') {
      dateTime = sEndDateTime;
    } else {
      dateTime = sEndGuestListDateTime;
    }

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Constants.primary, width: 0.0),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              DateTimeUtils.getFormattedDateString(
                  dateTime.millisecondsSinceEpoch),
              style: const TextStyle(fontSize: 18, color: Constants.primary)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Constants.darkPrimary,
              shadowColor: Constants.shadowColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              minimumSize: const Size(50, 50),
            ),
            onPressed: () {
              if (type == 'start') {
                _isStartDateBeingSet = true;
                _isEndDateBeingSet = false;
                _isGuestListDateBeingSet = false;
              } else if (type == 'end') {
                _isStartDateBeingSet = false;
                _isEndDateBeingSet = true;
                _isGuestListDateBeingSet = false;
              } else {
                _isStartDateBeingSet = false;
                _isEndDateBeingSet = false;
                _isGuestListDateBeingSet = true;
              }
              _selectDate(context, dateTime);
            },
            child: const Text(
              'pick date & time',
              style: TextStyle(color: Constants.darkPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    final DateTime? _sDate = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (_sDate != null) {
      DateTime sDateTemp = DateTime(_sDate.year, _sDate.month, _sDate.day);

      setState(() {
        sDate = sDateTemp;
        _selectTime(context);
      });
    }
  }

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    setState(() {
      sTimeOfDay = pickedTime!;

      DateTime sDateTime = DateTime(sDate.year, sDate.month, sDate.day,
          sTimeOfDay.hour, sTimeOfDay.minute);

      if (_isStartDateBeingSet) {
        sStartDateTime = sDateTime;
        widget.party = widget.party
            .copyWith(startTime: sStartDateTime.millisecondsSinceEpoch);
      } else if (_isEndDateBeingSet) {
        sEndDateTime = sDateTime;
        widget.party =
            widget.party.copyWith(endTime: sEndDateTime.millisecondsSinceEpoch);
      } else if (_isGuestListDateBeingSet) {
        sEndGuestListDateTime = sDateTime;
        widget.party = widget.party.copyWith(
            guestListEndTime: sEndGuestListDateTime.millisecondsSinceEpoch);
      } else {
        Logx.em(_TAG, 'unhandled date time');
      }
    });
    return sTimeOfDay;
  }

// showGuestListOrTicketButton(BuildContext context) {
//   int timeNow = Timestamp.now().millisecondsSinceEpoch;
//   bool isGuestListActive =
//   widget.party.isGuestListActive & (timeNow < widget.party.guestListEndTime);
//
//   if (!widget.party.isTBA && widget.party.isTix) {
//     return Container(
//       height: 50,
//       width: 160,
//       padding: const EdgeInsets.only(bottom: 1, top: 1),
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Constants.primary,
//           foregroundColor: Constants.background,
//           shadowColor: Colors.white30,
//           elevation: 3,
//         ),
//         onPressed: () {
//           if (kIsWeb) {
//             if(widget.party.isTix){
//               Tix tix = Dummy.getDummyTix();
//               tix = tix.copyWith(partyId: widget.party.id);
//
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                     builder: (context) => TixBuyEditScreen(
//                         tix: tix, task: 'buy')),
//               );
//             } else if (widget.party.ticketUrl.isNotEmpty) {
//               final uri = Uri.parse(widget.party.ticketUrl);
//               NetworkUtils.launchInBrowser(uri);
//             } else {
//               Logx.ilt(_TAG, 'bloc app is required to purchase this ticket');
//               DialogUtils.showDownloadAppTixDialog(context);
//             }
//           } else {
//             //navigate to purchase tix screen
//             Tix tix = Dummy.getDummyTix();
//             tix = tix.copyWith(partyId: widget.party.id);
//
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                   builder: (context) =>
//                       TixBuyEditScreen(tix: tix, task: 'buy')),
//             );
//           }
//
//           if (UserPreferences.isUserLoggedIn()) {
//             User user = UserPreferences.myUser;
//
//             FirestoreHelper.pullHistoryMusic(user.id, widget.party.genre)
//                 .then((res) {
//               if (res.docs.isEmpty) {
//                 // no history, add new one
//                 HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
//                 historyMusic.userId = user.id;
//                 historyMusic.genre = widget.party.genre;
//                 historyMusic.count = 1;
//                 FirestoreHelper.pushHistoryMusic(historyMusic);
//               } else {
//                 if (res.docs.length > 1) {
//                   // that means there are multiple, so consolidate
//                   HistoryMusic hm = Dummy.getDummyHistoryMusic();
//                   int totalCount = 0;
//
//                   for (int i = 0; i < res.docs.length; i++) {
//                     DocumentSnapshot document = res.docs[i];
//                     Map<String, dynamic> data =
//                     document.data()! as Map<String, dynamic>;
//                     final HistoryMusic historyMusic =
//                     Fresh.freshHistoryMusicMap(data, false);
//
//                     totalCount += historyMusic.count;
//                     if (i == 0) {
//                       hm = historyMusic;
//                     }
//                     FirestoreHelper.deleteHistoryMusic(historyMusic.id);
//                   }
//
//                   totalCount = totalCount + 1;
//                   hm = hm.copyWith(count: totalCount);
//                   FirestoreHelper.pushHistoryMusic(hm);
//                 } else {
//                   DocumentSnapshot document = res.docs[0];
//                   Map<String, dynamic> data =
//                   document.data()! as Map<String, dynamic>;
//                   HistoryMusic historyMusic =
//                   Fresh.freshHistoryMusicMap(data, false);
//                   int newCount = historyMusic.count + 1;
//
//                   historyMusic = historyMusic.copyWith(count: newCount);
//                   FirestoreHelper.pushHistoryMusic(historyMusic);
//                 }
//               }
//             });
//           }
//         },
//         label: const Text(
//           'ticket',
//           style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Constants.darkPrimary),
//         ),
//         icon: const Icon(
//           Icons.star,
//           size: 22.0,
//         ),
//       ),
//     );
//   } else if (!widget.party.isTBA && widget.party.ticketUrl.isNotEmpty) {
//     return Container(
//       height: 50,
//       width: 160,
//       padding: const EdgeInsets.only(bottom: 1, top: 1),
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Constants.primary,
//           foregroundColor: Constants.background,
//           shadowColor: Colors.white30,
//           elevation: 3,
//         ),
//         onPressed: () {
//           final uri = Uri.parse(widget.party.ticketUrl);
//           NetworkUtils.launchInBrowser(uri);
//
//           if (UserPreferences.isUserLoggedIn()) {
//             User user = UserPreferences.myUser;
//
//             FirestoreHelper.pullHistoryMusic(user.id, widget.party.genre)
//                 .then((res) {
//               if (res.docs.isEmpty) {
//                 // no history, add new one
//                 HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
//                 historyMusic.userId = user.id;
//                 historyMusic.genre = widget.party.genre;
//                 historyMusic.count = 1;
//                 FirestoreHelper.pushHistoryMusic(historyMusic);
//               } else {
//                 if (res.docs.length > 1) {
//                   // that means there are multiple, so consolidate
//                   HistoryMusic hm = Dummy.getDummyHistoryMusic();
//                   int totalCount = 0;
//
//                   for (int i = 0; i < res.docs.length; i++) {
//                     DocumentSnapshot document = res.docs[i];
//                     Map<String, dynamic> data =
//                     document.data()! as Map<String, dynamic>;
//                     final HistoryMusic historyMusic =
//                     Fresh.freshHistoryMusicMap(data, false);
//
//                     totalCount += historyMusic.count;
//                     if (i == 0) {
//                       hm = historyMusic;
//                     }
//                     FirestoreHelper.deleteHistoryMusic(historyMusic.id);
//                   }
//
//                   totalCount = totalCount + 1;
//                   hm = hm.copyWith(count: totalCount);
//                   FirestoreHelper.pushHistoryMusic(hm);
//                 } else {
//                   DocumentSnapshot document = res.docs[0];
//                   Map<String, dynamic> data =
//                   document.data()! as Map<String, dynamic>;
//                   HistoryMusic historyMusic =
//                   Fresh.freshHistoryMusicMap(data, false);
//                   int newCount = historyMusic.count + 1;
//
//                   historyMusic = historyMusic.copyWith(count: newCount);
//                   FirestoreHelper.pushHistoryMusic(historyMusic);
//                 }
//               }
//             });
//           }
//         },
//         label: const Text(
//           'ticket',
//           style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Constants.darkPrimary),
//         ),
//         icon: const Icon(
//           Icons.star_half,
//           size: 22.0,
//         ),
//       ),
//     );
//   } else if (isGuestListActive) {
//     if (isGuestListRequested) {
//       return Container(
//         height: 50,
//         width: 160,
//         padding: const EdgeInsets.only(bottom: 1, top: 1),
//         child: ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Constants.primary,
//             foregroundColor: Constants.background,
//             shadowColor: Colors.white30,
//             elevation: 3,
//             // minimumSize: const Size.fromHeight(60),
//           ),
//           onPressed: () {
//             GoRouter.of(context).pushNamed(RouteConstants.boxOfficeRouteName);
//           },
//           icon: const Icon(
//             Icons.keyboard_command_key_sharp,
//             size: 22.0,
//           ),
//           label: const Text(
//             'box office',
//             style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Constants.darkPrimary),
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         height: 50,
//         width: 160,
//         padding: const EdgeInsets.only(bottom: 1, top: 1),
//         child: ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Constants.primary,
//             foregroundColor: Constants.background,
//             shadowColor: Colors.white30,
//             elevation: 3,
//             // minimumSize: const Size.fromHeight(60),
//           ),
//           onPressed: () {
//             PartyGuest partyGuest = Dummy.getDummyPartyGuest(true);
//             partyGuest.partyId = widget.party.id;
//
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                   builder: (context) => PartyGuestAddEditManageScreen(
//                       partyGuest: partyGuest, party: widget.party, task: 'add')),
//             );
//           },
//           icon: const Icon(
//             Icons.app_registration,
//             size: 22.0,
//           ),
//           label: const Text(
//             'guest list',
//             style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Constants.darkPrimary),
//           ),
//         ),
//       );
//     }
//   } else {
//     return const SizedBox();
//   }
// }
//
// _showGuestListMiniButton(BuildContext context) {
//   return Container(
//     height: 40,
//     width: 100,
//     padding: const EdgeInsets.only(left: 5),
//     child: ElevatedButton.icon(
//       style: ElevatedButton.styleFrom(
//           backgroundColor: Constants.primary,
//           foregroundColor: Constants.background,
//           shadowColor: Colors.white30,
//           elevation: 3,
//           padding: EdgeInsets.only(left: 5, right: 5)
//       ),
//       onPressed: () {
//         PartyGuest partyGuest = Dummy.getDummyPartyGuest(true);
//         partyGuest.partyId = widget.party.id;
//
//         Navigator.of(context).push(
//           MaterialPageRoute(
//               builder: (context) => PartyGuestAddEditManageScreen(
//                   partyGuest: partyGuest, party: widget.party, task: 'add')),
//         );
//       },
//       icon: const Icon(Icons.app_registration, size: 19,),
//       label: const Text(
//         'guest',
//         maxLines: 1,
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Constants.darkPrimary),
//       ),
//     ),
//   );
// }
}
