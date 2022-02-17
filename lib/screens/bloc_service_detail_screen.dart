import 'package:bloc/db/entity/bloc_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/category.dart';
import '../utils/category_utils.dart';
import '../widgets/category_item.dart';
import '../widgets/ui/expandable_fab.dart';
import 'forms/new_service_category_screen.dart';

class BlocServiceDetailScreen extends StatelessWidget {
  BlocDao dao;
  BlocService service;

  BlocServiceDetailScreen({key, required this.dao, required this.service})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //           builder: (ctx) => NewServiceCategoryScreen(service:service)),
      //     );
      //   },
      //   child: Icon(
      //     Icons.add,
      //     color: Colors.black,
      //     size: 29,
      //   ),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   tooltip: 'New Bloc',
      //   elevation: 5,
      //   splashColor: Colors.grey,
      // ),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => {
              // _showAction(context, 0)
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) =>
                        NewServiceCategoryScreen(service: service)),
              ),
            },
            icon: const Icon(Icons.format_size),
          ),
          ActionButton(
            onPressed: () => {
              // _showAction(context, 1),
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) =>
                        NewServiceCategoryScreen(service: service)),
              ),
            },
            icon: const Icon(Icons.insert_photo),
          ),
          ActionButton(
            onPressed: () => {
              // _showAction(context, 2),
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) =>
                        NewServiceCategoryScreen(service: service)),
              ),
            },
            icon: const Icon(Icons.videocam),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          children: <Widget>[
            buildServiceDisplayHeader(context),
            SizedBox(height: 20.0),
            buildServiceCategories(context),
            SizedBox(height: 20.0),
            // buildBlocRow(context),
            // SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  buildServiceDisplayHeader(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 3.0,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 3.5,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: FadeInImage(
                    placeholder: const AssetImage(
                        'assets/images/product-placeholder.png'),
                    image: service.imageUrl != "url"
                        ? NetworkImage(service.imageUrl)
                        : NetworkImage("assets/images/product-placeholder.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildServiceCategories(BuildContext context) {
    final Stream<QuerySnapshot> _catsStream = FirebaseFirestore.instance
        .collection('categories')
        .where('serviceId', isEqualTo: service.id)
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: _catsStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        int count = snapshot.data!.docs.length;
        List categories = List.empty(growable: true);

        for (DocumentSnapshot document in snapshot.data!.docs) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Category cat = CategoryUtils.getCategory(data, document.id);
          BlocRepository.insertCategory(dao, cat);

          categories.add(cat);
          if (--count == 0) return displayCategoryList(context, categories);
        }
        return Text('Loading...');
      },
    );
  }

  displayCategoryList(BuildContext context, List cats) {
    return Container(
      height: MediaQuery.of(context).size.height / 6,
      child: ListView.builder(
        primary: false,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: cats == null ? 0 : cats.length,
        itemBuilder: (BuildContext context, int index) {
          Category cat = cats[index];

          return CategoryItem(
            cat: cat,
          );
        },
      ),
    );
  }
}
