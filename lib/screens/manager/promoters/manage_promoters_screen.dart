import 'package:bloc/screens/manager/promoters/promoter_add_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/promoter.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/logx.dart';
import '../../../widgets/manager/manage_promoter_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';

class ManagePromotersScreen extends StatelessWidget {
  static const String _TAG = 'ManagePromotersScreen';

  ManagePromotersScreen({Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title:'manage promoters'),
        titleSpacing: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => PromoterAddEditScreen(
                  promoter: Dummy.getDummyPromoter(),
                  task: 'add',
                )),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'add promoter',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _buildPromoters(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _buildPromoters(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getPromoters(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<Promoter> _promoters = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map = document.data()! as Map<
                      String,
                      dynamic>;
                  final Promoter _promoter = Fresh.freshPromoterMap(map, false);
                  _promoters.add(_promoter);
                }
                return _displayPromoters(context, _promoters);
              }
          }
        });
  }

  _displayPromoters(BuildContext context, List<Promoter> promoters) {
    return Expanded(
      child: ListView.builder(
          itemCount: promoters.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManagePromoterItem(
                  promoter: promoters[index],
                ),
                onTap: () {
                  Promoter sPromoter = promoters[index];
                  Logx.i(_TAG, '${sPromoter.name}}');

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => PromoterAddEditScreen(
                          promoter: sPromoter,
                          task: 'edit',
                        )),
                  );
                });
          }),
    );
  }
}
