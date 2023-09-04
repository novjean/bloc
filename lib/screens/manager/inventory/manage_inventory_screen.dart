import 'package:bloc/db/entity/inventory_option.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/manager_service.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/logx.dart';
import '../../../widgets/manager/manage_inventory_option_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import 'manage_category_screen.dart';
import 'manage_offers_screen.dart';
import 'manage_products_screen.dart';

class ManageInventoryScreen extends StatelessWidget{
  static const String _TAG = 'ManageInventoryScreen';
  String serviceId;
  ManagerService managerService;

  ManageInventoryScreen({super.key,
    required this.serviceId,
    required this.managerService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title:'manage inventory'),
        titleSpacing: 0,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 5.0),
          _buildInventoryOptions(context),
          const SizedBox(height: 5.0),
        ],
      ),
    );
  }

  _buildInventoryOptions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getInventoryOptions(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<InventoryOption> _invOptions = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map =
                  document.data()! as Map<String, dynamic>;
                  final InventoryOption _invOption = InventoryOption.fromMap(map);
                  _invOptions.add(_invOption);
                }
                return _displayInventoryOptions(context, _invOptions);
              }
          }
        });
  }

  _displayInventoryOptions(BuildContext context, List<InventoryOption> inventoryOptions) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: inventoryOptions.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageInventoryOptionItem(
                  inventoryOption: inventoryOptions[index],
                ),
                onTap: () {
                  InventoryOption sInvOption = inventoryOptions[index];
                  if(sInvOption.title.contains('Products')){
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ManageProductsScreen(
                            serviceId: serviceId,
                            managerService: managerService)));
                    Logx.i(_TAG, 'manage inventory screen selected.');
                  } else if(sInvOption.title.contains('Categories')) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ManageCategoryScreen(
                            serviceId: serviceId)));
                    Logx.i(_TAG, 'manage category screen selected.');
                  } else if(sInvOption.title.contains('Offers')) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ManageOffersScreen(
                            serviceId: serviceId)));
                    Logx.i(_TAG, 'manage category screen selected.');
                  }
                  else {
                    Logx.i(_TAG, 'undefined inventory option!');
                  }
                });
          }),
    );
  }


}