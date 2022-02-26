import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/widgets/ui/cover_photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/category.dart';
import '../db/entity/product.dart';
import '../utils/category_utils.dart';
import '../utils/product_utils.dart';
import '../widgets/category_item.dart';
import '../widgets/products_grid.dart';
import '../widgets/ui/expandable_fab.dart';
import 'cart_screen.dart';
import 'forms/new_product_screen.dart';
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
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => {
              // _showAction(context, 0)
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => CartScreen(service: service, dao:dao)),
              ),
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          ActionButton(
            onPressed: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => NewProductScreen(service: service)),
              ),
            },
            icon: const Icon(Icons.fastfood),
          ),
          ActionButton(
            onPressed: () => {
              // _showAction(context, 2),
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => NewServiceCategoryScreen(service: service, dao:dao)),
              ),
            },
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context, service),
    );
  }

  Widget _buildBody(BuildContext context, BlocService service) {
    return SingleChildScrollView(
      child: Column(
          children: [
            CoverPhoto(service.name, service.imageUrl),
            SizedBox(height: 20.0),
            buildServiceCategories(context),
            SizedBox(height: 20.0),
            buildProducts(context),
            SizedBox(height: 30.0),
          ]
      ),
    );
    // ListView(
    //   children: <Widget>[
    //     CoverPhoto(service.name, service.imageUrl),
    //     SizedBox(height: 20.0),
    //     buildServiceCategories(context),
    //     SizedBox(height: 20.0),
    //     buildProducts(context),
    //     SizedBox(height: 30.0),
    //   ],
    // ),
  }

  /** Categories List **/
  buildServiceCategories(BuildContext context) {
    final Stream<QuerySnapshot> _catsStream = FirebaseFirestore.instance
        .collection('categories')
        // .orderBy('sequence', descending: true)
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

        // if(count>0) {
        //   snapshot.data!.docs.sort((a, b) => a['sequence'].compareTo(b['sequence']));
        // }

        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Category cat = CategoryUtils.getCategory(data, document.id);
          BlocRepository.insertCategory(dao, cat);

          if (i==snapshot.data!.docs.length-1) {
            return displayCategoryList(context);
          }
        }
        return Text('Loading...');
      },
    );
  }

  displayCategoryList(BuildContext context) {
    Stream<List<Category>> _catsStream = dao.getCategories();

    return Container(
      height: MediaQuery.of(context).size.height / 6,
      child: StreamBuilder(
        stream: _catsStream,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Text('Loading...');
          } else {
            List<Category> cats = snapshot.data! as List<Category>;

            return ListView.builder(
              primary: false,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: cats == null ? 0 : cats.length,
              itemBuilder: (BuildContext ctx, int index) {
                Category cat = cats[index];

                return CategoryItem(
                  cat: cat,
                );
              },
            );
          }
        },
      ),
    );
  }

  /** Items List **/
  buildProducts(BuildContext context) {
    final Stream<QuerySnapshot> _itemsStream = FirebaseFirestore.instance
        .collection('products')
    // .orderBy('sequence', descending: true)
        .where('serviceId', isEqualTo: service.id)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _itemsStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // if(count>0) {
        //   snapshot.data!.docs.sort((a, b) => a['sequence'].compareTo(b['sequence']));
        // }
        List<Product> products=[];
        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Product product = ProductUtils.getProduct(data, document.id);
          BlocRepository.insertProduct(dao, product);
          products.add(product);

          if (i==snapshot.data!.docs.length-1) {
            // return ProductsList(products);
            return ProductsGrid(products, dao);
          }
        }
        return Text('Streaming service products...');
      },
    );
  }
}
