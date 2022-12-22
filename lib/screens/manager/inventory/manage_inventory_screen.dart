import 'package:bloc/db/entity/inventory_option.dart';
import 'package:bloc/widgets/ui/listview_block.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/manager_service.dart';
import '../../../helpers/firestore_helper.dart';
import 'manage_category_screen.dart';
import 'manage_offers_screen.dart';
import 'manage_products_screen.dart';

class ManageInventoryScreen extends StatelessWidget{
  String serviceId;
  BlocDao dao;
  ManagerService managerService;

  ManageInventoryScreen({
    required this.serviceId,
    required this.dao,
    required this.managerService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager | Inventory'),
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
          _buildInventoryOptions(context),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  _buildInventoryOptions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getInventoryOptions(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<InventoryOption> _invOptions = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map =
            document.data()! as Map<String, dynamic>;
            final InventoryOption _invOption = InventoryOption.fromMap(map);
            _invOptions.add(_invOption);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayInventoryOptions(context, _invOptions);
            }
          }
          return Center(child: Text('loading inventory options...'));
        });
  }

  _displayInventoryOptions(BuildContext context, List<InventoryOption> _invOptions) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: _invOptions.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ListViewBlock(
                  title: _invOptions[index].title,
                ),
                onTap: () {
                  InventoryOption _sInvOption = _invOptions[index];

                  if(_sInvOption.title.contains('Products')){
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ManageProductsScreen(
                            serviceId: serviceId,
                            managerService: managerService,
                            dao: dao)));
                    print('manage inventory screen selected.');
                  } else if(_sInvOption.title.contains('Categories')) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ManageCategoryScreen(
                            serviceId: serviceId,
                            // managerService: managerService,
                            dao: dao)));
                    print('manage category screen selected.');
                  } else if(_sInvOption.title.contains('Offers')) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ManageOffersScreen(
                            serviceId: serviceId,
                            dao: dao)));
                    print('manage category screen selected.');
                  }
                  else {
                    print('Undefined inventory option!');
                  }
                });
          }),
    );
  }


}