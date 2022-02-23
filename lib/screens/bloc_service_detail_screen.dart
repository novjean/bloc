import 'package:bloc/db/entity/bloc_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/category.dart';
import '../db/entity/product.dart';
import '../utils/category_utils.dart';
import '../utils/product_utils.dart';
import '../widgets/category_item.dart';
import '../widgets/product_item.dart';
import '../widgets/products_grid.dart';
import '../widgets/ui/expandable_fab.dart';
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
                    builder: (ctx) =>
                        NewServiceCategoryScreen(service: service, dao:dao)),
              ),
            },
            icon: const Icon(Icons.question_answer_outlined),
          ),
          ActionButton(
            onPressed: () => {
              // _showAction(context, 1),
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
                    builder: (ctx) =>
                        NewServiceCategoryScreen(service: service, dao:dao)),
              ),
            },
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          children: <Widget>[
            buildBanner(context),
            SizedBox(height: 20.0),
            buildServiceCategories(context),
            SizedBox(height: 20.0),
            buildServiceItems(context),
            SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  buildBanner(BuildContext context) {
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
  buildServiceItems(BuildContext context) {
    final Stream<QuerySnapshot> _itemsStream = FirebaseFirestore.instance
        .collection('items')
    // .orderBy('sequence', descending: true)
        .where('serviceId', isEqualTo: service.id)
        .snapshots();

    return Container(
      height: MediaQuery.of(context).size.height,
      child: StreamBuilder<QuerySnapshot>(
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
              return ProductsGrid(products);
              // return displayItemsList(context, products);
            }
          }
          return Text('Loading...');
        },
      ),
    );
  }

  displayItemsList(BuildContext context, List<Product> products) {
    return ProductsGrid(products);

    // Stream<List<Product>> _itemsStream = dao.getItems();

    // return Container(
    //   height: 100,
    //   child: StreamBuilder(
    //     stream: _itemsStream,
    //     builder: (context, snapshot) {
    //       if(snapshot.connectionState == ConnectionState.waiting) {
    //         return Text('Loading...');
    //       } else {
    //         List<Product> products = snapshot.data! as List<Product>;
    //
    //         return GridView.builder(
    //           // const keyword can be used so that it does not rebuild when the build method is called
    //           // useful for performance improvement
    //           padding: const EdgeInsets.all(10.0),
    //           itemCount: products.length,
    //           // grid delegate describes how many grids should be there
    //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //             crossAxisCount: 1,
    //             childAspectRatio: 3 / 2,
    //             crossAxisSpacing: 10,
    //             mainAxisSpacing: 10,
    //           ),
    //           // item builder defines how the grid should look
    //           itemBuilder: (ctx, i) {
    //             Product product = products[i];
    //             return ProductItem(product:product);
    //           },
    //         );
    //
    //         // return ListView.builder(
    //         //   primary: false,
    //         //   scrollDirection: Axis.vertical,
    //         //   shrinkWrap: true,
    //         //   itemCount: items == null ? 0 : items.length,
    //         //   itemBuilder: (BuildContext ctx, int index) {
    //         //     Product item = items[index];
    //         //     return ProductItem(
    //         //       item: item,
    //         //     );
    //         //   },
    //         // );
    //       }
    //     },
    //   ),
    // );
  }

}
