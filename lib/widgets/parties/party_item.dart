import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../db/entity/party.dart';

class PartyItem extends StatelessWidget {
  final Party party;
  final double imageHeight;

  int addCount = 1;

  PartyItem({required this.party, required this.imageHeight});

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
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
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                  EdgeInsets.only(top: 10, left: 15.0, right: 15.0),
                  child: Text(
                    "${party.name}",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text('Date : ' + DateTimeUtils.getFormattedDateString(party.startTime)),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonWidget(text: 'Instagram', onClicked: () {
                      final uri = Uri.parse(party.instagramUrl);
                      _launchInBrowser(uri);
                    }),
                    SizedBox(width: 10),
                    ButtonWidget(text: 'Tickets', onClicked: () {
                      final uri = Uri.parse(party.ticketUrl);
                      _launchInBrowser(uri);
                    }),
                    SizedBox(width: 15),
                  ],
                ),
                SizedBox(height: 7.0),

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
