import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/table_card_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/bloc_repository.dart';
import '../../db/dao/bloc_dao.dart';
import '../../db/entity/category.dart';
import '../../db/entity/product.dart';
import '../../db/entity/seat.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../widgets/category_item.dart';
import '../../widgets/product_item.dart';
import '../../widgets/ui/Toaster.dart';
import 'cart_screen.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;

class BlocServiceDetailScreen extends StatefulWidget {
  BlocDao dao;
  BlocService service;

  BlocServiceDetailScreen({key, required this.dao, required this.service})
      : super(key: key);

  @override
  State<BlocServiceDetailScreen> createState() =>
      _BlocServiceDetailScreenState();
}

class _BlocServiceDetailScreenState extends State<BlocServiceDetailScreen>
    with WidgetsBindingObserver {
  static String _TAG = 'BlocServiceDetailScreen';

  String _categoryName = 'Beer';

  late ServiceTable mTable;
  late Seat mSeat;

  var _isLoading = true;
  var _isTableDetailsLoading = true;
  var _isCustomerSeated = false;

  late Widget _categoriesWidget;
  var _isCommunity = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _categoriesWidget = buildServiceCategories(context);

    blocUser.User user = UserPreferences.myUser;

    FirestoreHelper.pullCustomerSeat(widget.service.id, user.id).then((res) {
      print("Successfully retrieved seat of user " + user.name);

      if (res.docs.isEmpty) {
        // the user has not selected a table yet
        // notify user to scan the table

        ServiceTable dummyTable = ServiceTable(
            id: 'dummy_table',
            captainId: '',
            capacity: 0,
            isActive: false,
            isOccupied: false,
            serviceId: widget.service.blocId,
            tableNumber: -1,
            type: FirestoreHelper.TABLE_PRIVATE_TYPE_ID);

        Seat dummySeat = Seat(
            tableNumber: -1,
            serviceId: widget.service.blocId,
            id: 'dummy_seat',
            custId: user.id,
            tableId: 'dummy_table');

        setState(() {
          mTable = dummyTable;
          mSeat = dummySeat;
          _isTableDetailsLoading = false;
          _isLoading = false;
          _isCustomerSeated = false;
        });
      } else {
        // we should receive only 1 seat for a user
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Seat userSeat = Seat.fromMap(data);
          mSeat = userSeat;
          BlocRepository.insertSeat(widget.dao, userSeat);

          if (i == res.docs.length - 1) {
            FirestoreHelper.pullSeatTable(userSeat.tableId).then(
              (result) {
                if (result.docs.isNotEmpty) {
                  for (int i = 0; i < result.docs.length; i++) {
                    DocumentSnapshot document = result.docs[i];
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    final ServiceTable _table = ServiceTable.fromMap(data);

                    setState(() {
                      mTable = _table;
                      _isTableDetailsLoading = false;
                      _isLoading = false;
                      _isCustomerSeated = true;
                    });
                  }
                } else {
                  print('table could not be found for ' + userSeat.tableId);
                }
              },
              onError: (e) => print("Error searching for table : $e"),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // keeping this here, could be useful
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
    }
  }

  @override
  void didChangeDependencies() {
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
              Icons.back_hand_outlined,
            ),
            onPressed: () {
              Toaster.shortToast(
                  'We are sending someone from our team towards tour table.');

              blocUser.User user = UserPreferences.myUser;

              FirestoreHelper.sendSOSMessage(user.fcmToken, user.name,
                  user.phoneNumber, mTable.tableNumber, mTable.id, mSeat.id);
            },
          ),
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
                        tableNumber: mTable.tableNumber)),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: Text('Loading the menu...'))
          : _buildBody(context, widget.service),
    );
  }

  Widget _buildBody(BuildContext context, BlocService service) {
    if (mTable.type == FirestoreHelper.TABLE_COMMUNITY_TYPE_ID) {
      _isCommunity = true;
    }

    return Column(
      children: [
        const SizedBox(height: 2.0),
        _isTableDetailsLoading
            ? TextFormField(
                key: const ValueKey('table_loading'),
                initialValue: 'Loading Table Info ...',
                enabled: false,
                autocorrect: false,
                textCapitalization: TextCapitalization.words,
                enableSuggestions: false,
                keyboardType: TextInputType.text,
              )
            : _isCustomerSeated
                ? TableCardItem(
                    tableId: mTable.id,
                    tableNumber: mTable.tableNumber,
                    isCommunity: _isCommunity,
                    seatId: mSeat.id,
                  )
                : _searchTableNumber(context),
        const SizedBox(height: 2.0),
        // buildServiceCategories(context),
        _categoriesWidget,
        const SizedBox(height: 2.0),
        buildProducts(context, 'Beer'),
        const SizedBox(height: 1.0),
      ],
    );
  }

  /** Table Info **/
  _searchTableNumber(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.findTableNumber(
            widget.service.id, UserPreferences.myUser.id),
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
              final Seat seat = Seat.fromMap(data);
              BlocRepository.insertSeat(widget.dao, seat);
              seats.add(seat);

              if (i == snapshot.data!.docs.length - 1) {
                mSeat = seat;
                FirestoreHelper.pullSeatTable(seat.tableId).then(
                  (result) {
                    if (result.docs.isNotEmpty) {
                      for (int i = 0; i < result.docs.length; i++) {
                        DocumentSnapshot document = result.docs[i];
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        final ServiceTable _table = ServiceTable.fromMap(data);

                        setState(() {
                          mTable = _table;
                          _isTableDetailsLoading = false;
                          _isCustomerSeated = true;
                        });
                      }
                    } else {
                      print('table could not be found for ' + seat.tableId);
                    }
                  },
                  onError: (e) => print("Error searching for table : $e"),
                );
                return SizedBox();
              }
            }
          } else {
            // this will display the table card item with the dummy values
            return TableCardItem(
              tableId: mTable.id,
              tableNumber: mTable.tableNumber,
              isCommunity: _isCommunity,
              seatId: mSeat.id,
            );
          }
          return SizedBox();
        });
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

        // here we should check if there are offers running

        if (snapshot.hasData) {
          List<Product> products = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final Product product = Product.fromMap(data);
            BlocRepository.insertProduct(widget.dao, product);
            products.add(product);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayProductsList(context, products);
            }
          }
        } else {
          return const Expanded(
              child: Center(child: Text('No products found!')));
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
                  tableNumber: mTable.tableNumber,
                  isCommunity: _isCommunity,
                ),
                onTap: () {
                  Product _sProduct = _products[index];
                  print(_sProduct.name + ' is selected');
                });
          }),
    );
  }
}
