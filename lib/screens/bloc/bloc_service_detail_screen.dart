import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/table_card_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../db/bloc_repository.dart';
import '../../db/dao/bloc_dao.dart';
import '../../db/entity/category.dart';
import '../../db/entity/product.dart';
import '../../db/entity/seat.dart';
import '../../helpers/token_monitor.dart';
import '../../widgets/category_item.dart';
import '../../widgets/product_item.dart';
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
  String _categoryName = 'Beer';
  var _mTableNumber = 0;
  late ServiceTable _mTable;
  var _isInit = true;
  var _isLoading = false;
  late Widget _categoriesWidget;
  var _isCommunity = false;
  String? _token;

  @override
  void initState() {
    _categoriesWidget = buildServiceCategories(context);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
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
            icon: const Icon(
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
      // floatingActionButton: ExpandableFab(
      //   distance: 112.0,
      //   children: [
      //     ActionButton(
      //       onPressed: () => {
      //         // _showAction(context, 0)
      //         Navigator.of(context).push(
      //           MaterialPageRoute(
      //               builder: (ctx) => CartScreen(
      //                   service: widget.service,
      //                   dao: widget.dao,
      //                   tableNumber: _mTableNumber)),
      //         ),
      //       },
      //       icon: const Icon(Icons.shopping_cart_outlined),
      //     ),
      //     ActionButton(
      //       onPressed: () => {
      //         Navigator.of(context).push(
      //           MaterialPageRoute(
      //               builder: (ctx) => NewProductScreen(
      //                   service: widget.service, dao: widget.dao)),
      //         ),
      //       },
      //       icon: const Icon(Icons.fastfood),
      //     ),
      //     ActionButton(
      //       onPressed: () => {
      //         // _showAction(context, 2),
      //         // Navigator.of(context).push(
      //         //   MaterialPageRoute(
      //         //       builder: (ctx) => NewServiceCategoryScreen(
      //         //           service: widget.service, dao: widget.dao)),
      //         // ),
      //       },
      //       icon: const Icon(Icons.category_outlined),
      //     ),
      //   ],
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context, widget.service),
    );
  }

  Widget _buildBody(BuildContext context, BlocService service) {
    try {
      if (_mTable.colorStatus == 2) {
        _isCommunity = true;
      }
    } catch (err) {
      print(err);
    }

    return Column(
      children: [
        // TokenMonitor((token) {
        //   _token = token;
        //   return token == null
        //       ? const CircularProgressIndicator()
        //       : Text(token, style: const TextStyle(fontSize: 12));
        // }),
        const SizedBox(height: 2.0),
        _searchTableNumber(context),
        // CoverPhoto(service.name, service.imageUrl),
        const SizedBox(height: 2.0),
        // buildServiceCategories(context),
        _categoriesWidget,
        const SizedBox(height: 2.0),
        buildProducts(context, 'Beer'),
        const SizedBox(height: 0.0),
      ],
    );
  }

  /** Table Info **/
  _searchTableNumber(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final Stream<QuerySnapshot> _stream =
        FirestoreHelper.findTableNumber(widget.service.id, user!.uid);
    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('loading table number...');
            return const SizedBox();
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
                if (_mTableNumber == 0) {
                  // this is needed or else we will hit a loop in loading
                  _findTable(seat.tableId);
                  _mTableNumber = seat.tableNumber;
                  return Text('table number is ' + _mTableNumber.toString());
                } else {
                  return TokenMonitor((token) {
                    _token = token;
                    return token == null
                        ? const CircularProgressIndicator()
                        : TableCardItem(seat.id, seat.tableNumber, seat.tableId, _isCommunity, _token);
                  });
                }
              }
            }
          } else {
            return TableCardItem('', -1, '', _isCommunity, _token);
          }
          return Text('loading table number...');
        });
  }

  void _findTable(String tableId) {
    FirebaseFirestore.instance
        .collection(FirestoreHelper.TABLES)
        .where('id', isEqualTo: tableId)
        .get()
        .then(
      (result) {
        if (result.docs.isNotEmpty) {
          for (int i = 0; i < result.docs.length; i++) {
            DocumentSnapshot document = result.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final ServiceTable _table = ServiceTable.fromMap(data);

            setState(() {
              _mTable = _table;
            });
          }
        } else {
          print('table could not be found for ' + tableId);
        }
      },
      onError: (e) => print("Error searching for table : $e"),
    );
  }

  /** Categories List **/
  buildServiceCategories(BuildContext context) {
    final Stream<QuerySnapshot> _catsStream =
        FirestoreHelper.getCategories(widget.service.id);

    return StreamBuilder<QuerySnapshot>(
      stream: _catsStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('loading categories...');
          return SizedBox();
        }

        if (snapshot.data!.docs.length > 0) {
          BlocRepository.clearCategories(widget.dao);
        }

        List<Category> _categories = [];
        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Category cat = Category.fromMap(data);
          BlocRepository.insertCategory(widget.dao, cat);
          _categories.add(cat);

          if (i == snapshot.data!.docs.length - 1) {
            return _displayCategories(context, _categories);
          }
        }
        return Text('Loading categories...');
      },
    );
  }

  _displayCategories(BuildContext context, List<Category> categories) {
    return Container(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 8,
      child: ListView.builder(
          itemCount: categories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: CategoryItem(
                  cat: categories[index],
                ),
                onTap: () {
                  setState(() {
                    // _sCategory = categories[index];
                    _categoryName = categories[index].name;
                    print(_categoryName + ' category is selected');
                  });
                  // displayProductsList(context, categories[index].id);
                });
          }),
    );
  }

  /** Products List **/
  buildProducts(BuildContext context, String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getProductsByCategory(
          widget.service.id, _categoryName),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.isNotEmpty) {
          BlocRepository.clearProducts(widget.dao);
        }

        List<Product> products = [];
        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Product product = Product.fromMap(data);
          BlocRepository.insertProduct(widget.dao, product);
          products.add(product);

          if (i == snapshot.data!.docs.length - 1) {
            return _displayProductsList(context, products);
          }
        }
        return const Expanded(child: Center(child: Text('No products found!')));
      },
    );
  }

  _displayProductsList(BuildContext context, List<Product> _products) {
    return Expanded(
      child: ListView.builder(
          itemCount: _products.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ProductItem(
                  serviceId: widget.service.id,
                  product: _products[index],
                  dao: widget.dao,
                  tableNumber: _mTableNumber,
                  isCommunity: _isCommunity,
                ),
                onTap: () {
                  Product _sProduct = _products[index];
                  print(_sProduct.name + ' is selected');
                });
          }),
    );

    // if (_categorySelected == 0) {
    //   fProducts = BlocRepository.getProductsByCategory(widget.dao, "Food");
    // } else {
    //   fProducts = BlocRepository.getProductsByCategory(widget.dao, "Alcohol");
    // }
    //
    // return FutureBuilder(
    //     future: fProducts,
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       }
    //       List<Product> products = snapshot.data! as List<Product>;
    //
    //       return ListView.builder(
    //         primary: false,
    //         scrollDirection: Axis.vertical,
    //         shrinkWrap: true,
    //         itemCount: products == null ? 0 : products.length,
    //         itemBuilder: (BuildContext ctx, int index) {
    //           Product product = products[index];
    //
    //           return ProductItem(
    //               serviceId: widget.service.id,
    //               product: product,
    //               dao: widget.dao,
    //               tableNumber: _mTableNumber);
    //         },
    //       );
    //     });
  }

}
