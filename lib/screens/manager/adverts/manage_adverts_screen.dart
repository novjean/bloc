import 'package:bloc/widgets/manager/manage_ad_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/ad.dart';
import '../../../db/entity/advert.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../widgets/manager/manage_advert_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';
import '../../advertise/advert_add_edit_screen.dart';

class ManageAdvertsScreen extends StatelessWidget {
  static const String _TAG = 'ManageAdvertsScreen';

  String serviceId;

  ManageAdvertsScreen({Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title:'manage adverts'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => AdvertAddEditScreen(
                  advert: Dummy.getDummyAdvert(),
                  task: 'add',
                )),
          );
        },
        backgroundColor: Constants.primary,
        tooltip: 'add advert',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildAdverts(context),
    );
  }

  _buildAdverts(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getAdverts(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<Advert> ads = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map = document.data()! as Map<
                      String,
                      dynamic>;
                  final Advert _ad = Fresh.freshAdvertMap(map, false);
                  ads.add(_ad);
                }
                return _displayAdverts(context, ads);
              }
          }
        });
  }

  _displayAdverts(BuildContext context, List<Advert> ads) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: ads.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageAdvertItem(
                  advert: ads[index],
                ),
                onTap: () {
                  Advert sAd = ads[index];

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => AdvertAddEditScreen(
                          advert: sAd,
                          task: 'manage',
                        )),
                  );
                });
          }),
    );
  }
}
