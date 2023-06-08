import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/scan_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/logx.dart';
import '../../widgets/box_office/box_office_item.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';

class PromoterGuestsScreen extends StatefulWidget {
  final Party party;

  const PromoterGuestsScreen(
      {Key? key,
        required this.party})
      : super(key: key);

  @override
  State<PromoterGuestsScreen> createState() => _PromoterGuestsScreenState();
}

class _PromoterGuestsScreenState extends State<PromoterGuestsScreen> {
  static const String _TAG = 'PromoterGuestsScreen';

  late List<String> mOptions;
  late String sOption;

  @override
  void initState() {
    mOptions = ['arriving', 'completed'];
    sOption = mOptions.first;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bloc | promoter box office'),
      ),
      floatingActionButton:
      !kIsWeb
          ? FloatingActionButton(
        onPressed: () {
          ScanUtils.scanCode(context);
          // scanCode();
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'scan code',
        elevation: 5,
        splashColor: Colors.grey,
        child: Icon(
          Icons.qr_code_scanner,
          color: Theme.of(context).primaryColorDark,
          size: 29,
        ),
      )
          : const SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          displayBoxOfficeOptions(context),
          const Divider(),
          buildGuestsList(context)
        ],
      ),
    );
  }

  displayBoxOfficeOptions(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 15,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                    Logx.i(_TAG, '$sOption at box office is selected');
                  });
                });
          }),
    );
  }

  buildGuestsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getPartyGuestsByPartyId(widget.party.id),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasData) {
          List<PartyGuest> arrivingRequests = [];
          List<PartyGuest> completedRequests = [];

          if (snapshot.data!.docs.isEmpty) {
            return const Expanded(
                child: Center(child: Text('no guest list requests found!')));
          } else {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
              final PartyGuest partyGuest = Fresh.freshPartyGuestMap(map, false);

              if (partyGuest.guestsRemaining == 0) {
                completedRequests.add(partyGuest);
              } else {
                arrivingRequests.add(partyGuest);
              }

              if (i == snapshot.data!.docs.length - 1) {
                return displayGuests(
                    context,
                    sOption == mOptions.first
                        ? arrivingRequests
                        : completedRequests);
              }
            }
          }
        } else {
          return const Expanded(
              child: Center(child: Text('no guest list requests found!')));
        }
        return const LoadingWidget();
      },
    );
  }


  displayGuests(BuildContext context, List<PartyGuest> guests) {
    return Expanded(
      child: ListView.builder(
        itemCount: guests.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          return BoxOfficeItem(
            partyGuest: guests[index],
            party: widget.party,
            isClickable: true,
            challenges: [],
          );
        },
      ),
    );
  }
}

