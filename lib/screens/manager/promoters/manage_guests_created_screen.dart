import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/party_guest.dart';
import '../../../db/entity/promoter.dart';
import '../../../widgets/parties/party_guest_widget.dart';

class ManageGuestsCreatedScreen extends StatelessWidget {
  List<PartyGuest> partyGuests;
  List<Promoter> promoters;

  ManageGuestsCreatedScreen({Key? key, required this.partyGuests, required this.promoters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title: 'guests confirm'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: partyGuests.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) {
                    return PartyGuestWidget(
                      partyGuest: partyGuests[index],
                      promoters: promoters,
                    );
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ButtonWidget(text: '🚀 done', onClicked: () {
              Navigator.of(context).pop();
            },),
          ),
        ],
      ),
    );
  }
}