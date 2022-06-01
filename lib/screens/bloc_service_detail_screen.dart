import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/table_card_item.dart';
import 'package:bloc/widgets/ui/cover_photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/category.dart';
import '../db/entity/product.dart';
import '../db/entity/seat.dart';
import '../utils/category_utils.dart';
import '../utils/product_utils.dart';
import '../widgets/category_item.dart';
import '../widgets/product_item.dart';
import '../widgets/ui/toaster.dart';
import '../widgets/ui/expandable_fab.dart';
import 'forms/new_product_screen.dart';
import 'forms/new_service_category_screen.dart';
import 'cart_screen.dart';

class BlocServiceDetailScreen extends StatefulWidget {
  BlocDao dao;
  BlocService service;

  BlocServiceDetailScreen({key, required this.dao, required this.service})
      : super(key: key);

  @override
  State<BlocServiceDetailScreen> createState() =>
      _BlocServiceDetailScreenState();
}

class _BlocServiceDetailScreenState extends State<BlocServiceDetailScreen> {
  late Future<List<Product>> fProducts;
  var _categorySelected = 0;
  var _mTableNumber = 0;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      if (_categorySelected == 0) {
        fProducts = BlocRepository.getProductsByCategory(widget.dao, "Food");
        setState(() {
          _isLoading = false;
        });
      } else {
        fProducts = BlocRepository.getProductsByCategory(widget.dao, "Alcohol");
        setState(() {
          _isLoading = false;
        });
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.name),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => CartScreen(
                        service: widget.service,
                        dao: widget.dao,
                        tableNumber: _mTableNumber)),
              );
            },
          ),
        ],
      ),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => {
              // _showAction(context, 0)
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => CartScreen(
                        service: widget.service,
                        dao: widget.dao,
                        tableNumber: _mTableNumber)),
              ),
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          ActionButton(
            onPressed: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => NewProductScreen(
                        service: widget.service, dao: widget.dao)),
              ),
            },
            icon: const Icon(Icons.fastfood),
          ),
          ActionButton(
            onPressed: () => {
              // _showAction(context, 2),
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => NewServiceCategoryScreen(
                        service: widget.service, dao: widget.dao)),
              ),
            },
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context, widget.service),
    );
  }

  Widget _buildBody(BuildContext context, BlocService service) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.0),
          _searchTableNumber(context),
          // CoverPhoto(service.name, service.imageUrl),
          SizedBox(height: 2.0),
          buildServiceCategories(context),
          SizedBox(height: 2.0),
          buildProducts(context),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  /** Categories List **/
  buildServiceCategories(BuildContext context) {
    final Stream<QuerySnapshot> _catsStream =
        FirestoreHelper.getCategorySnapshot(widget.service.id);

    return StreamBuilder<QuerySnapshot>(
      stream: _catsStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.length > 0) {
          BlocRepository.clearCategories(widget.dao);
        }

        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Category cat = CategoryUtils.getCategory(data, document.id);
          BlocRepository.insertCategory(widget.dao, cat);

          if (i == snapshot.data!.docs.length - 1) {
            return displayCategoryList(context);
          }
        }
        return Text('Loading categories...');
      },
    );
  }

  displayCategoryList(BuildContext context) {
    Stream<List<Category>> _catsStream =
        BlocRepository.getCategories(widget.dao);

    return Container(
      height: MediaQuery.of(context).size.height / 6,
      child: StreamBuilder(
        stream: _catsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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

                return GestureDetector(
                    child: CategoryItem(
                      cat: cat,
                    ),
                    onTap: () => {
                          setState(() {
                            _categorySelected = index;
                          }),
                          Toaster.shortToast(
                              "Category index : " + index.toString()),
                          displayProductsList(context, index),
                        }

                    // Scaffold
                    // .of(context)
                    // .showSnackBar(SnackBar(content: Text(index.toString()))),
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
        .where('serviceId', isEqualTo: widget.service.id)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _itemsStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.length > 0) {
          BlocRepository.clearProducts(widget.dao);
        }

        List<Product> products = [];
        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Product product = ProductUtils.getProduct(data, document.id);
          BlocRepository.insertProduct(widget.dao, product);
          products.add(product);

          if (i == snapshot.data!.docs.length - 1) {
            // return ProductsGrid(products, dao);
            return displayProductsList(context, -1);
          }
        }
        return Text('Streaming service products...');
      },
    );
  }

  displayProductsList(BuildContext context, int category) {
    if (_categorySelected == 0) {
      fProducts = BlocRepository.getProductsByCategory(widget.dao, "Food");
    } else {
      fProducts = BlocRepository.getProductsByCategory(widget.dao, "Alcohol");
    }

    return FutureBuilder(
        future: fProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Product> products = snapshot.data! as List<Product>;

          return ListView.builder(
            primary: false,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: products == null ? 0 : products.length,
            itemBuilder: (BuildContext ctx, int index) {
              Product product = products[index];

              return ProductItem(
                  serviceId: widget.service.id,
                  product: product,
                  dao: widget.dao,
                  tableNumber: _mTableNumber);
            },
          );
        });
  }

  _searchTableNumber(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final Stream<QuerySnapshot> _stream =
        FirestoreHelper.findTableNumber(widget.service.id, user!.uid);
    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Seat> seats = [];
          if (snapshot.data!.docs.length > 0) {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              final Seat seat = Seat.fromJson(data);
              BlocRepository.insertSeat(widget.dao, seat);
              seats.add(seat);

              if (i == snapshot.data!.docs.length - 1) {
                _mTableNumber = seat.tableNumber;
                return TableCardItem(seat.id, seat.tableNumber, seat.tableId);
              }
            }
          } else {
            return TableCardItem('', -1, '');
          }
          return Text('loading table number...');
        });
  }
}
