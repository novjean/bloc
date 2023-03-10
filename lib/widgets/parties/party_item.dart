import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../screens/parties/artist_screen.dart';
import '../../utils/network_utils.dart';
import '../../utils/string_utils.dart';
import '../ui/dark_button_widget.dart';

class PartyItem extends StatelessWidget {
  final Party party;
  final double imageHeight;

  int addCount = 1;

  PartyItem({required this.party, required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //handled in parent
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => ArtistScreen(party: party)),
        );
      },
      child: Hero(
        tag: party.id,
        child: Card(
          color: Theme.of(context).primaryColorLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Stack(
                  children: [
                    Container(
                      height: imageHeight,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        image: DecorationImage(
                          image: NetworkImage(party.imageUrl),
                          fit: BoxFit.fitWidth,
                          // AssetImage(food['image']),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5.0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  "${party.name.toLowerCase()}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                flex: 1,
                              ),
                            ]),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      party.eventName.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    party.eventName.toLowerCase(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          party.isTBA
                              ? 'tba'
                              : DateTimeUtils.getFormattedDate(party.startTime),
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    ]),
                const SizedBox(height: 5.0),
                party.description.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                            StringUtils.firstFewWords(
                                    party.description.toLowerCase(), 30) +
                                (StringUtils.getWordCount(party.description) >
                                        30
                                    ? ' ...'
                                    : ''),
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).primaryColorDark)),
                      )
                    : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    party.listenUrl.isNotEmpty
                        ? DarkButtonWidget(
                            text: 'listen',
                            onClicked: () {
                              final uri = Uri.parse(party.listenUrl);
                              NetworkUtils.launchInBrowser(uri);
                            })
                        : const SizedBox(),
                    const SizedBox(width: 10),
                    party.instagramUrl.isNotEmpty
                        ? DarkButtonWidget(
                            text: 'social',
                            onClicked: () {
                              final uri = Uri.parse(party.instagramUrl);
                              NetworkUtils.launchInBrowser(uri);
                            })
                        : const SizedBox(),
                    const SizedBox(width: 10),
                    party.ticketUrl.isNotEmpty
                        ? DarkButtonWidget(
                            text: 'tickets',
                            onClicked: () {
                              final uri = Uri.parse(party.ticketUrl);
                              NetworkUtils.launchInBrowser(uri);
                            })
                        : const SizedBox(),
                    const SizedBox(width: 15),
                  ],
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
