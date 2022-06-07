import 'package:bloc/screens/forms/new_product_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/manager_service.dart';
import '../../../db/entity/product.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/manager/manage_product_item.dart';

class ManageProductsScreen extends StatelessWidget {
  String serviceId;
  BlocDao dao;
  ManagerService managerService;

  ManageProductsScreen(
      {required this.serviceId,
      required this.dao,
      required this.managerService});

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
                    NewProductScreen(serviceId: serviceId, dao: dao)),
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
      body: _buildProducts(context),
    );
  }

  _buildProducts(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getProducts(serviceId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Product> _products = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Product _product = Product.fromMap(map);
            _products.add(_product);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayProducts(context, _products);
            }
          }
          return Center(child: Text('loading products...'));
        });
  }

  _displayProducts(BuildContext context, List<Product> _products) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: _products.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageProductItem(
                  serviceId: serviceId,
                  product: _products[index],
                  dao: dao,
                ),
                onTap: () {
                  Product _sProduct = _products[index];
                  print(_sProduct.name + ' is selected');

                  // if(_sInvOption.title.contains('Price')){
                  //   Navigator.of(context).push(MaterialPageRoute(
                  //       builder: (ctx) => ManagePriceScreen(
                  //           serviceId: serviceId,
                  //           managerService: managerService,
                  //           dao: dao)));
                  //   print('manage inventory screen selected.');
                  // } else {
                  //   Navigator.of(context).push(MaterialPageRoute(
                  //       builder: (ctx) => ManageCategoryScreen(
                  //           serviceId: serviceId,
                  //           managerService: managerService,
                  //           dao: dao)));
                  //   print('manage category screen selected.');
                  // }
                });
          }),
    );
  }
}
