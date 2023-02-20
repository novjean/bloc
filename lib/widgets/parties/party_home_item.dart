import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../db/entity/party.dart';

class PartyHomeItem extends StatelessWidget {
  final Party party;

  int addCount = 1;

  PartyHomeItem({required this.party});

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // handled by parent
      },
      child: Hero(
        tag: party.id,
        child: Card(
          elevation: 1,
          color: Theme.of(context).primaryColorLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
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
                        padding: EdgeInsets.only(top: 3, left: 5.0, right: 0.0),
                        child: Text(
                          "${party.name.toLowerCase()}",
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
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

                      party.isTBA
                          ? showListenOrInstaDialog(context)
                          : party.ticketUrl.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context).highlightColor,
                                      onPrimary: Colors.white,
                                      shadowColor: Colors.white30,
                                      elevation: 3,

                                      minimumSize:
                                          Size.fromHeight(60), //////// HERE
                                    ),
                                    onPressed: () {
                                      final uri = Uri.parse(party.ticketUrl);
                                      _launchInBrowser(uri);
                                    },
                                    child: Text(
                                      'tickets',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                )
                              : showListenOrInstaDialog(context),

                      // ButtonWidget(text: 'Tickets', onClicked: () {
                      //   final uri = Uri.parse(party.ticketUrl);
                      //   _launchInBrowser(uri);
                      // }),
                      SizedBox(width: 0),
                    ],
                  ),
                  flex: 2,
                ),
                Flexible(
                  child: Container(
                    height: 190,
                    width: 190,
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
    bool isListen =  party.listenUrl.isNotEmpty;
    bool isInsta = party.instagramUrl.isNotEmpty;

    if(!isListen && !isInsta){
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).highlightColor,
          onPrimary: Colors.white,
          shadowColor: Colors.white30,
          elevation: 3,

          minimumSize: Size.fromHeight(60), //////// HERE
        ),
        onPressed: () {
          final uri = Uri.parse(isListen?party.listenUrl:party.instagramUrl);
          _launchInBrowser(uri);
        },
        child: Text(
          isListen? 'listen':'social',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
