import 'package:bloc/screens/manager/tickets/manage_party_tixs_screen.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/party.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../widgets/parties/party_box_office_banner.dart';
import '../../../widgets/ui/loading_widget.dart';

class ManageTixsScreen extends StatefulWidget {

  const ManageTixsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ManageTixsScreenState();
}

class _ManageTixsScreenState extends State<ManageTixsScreen> {
  static const String _TAG = 'ManageTixsScreen';

  List<Party> mTixParties = [];
  var _isPartiesLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullPartiesTicketed().then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          mTixParties.add(party);
        }

        setState(() {
          _isPartiesLoading = false;
        });
      } else {
        setState(() {
          _isPartiesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title:'manage tixs'),
        titleSpacing: 0,
      ),
      body: _isPartiesLoading ? const LoadingWidget() : _buildBody(context)
    );
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _displayTixParties(context)
        ],
      ),
    );
  }

  _displayTixParties(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: mTixParties.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: PartyBoxOfficeBanner(
                  party: mTixParties[index],
                ),
                onTap: () {
                  Party sParty = mTixParties[index];

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ManagePartyTixsScreen(party: sParty)));
                });
          }),
    );
  }
}