import 'dart:collection';

import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/table_card_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../db/bloc_repository.dart';
import '../../db/dao/bloc_dao.dart';
import '../../db/entity/category.dart';
import '../../db/entity/offer.dart';
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
  BlocService blocService;

  BlocServiceDetailScreen({key, required this.dao, required this.blocService})
      : super(key: key);

  @override
  State<BlocServiceDetailScreen> createState() =>
      _BlocServiceDetailScreenState();
}

class _BlocServiceDetailScreenState extends State<BlocServiceDetailScreen>
    with WidgetsBindingObserver {
  static String _TAG = 'BlocServiceDetailScreen';

  String _sCategoryType = 'Alcohol';

  late ServiceTable mTable;
  late Seat mSeat;

  List<Offer> mOffers = [];
  List<Category> mCategories = [];
  List<Category> mCategoryTypes = [];
  List<Category> mAlcoholSubCategories = [];
  List<Category> mFoodSubCategories = [];

  var _isLoading = true;
  var _isTableDetailsLoading = true;
  var _isCategoriesLoading = true;
  var _isCustomerSeated = false;

  var _isCommunity = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    blocUser.User user = UserPreferences.myUser;

    FirestoreHelper.pullCategories(widget.blocService.id).then((res) {
      print("Successfully retrieved categories...");

      if (res.docs.isNotEmpty) {
        List<Category> _categories = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Category category = Category.fromMap(data);
          BlocRepository.insertCategory(widget.dao, category);
          _categories.add(category);
        }

        setState(() {
          mCategories = _categories;
          _isCategoriesLoading = false;
        });
      } else {
        print('no categories found!');
      }
    });

    FirestoreHelper.pullCustomerSeat(widget.blocService.id, user.id)
        .then((res) {
      print("Successfully retrieved seat of user " + user.name);

      if (res.docs.isEmpty) {
        // the user has not selected a table yet
        // notify user to scan the table

        ServiceTable dummyTable = Dummy.getDummyTable(widget.blocService.id);
        Seat dummySeat = Dummy.getDummySeat(widget.blocService.id, user.id);

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

    FirestoreHelper.pullOffers(widget.blocService.id).then((res) {
      print("Successfully retrieved offers at bloc " + widget.blocService.name);

      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Offer offer = Offer.fromMap(data);
          mOffers.add(offer);
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
        title: Text(widget.blocService.name),
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
                        service: widget.blocService,
                        dao: widget.dao,
                        tableNumber: mTable.tableNumber)),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: Text('Loading the menu...'))
          : _buildBody(context, widget.blocService),
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
        _isCategoriesLoading ? SizedBox() : _displayCategories(context),
        const SizedBox(height: 2.0),
        buildProducts(context, 'Beer'),
        const SizedBox(height: 1.0),
        _updateOffers(context)
      ],
    );
  }

  /** Offer Update **/
  _updateOffers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getActiveOffers(widget.blocService.id, true),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('loading offers...');
          return SizedBox();
        }

        mOffers.clear();

        List<Offer> _offers = [];
        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Offer offer = Offer.fromMap(data);
          _offers.add(offer);

          if (i == snapshot.data!.docs.length - 1) {
            // here we need to check if any new offers has come
            // then somehow force a refresh of the menu items
            mOffers.addAll(_offers);

            return SizedBox();
          }
        }
        return SizedBox();
      },
    );
  }

  /** Table Info **/
  _searchTableNumber(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.findTableNumber(
            widget.blocService.id, UserPreferences.myUser.id),
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
  _displayCategories(BuildContext context) {
    mCategoryTypes.clear();
    mAlcoholSubCategories.clear();
    mFoodSubCategories.clear();

    for (Category cat in mCategories) {
      if (cat.name == 'Food' || cat.name == 'Alcohol') {
        mCategoryTypes.add(cat);
      } else {
        if (cat.type == 'Food') {
          mFoodSubCategories.add(cat);
        } else {
          mAlcoholSubCategories.add(cat);
        }
      }
    }

    return Container(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 14,
      child: ListView.builder(
          itemCount: mCategoryTypes.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: CategoryItem(
                  cat: mCategoryTypes[index],
                ),
                onTap: () {
                  setState(() {
                    // _sCategory = categories[index];
                    _sCategoryType = mCategoryTypes[index].name;
                    print(_sCategoryType + ' category type is selected');
                  });
                });
          }),
    );
  }

  /** Products List **/
  buildProducts(BuildContext context, String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getProductsByCategoryType(
          widget.blocService.id, _sCategoryType),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.isNotEmpty) {
          BlocRepository.clearProducts(widget.dao);
        }

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

  _displayProductsList(BuildContext context, List<Product> _categoryProducts) {
    bool isProductOnOffer;
    Offer productOffer = Dummy.getDummyOffer();
    String categoryTitle = '';
    bool isCategoryChange;

    LinkedHashMap map = new LinkedHashMap<int, String>();

    List<Product> subProducts = [];
    String curCategory = '';

    for (Category sub in _sCategoryType == 'Food'
        ? mFoodSubCategories
        : mAlcoholSubCategories) {
      for (Product product in _categoryProducts) {
        if (product.category == sub.name) {
          subProducts.add(product);

          // category determination logic
          if(subProducts.length == 1){
            map.putIfAbsent(subProducts.length-1, () => product.category);
            curCategory = product.category;
          } else {
            if(curCategory!=product.category){
              map.putIfAbsent(subProducts.length-1, () => product.category);
              curCategory = product.category;
            }
          }
        }
      }
    }

    return Expanded(
      child: ListView.builder(
          itemCount: subProducts.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            //lets check if the product is on offer
            isProductOnOffer = false;

            for (Offer offer in mOffers) {
              if (offer.productId == subProducts[index].id) {
                isProductOnOffer = true;
                productOffer = offer;
                break;
              }
            }

            if(map.containsKey(index)){
              isCategoryChange = true;
              categoryTitle = map[index];
            } else {
              isCategoryChange = false;
            }

            return Column(
              children: [
                isCategoryChange
                    ? Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: 8.0, bottom: 8, right: 20),
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                categoryTitle,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
                GestureDetector(
                    child: ProductItem(
                      serviceId: widget.blocService.id,
                      product: subProducts[index],
                      dao: widget.dao,
                      tableNumber: mTable.tableNumber,
                      isCommunity: _isCommunity,
                      isOnOffer: isProductOnOffer,
                      offer: productOffer,
                    ),
                    onTap: () {
                      Product _sProduct = subProducts[index];
                      print(_sProduct.name + ' is selected');
                    }),
              ],
            );
          }),
    );
  }
}
