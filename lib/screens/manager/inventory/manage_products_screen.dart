import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/screens/manager/inventory/add_product_screen.dart';
import 'package:bloc/screens/manager/inventory/product_add_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/manager_service.dart';
import '../../../db/entity/product.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/manager/manage_product_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';

class ManageProductsScreen extends StatefulWidget {
  String serviceId;
  BlocDao dao;
  ManagerService managerService;

  ManageProductsScreen(
      {required this.serviceId,
      required this.dao,
      required this.managerService});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  String _selectedType = 'Alcohol';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory | Products'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) =>
                    ProductAddScreen(blocServiceId: widget.serviceId,
                      product: Dummy.getDummyProduct(widget.serviceId, UserPreferences.myUser.id),)),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Add Product',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2.0),
        _displayOptions(context),
        const Divider(),
        const SizedBox(height: 2.0),
        _buildProducts(context),
        const SizedBox(height: 2.0),
      ],
    );
  }

  _displayOptions(BuildContext context) {
    List<String> _options = ['Alcohol', 'Food'];
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: containerHeight,
      child: ListView.builder(
          itemCount: _options.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: _options[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 2,
                ),
                onTap: () {
                  setState(() {
                    // _sCategory = categories[index];
                    _selectedType = _options[index];
                    print(_selectedType + ' products display option is selected.');
                  });
                });
          }),
    );
  }

  _buildProducts(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getProductsByType(widget.serviceId, _selectedType),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Product> _products = [];

          if(!snapshot.hasData){
            return Center(child: Text('No products found!'));
          }

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Product _product = Product.fromMap(map);
            _products.add(_product);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayProductsList(context, _products);
            }
          }
          return Center(child: Text('loading products...'));
        });
  }

  _displayProductsList(BuildContext context, List<Product> _products) {
    return Expanded(
      child: ListView.builder(
          itemCount: _products.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageProductItem(
                  serviceId: widget.serviceId,
                  product: _products[index],
                ),
                onTap: () {
                  Product _sProduct = _products[index];
                  print(_sProduct.name + ' is selected');
                });
          }),
    );
  }

}
