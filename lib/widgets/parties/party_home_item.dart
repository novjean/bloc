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
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //       builder: (ctx) =>
        //           BlocServiceDetailScreen(blocService: mBlocService)),
        // );
      },
      child: Hero(
        tag: party.id,
        child: Card(
          elevation: 1,
          color: Theme.of(context).primaryColorLight,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0)),
          child: SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
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
                    SizedBox(width: 0),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(DateTimeUtils.getFormattedDate(party.startTime),
                        style: const TextStyle(fontSize: 18),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(DateTimeUtils.getFormattedTime(party.startTime),
                        style: const TextStyle(fontSize: 18),),
                    ),
                    // ButtonWidget(text: 'Instagram', onClicked: () {
                    //   final uri = Uri.parse(party.instagramUrl);
                    //   _launchInBrowser(uri);
                    // }),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).highlightColor,
                        onPrimary: Colors.white,
                        shadowColor: Colors.white30,
                        elevation: 3,

                        minimumSize: Size(210, 60), //////// HERE
                      ),
                      onPressed: () {
                        final uri = Uri.parse(party.ticketUrl);
                        _launchInBrowser(uri);
                      },
                      child: Text(
                        'get tickets',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),

                    // ButtonWidget(text: 'Tickets', onClicked: () {
                    //   final uri = Uri.parse(party.ticketUrl);
                    //   _launchInBrowser(uri);
                    // }),
                    SizedBox(width: 0),
                  ],
                ),


                SizedBox(height: 0.0),
                Container(
                  height: 190,
                  width: 190,
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                    image: DecorationImage(
                      image: NetworkImage(party.imageUrl),
                      fit: BoxFit.fitWidth,
                      // AssetImage(food['image']),
                    ),
                  ),
                ),

                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   padding: EdgeInsets.only(
                //       top: 5, left: 15.0, right: 15.0, bottom: 5),
                //   child: Text(
                //     "${widget.bloc.addressLine1}, ${widget.bloc.addressLine2}",
                //     style: TextStyle(
                //       fontSize: 16.0,
                //       fontWeight: FontWeight.w300,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
