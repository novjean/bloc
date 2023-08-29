import 'package:bloc/db/entity/category.dart';
import 'package:bloc/widgets/ui/listview_block.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../widgets/manager/manage_category_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import 'category_add_edit_screen.dart';

class ManageCategoryScreen extends StatelessWidget {
  String serviceId;

  ManageCategoryScreen({Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title:'manage category'),
        titleSpacing: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => CategoryAddEditScreen(
                  category: Dummy.getDummyCategory(serviceId), task: 'add')));
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'add category',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildCategories(context),
    );
  }

  _buildCategories(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCategories(serviceId),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:{
            List<Category> categories = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
              final Category category = Fresh.freshCategoryMap(map, true);
              categories.add(category);
            }
            return _displayCategories(context, categories);
          }
          }
        });
  }

  _displayCategories(BuildContext context, List<Category> categories) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: categories.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageCategoryItem(
                  category: categories[index],
                ),
                onTap: () {
                  Category sCategory = categories[index];
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => CategoryAddEditScreen(
                          category: sCategory, task: 'edit')));
                });
          }),
    );
  }
}
