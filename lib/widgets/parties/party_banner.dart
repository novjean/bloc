import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/network_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../screens/parties/artist_screen.dart';
import '../../utils/string_utils.dart';

class PartyBanner extends StatelessWidget {
  final Party party;
  final bool isClickable;
  final bool shouldShowButton;

  const PartyBanner(
      {Key? key,
      required this.party,
      required this.isClickable,
      required this.shouldShowButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isClickable
            ? Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => ArtistScreen(party: party)),
              )
            : print('party banner no click');
      },
      child: Hero(
        tag: party.id,
        child: Card(
          elevation: 1,
          color: Theme.of(context).primaryColorLight,
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
          child: SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 3, left: 5.0, right: 0.0),
                        child: Text(
                          party.name.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      party.eventName.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                party.eventName.toLowerCase(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          party.isTBA
                              ? 'tba'
                              : DateTimeUtils.getFormattedDate(party.startTime),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          party.isTBA
                              ? ''
                              : DateTimeUtils.getFormattedTime(party.startTime),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),

                      shouldShowButton
                          ? party.isTBA
                              ? showListenOrInstaDialog(context)
                              : party.ticketUrl.isNotEmpty
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).highlightColor,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.white30,
                                          elevation: 3,

                                          minimumSize: const Size.fromHeight(
                                              60), //////// HERE
                                        ),
                                        onPressed: () {
                                          final uri =
                                              Uri.parse(party.ticketUrl);
                                          NetworkUtils.launchInBrowser(uri);
                                        },
                                        child: Text(
                                          'tickets',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                      ),
                                    )
                                  : showListenOrInstaDialog(context)
                          : party.description.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5),
                                  child: Text(
                                    StringUtils.firstFewWords(
                                            party.description.toLowerCase(),
                                            30) +
                                        (StringUtils.getWordCount(
                                                    party.description) >
                                                30
                                            ? ' ...'
                                            : ''),
                                    style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  ),
                                )
                              : const SizedBox(),
                    ],
                  ),
                  flex: 2,
                ),
                Flexible(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      image: DecorationImage(
                        image: NetworkImage(party.imageUrl),
                        fit: BoxFit.fitHeight,
                        // AssetImage(food['image']),
                      ),
                    ),
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showListenOrInstaDialog(BuildContext context) {
    bool isListen = party.listenUrl.isNotEmpty;
    bool isInsta = party.instagramUrl.isNotEmpty;

    if (!isListen && !isInsta) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).highlightColor,
          foregroundColor: Colors.white,
          shadowColor: Colors.white30,
          elevation: 3,
          minimumSize: const Size.fromHeight(60),
        ),
        onPressed: () {
          final uri =
              Uri.parse(isListen ? party.listenUrl : party.instagramUrl);
          NetworkUtils.launchInBrowser(uri);
        },
        child: Text(
          isListen ? 'listen' : 'social',
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}