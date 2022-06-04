import 'package:bloc/db/entity/category.dart';
import 'package:bloc/widgets/ui/listview_block.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/dao/bloc_dao.dart';
import '../../../helpers/firestore_helper.dart';
import '../../forms/new_service_category_screen.dart';

class ManageCategoryScreen extends StatelessWidget {
  String serviceId;
  BlocDao dao;

  ManageCategoryScreen({
    required this.serviceId,
    required this.dao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory | Category'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => NewServiceCategoryScreen(
                    serviceId: serviceId, dao: dao)),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'New Bloc',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.0),
          _buildCategories(context),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  _buildCategories(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCategories(serviceId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Category> _categories = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Category _category = Category.fromMap(map);
            _categories.add(_category);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayCategories(context, _categories);
            }
          }
          return Center(child: Text('loading categories...'));
        });
  }

  _displayCategories(BuildContext context, List<Category> _categories) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: _categories.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ListViewBlock(
                  title: _categories[index].name,
                ),
                onTap: () {
                  Category _sCategory = _categories[index];
                  print(_sCategory.name + ' is selected');

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
