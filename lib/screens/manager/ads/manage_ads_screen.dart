import 'package:bloc/widgets/manager/manage_ad_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/ad.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/logx.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';
import 'ad_add_edit_screen.dart';

class ManageAdsScreen extends StatelessWidget {
  static const String _TAG = 'ManageAdsScreen';

  String serviceId;

  ManageAdsScreen({Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title:'manage ads'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => AdAddEditScreen(
                  ad: Dummy.getDummyAd(serviceId),
                  task: 'add',
                )),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'add ad',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildAds(context),
    );
  }

  _buildAds(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getAds(serviceId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          List<Ad> _ads = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Ad _ad = Fresh.freshAdMap(map, false);
            _ads.add(_ad);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayAds(context, _ads);
            }
          }
          Logx.i(_TAG, 'loading ads...');
          return const LoadingWidget();
        });
  }

  _displayAds(BuildContext context, List<Ad> ads) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: ads.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageAdItem(
                  ad: ads[index],
                ),
                onTap: () {
                  Ad sAd = ads[index];

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => AdAddEditScreen(
                          ad: sAd,
                          task: 'edit',
                        )),
                  );
                });
          }),
    );
  }
}
