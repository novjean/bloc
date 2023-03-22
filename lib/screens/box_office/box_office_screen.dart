import 'package:bloc/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../widgets/box_office/box_office_item.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../../widgets/ui/toaster.dart';
import '../parties/manage_party_ticket_screen.dart';

class BoxOfficeScreen extends StatefulWidget {
  @override
  State<BoxOfficeScreen> createState() => _BoxOfficeScreenState();
}

class _BoxOfficeScreenState extends State<BoxOfficeScreen> {
  List<Party> mParties = [];
  var _isPartiesLoading = true;

  List<String> mOptions = ['guest list', 'tickets'];
  String sOption = 'guest list';

  @override
  void initState() {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    FirestoreHelper.pullPartiesByEndTime(timeNow, true).then((res) {
      print("successfully pulled in parties");

      if (res.docs.isNotEmpty) {
        List<Party> parties = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          parties.add(party);

          setState(() {
            mParties = parties;
            _isPartiesLoading = false;
          });
        }
      } else {
        print('no parties found!');
        setState(() {
          _isPartiesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = UserPreferences.myUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('bloc | box office'),
      ),

      floatingActionButton: (user.clearanceLevel>=Constants.PROMOTER_LEVEL && !kIsWeb)? FloatingActionButton(
        onPressed: () {
          scanCode();
        },
        child: Icon(
          Icons.qr_code_scanner,
          color: Theme.of(context).primaryColorDark,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'scan code',
        elevation: 5,
        splashColor: Colors.grey,
      ): const SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartiesLoading
        ? const LoadingWidget()
        : Padding(
            padding:
                const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                displayBoxOfficeOptions(context),
                const Divider(),
                buildUserPartyGuestList(context)
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
                    print(sOption + ' at box office is selected');
                  });
                });
          }),
    );
  }

  buildUserPartyGuestList(BuildContext context) {
    return sOption == mOptions.first? StreamBuilder<QuerySnapshot>(
      stream:
          FirestoreHelper.getPartyGuestListByUser(UserPreferences.getUser().id),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasData) {
          List<PartyGuest> partyGuestRequests = [];
          if(snapshot.data!.docs.isEmpty){
            return const Expanded(
                child: Center(child: Text('no guest list requests found!')));
          } else {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
              final PartyGuest partyGuest = Fresh.freshPartyGuestMap(map, false);
              partyGuestRequests.add(partyGuest);

              if (i == snapshot.data!.docs.length - 1) {
                return _displayPartyGuestListRequests(
                    context, partyGuestRequests);
              }
            }
          }
        } else {
          return const Expanded(
              child: Center(child: Text('no guest list requests found!')));
        }
        return const LoadingWidget();
      },
    ) : Expanded(child: Center(child: Text('no tickets here!'),));
  }

  _displayPartyGuestListRequests(
      BuildContext context, List<PartyGuest> requests) {
    return Expanded(
      child: ListView.builder(
        itemCount: requests.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          PartyGuest sPartyGuest = requests[index];
          Party sParty = Dummy.getDummyParty('');

          for(Party party in mParties){
            if(party.id == sPartyGuest.partyId){
              sParty = party;
              break;
            }
          }

          if(!sParty.isActive){
            // the party is over, so the request should be deleted
            FirestoreHelper.deletePartyGuest(sPartyGuest);
            return const SizedBox();
          } else {
            return BoxOfficeItem(partyGuest: sPartyGuest, party: sParty, isClickable: true,);
          }
        },
      ),
    );
  }

  void scanCode() async {
    String scanCode;

    try {
      scanCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'cancel', true, ScanMode.QR);
      print('code scanned ' + scanCode);
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (ctx) =>
                ManagePartyTicketScreen(partyGuestId: scanCode,)),
      );
    } on PlatformException {
      scanCode = 'failed to get platform version.';
    } catch(e){
      Toaster.longToast('code scan failed');
    }

    if (!mounted) return;

  }
}
