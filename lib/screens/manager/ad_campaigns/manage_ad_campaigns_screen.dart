import 'package:bloc/db/entity/ad_campaign.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/ad.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/logx.dart';
import '../../../widgets/manager/manage_ad_campaign_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/listview_block.dart';
import '../../../widgets/ui/loading_widget.dart';
import 'ad_campaign_add_edit_screen.dart';

class ManageAdCampaignsScreen extends StatelessWidget {
  static const String _TAG = 'ManageAdCampaignsScreen';

  String serviceId;

  ManageAdCampaignsScreen({Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title:'manage ad campaigns'),
        titleSpacing: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => AdCampaignAddEditScreen(
                  adCampaign: Dummy.getDummyAdCampaign(),
                  task: 'add',
                )),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'add ad campaign',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildAdCampaigns(context),
    );
  }

  // Widget _buildBody(BuildContext context) {
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         const SizedBox(height: 5.0),
  //         _buildAdCampaigns(context),
  //         const SizedBox(height: 5.0),
  //       ],
  //     ),
  //   );
  // }

  _buildAdCampaigns(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getAdCampaigns(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done: {
            List<AdCampaign> adCampaigns = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
              final AdCampaign adCampaign = Fresh.freshAdCampaignMap(map, false);
              adCampaigns.add(adCampaign);
            }
            return _displayAdCampaigns(context, adCampaigns);
          }
          }
        });
  }

  _displayAdCampaigns(BuildContext context, List<AdCampaign> adCampaigns) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: adCampaigns.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageAdCampaignItem(
                  adCampaign: adCampaigns[index],
                ),
                onTap: () {
                  AdCampaign sAdCampaign = adCampaigns[index];
                  Logx.i(_TAG, '${sAdCampaign.name} : ${sAdCampaign.adClick}');

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => AdCampaignAddEditScreen(
                          adCampaign: sAdCampaign,
                          task: 'edit',
                        )),
                  );
                });
          }),
    );
  }
}
