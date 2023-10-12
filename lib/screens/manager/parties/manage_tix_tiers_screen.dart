import 'package:bloc/db/entity/party_tix_tier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../widgets/manager/manage_tix_tier_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';
import 'party_tix_tier_add_edit_screen.dart';

class ManageTixTiersScreen extends StatelessWidget {
  static const String _TAG = 'ManageTixTiersScreen';

  String partyId;

  ManageTixTiersScreen({
    Key? key,
    required this.partyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title: 'manage tix tiers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => PartyTixTierAddEditScreen(
                      tixTier: Dummy.getDummyPartyTixTier(partyId),
                      task: 'add',
                    )),
          );
        },
        backgroundColor: Constants.primary,
        tooltip: 'add tix tier',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildTixTiers(context),
    );
  }

  _buildTixTiers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getPartyTixTiers(partyId),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<PartyTixTier> tixTiers = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map =
                      document.data()! as Map<String, dynamic>;
                  final PartyTixTier tixTier =
                      Fresh.freshPartyTixTierMap(map, false);
                  tixTiers.add(tixTier);
                }
                return _displayTixTiers(context, tixTiers);
              }
          }
        });
  }

  _displayTixTiers(BuildContext context, List<PartyTixTier> tixTiers) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: tixTiers.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageTixTierItem(
                  partyTixTier: tixTiers[index],
                ),
                onTap: () {
                  PartyTixTier sTixTier = tixTiers[index];

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => PartyTixTierAddEditScreen(
                              tixTier: sTixTier,
                              task: 'edit',
                            )),
                  );
                });
          }),
    );
  }
}
