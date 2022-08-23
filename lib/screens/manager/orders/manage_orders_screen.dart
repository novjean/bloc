import 'package:bloc/db/entity/manager_service_option.dart';
import 'package:bloc/screens/manager/orders/orders_community_bar_screen.dart';
import 'package:bloc/widgets/ui/listview_block.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/dao/bloc_dao.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/Toaster.dart';
import 'orders_completed_screen.dart';
import 'orders_pending_screen.dart';

class ManageOrdersScreen extends StatelessWidget {
  String serviceId;
  BlocDao dao;
  String serviceName;
  String userTitle;

  ManageOrdersScreen({
    required this.serviceId,
    required this.dao,
    required this.serviceName,
    required this.userTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userTitle + ' | Orders'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.0),
          _buildOrderOptions(context),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  _buildOrderOptions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getManagerServiceOptions('Order'),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<ManagerServiceOption> _serviceOptions = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final ManagerServiceOption _option =
                ManagerServiceOption.fromMap(map);
            _serviceOptions.add(_option);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayServiceOptions(context, _serviceOptions);
            }
          }
          return Center(child: Text('loading service options...'));
        });
  }

  _displayServiceOptions(
      BuildContext context, List<ManagerServiceOption> _options) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: _options.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ListViewBlock(
                  title: _options[index].name,
                ),
                onTap: () {
                  ManagerServiceOption _option = _options[index];

                  if (_option.name.contains('Community Bar')) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => OrdersCommunityBarScreen(
                            serviceId: serviceId,
                            titleHead: serviceName,
                            dao: dao)));
                  } else if (_option.name.contains('Completed')) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => OrdersCompletedScreen(
                            serviceId: serviceId,
                            titleHead: serviceName,
                            dao: dao)));
                  } else if (_option.name.contains('Pending')) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => OrdersPendingScreen(
                            serviceId: serviceId,
                            titleHead: serviceName,
                            dao: dao)));
                  } else if (_option.name.contains('Community Bar')) {
                    Toaster.shortToast(
                        'Community bar is yet to be implemented!');
                    print('community bar order option selected!');
                  } else {
                    print('Undefined order service option!');
                  }
                });
          }),
    );
  }
}
