import 'package:bloc/db/entity/category.dart';
import 'package:bloc/widgets/ui/listview_block.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
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
        title: AppBarTitle(title:'manage inventory category'),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          List<Category> _categories = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Category _category = Fresh.freshCategoryMap(map, true);
            _categories.add(_category);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayCategories(context, _categories);
            }
          }
          return const LoadingWidget();
        });
  }

  _displayCategories(BuildContext context, List<Category> _categories) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: _categories.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ListViewBlock(
                  title: '${_categories[index].sequence} : ${_categories[index].name}',
                ),
                onTap: () {
                  Category _sCategory = _categories[index];
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => CategoryAddEditScreen(
                          category: _sCategory, task: 'edit')));
                });
          }),
    );
  }
}
