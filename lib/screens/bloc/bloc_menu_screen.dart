import 'dart:collection';

import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/db/shared_preferences/table_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../db/entity/category.dart';
import '../../db/entity/offer.dart';
import '../../db/entity/product.dart';
import '../../db/entity/seat.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../main.dart';
import '../../widgets/cart_widget.dart';
import '../../widgets/category_item.dart';
import '../../widgets/product_item.dart';
import '../../widgets/ui/system_padding.dart';
import '../../widgets/ui/toaster.dart';
import 'cart_screen.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;

class BlocMenuScreen extends StatefulWidget {
  BlocService blocService;

  BlocMenuScreen({key, required this.blocService}) : super(key: key);

  @override
  State<BlocMenuScreen> createState() => _BlocMenuScreenState();
}

class _BlocMenuScreenState extends State<BlocMenuScreen>
    with WidgetsBindingObserver {
  String _sCategoryType = 'Alcohol';

  late ServiceTable mTable;
  late Seat mSeat;

  List<Offer> mOffers = [];
  List<Category> mCategories = [];
  List<Category> mCategoryTypes = [];
  List<Category> mAlcoholSubCategories = [];
  List<Category> mFoodSubCategories = [];

  var _isLoading = true;
  var _isCategoriesLoading = true;
  var _isCustomerSeated = false;

  var _isCommunity = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    blocUser.User user = UserPreferences.myUser;

    FirestoreHelper.pullCategories(widget.blocService.id).then((res) {
      print("successfully retrieved categories");

      if (res.docs.isNotEmpty) {
        List<Category> _categories = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Category category = Category.fromMap(data);
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
      print("successfully retrieved seat of user " + user.name);

      if (res.docs.isEmpty) {
        // the user has not selected a table yet
        // notify user to scan the table

        ServiceTable dummyTable = Dummy.getDummyTable(widget.blocService.id);
        Seat dummySeat = Dummy.getDummySeat(widget.blocService.id, user.id);

        setState(() {
          mTable = dummyTable;
          mSeat = dummySeat;
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
                      _isLoading = false;
                      _isCustomerSeated = true;
                    });
                  }
                } else {
                  print('table could not be found for ' + userSeat.tableId);
                }
              },
              onError: (e) => print("error searching for table : $e"),
            );
          }
        }
      }
    });

    FirestoreHelper.pullOffers(widget.blocService.id).then((res) {
      print("successfully retrieved offers at bloc " + widget.blocService.name);

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

  Future<void> scanTableQR(blocUser.User user) async {
    String scanTableId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      scanTableId = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print('table id scanned ' + scanTableId);
    } on PlatformException {
      scanTableId = 'failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (scanTableId.compareTo('-1') == 0) {
      return;
    }

    updateTableWithUser(scanTableId, user.id);
  }

  void updateTableWithUser(String tableId, String userId) {
    if (userId.isNotEmpty) {
      // set the table as occupied
      FirestoreHelper.setTableOccupyStatus(tableId, true);

      FirestoreHelper.pullSeats(tableId).then(
        (result) {
          bool isSeatAvailable = false;
          if (result.docs.isNotEmpty) {
            for (int i = 0; i < result.docs.length; i++) {
              DocumentSnapshot document = result.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              final Seat seat = Seat.fromMap(data);

              if (seat.custId.isEmpty) {
                // set the table as occupied
                FirestoreHelper.updateSeat(seat.id, userId);
                // here we update the user's bloc service id
                FirestoreHelper.updateUserBlocId(userId, seat.serviceId);

                if (!kIsWeb) {
                  // keeping this here since android/ios does not set table
                  FirestoreHelper.pullTableById(widget.blocService.id, tableId)
                      .then((res) {
                    print('successfully pulled in table for id ' + tableId);

                    if (res.docs.isNotEmpty) {
                      DocumentSnapshot document = res.docs[0];
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      final ServiceTable table = ServiceTable.fromMap(data);

                      TablePreferences.setTable(table);
                      setState(() {
                        mTable = table;
                      });
                    } else {
                      print('table could not be found for id ' + tableId);
                    }
                  });
                }

                break;
              }

              if (i == result.docs.length - 1) {
                if (!isSeatAvailable) {
                  print(mTable.tableNumber.toString() +
                      ' does not have a seat for ' +
                      UserPreferences.myUser.name);
                }
                // we should still let them be part of the table
                // and notify the main person that someone has joined the table.
                Toaster.shortToast('no seats left on the table!');
              }
            }
            Toaster.longToast(
                'welcome ' + UserPreferences.myUser.name.toLowerCase());
          } else {
            print('seats could not be found for table id ' + tableId);
          }
        },
        onError: (e) => print("error completing: $e"),
      );
    } else {
      print('user not signed in, logging out');

      // Toaster.shortToast('not signed in, write go to log in logic here!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(widget.blocService.name),
        backgroundColor: Theme.of(context).backgroundColor,
        actions: [
          UserPreferences.isUserLoggedIn()
              ?
              // need to check if the person is seated
              _isCustomerSeated
                  ? IconButton(
                      icon: const Icon(
                        Icons.back_hand_outlined,
                      ),
                      onPressed: () {
                        Toaster.longToast(
                            'we are sending someone over to assist you soon');

                        blocUser.User user = UserPreferences.myUser;

                        FirestoreHelper.sendSOSMessage(
                            user.fcmToken,
                            user.name,
                            user.phoneNumber,
                            mTable.tableNumber,
                            mTable.id,
                            mSeat.id);
                      },
                    )
                  : kIsWeb
                      ? IconButton(
                          icon: const Icon(
                            Icons.table_bar,
                          ),
                          onPressed: () {
                            Toaster.longToast('enter your table number');

                            TablePreferences.resetTable();
                            int tableNum = -1;

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SystemPadding(
                                  child: AlertDialog(
                                    contentPadding: const EdgeInsets.all(16.0),
                                    content: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: TextField(
                                            autofocus: true,
                                            keyboardType: TextInputType.number,
                                            onChanged: (text) {
                                              try {
                                                tableNum = int.parse(text);
                                              } catch (err) {
                                                print('err: ' + err.toString());
                                              }
                                            },
                                            decoration: InputDecoration(
                                                labelText: 'table number',
                                                hintText: 'eg. 12'),
                                          ),
                                        )
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("no"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text("continue"),
                                        onPressed: () {
                                          print('table num is ' +
                                              tableNum.toString());

                                          FirestoreHelper.pullTableByNumber(
                                                  widget.blocService.id,
                                                  tableNum)
                                              .then(
                                            (result) {
                                              if (result.docs.isNotEmpty) {
                                                for (int i = 0;
                                                    i < result.docs.length;
                                                    i++) {
                                                  DocumentSnapshot document =
                                                      result.docs[i];
                                                  Map<String, dynamic> data =
                                                      document.data()! as Map<
                                                          String, dynamic>;
                                                  final ServiceTable table =
                                                      ServiceTable.fromMap(
                                                          data);
                                                  print('table found ' +
                                                      table.tableNumber
                                                          .toString());

                                                  // check if table is occupied
                                                  if (table.isActive &&
                                                      !table.isOccupied) {
                                                    updateTableWithUser(
                                                        table.id,
                                                        UserPreferences
                                                            .myUser.id);

                                                    TablePreferences.setTable(
                                                        table);
                                                  } else {
                                                    Toaster.longToast('table ' +
                                                        tableNum.toString() +
                                                        ' is occupied');
                                                  }
                                                }
                                              } else {
                                                print(
                                                    'table could not be found for table number ' +
                                                        tableNum.toString());
                                              }
                                            },
                                            onError: (e) => print(
                                                "error searching for table : $e"),
                                          );

                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.qr_code,
                          ),
                          onPressed: () {
                            Toaster.longToast('scan your table now');

                            TablePreferences.resetTable();

                            blocUser.User user = UserPreferences.myUser;
                            scanTableQR(user);
                          },
                        )
              : const SizedBox(),
          UserPreferences.isUserLoggedIn()
              ? IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => CartScreen()),
                    );
                  },
                )
              : const SizedBox(),
        ],
      ),
      body: _isLoading
          ? Center(child: Text('loading menu...'))
          : _buildBody(context, widget.blocService),
    );
  }

  Widget _buildBody(BuildContext context, BlocService service) {
    if (mTable.type == FirestoreHelper.TABLE_COMMUNITY_TYPE_ID) {
      _isCommunity = true;
    }

    return Column(
      children: [
        const SizedBox(height: 5.0),
        _isCategoriesLoading ? const SizedBox() : _displayCategories(context),
        const SizedBox(height: 5.0),
        buildProducts(context, 'Beer'),
        const SizedBox(height: 5.0),
        _updateOffers(context),
        !_isCustomerSeated ? _searchTableNumber(context) : CartWidget()
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
          return const SizedBox();
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

            return const SizedBox();
          }
        }
        return const SizedBox();
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
                          _isCustomerSeated = true;
                        });
                      }
                    } else {
                      print('table could not be found for ' + seat.tableId);
                    }
                  },
                  onError: (e) => print("error searching for table : $e"),
                );
                return const SizedBox();
              }
            }
          } else {
            return const SizedBox(height: 0);
          }
          return const SizedBox();
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
      height: MediaQuery.of(context).size.height / 12,
      child: ListView.builder(
          itemCount: mCategoryTypes.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: CategoryItem(
                  category: mCategoryTypes[index],
                ),
                onTap: () {
                  setState(() {
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

        if (snapshot.hasData) {
          List<Product> products = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final Product product = Product.fromMap(data);
            products.add(product);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayProductsList(context, products);
            }
          }
        } else {
          return const Expanded(
              child: Center(child: Text('no products found!')));
        }
        return const Expanded(child: Center(child: Text('no products found!')));
      },
    );
  }

  _displayProductsList(BuildContext context, List<Product> _categoryProducts) {
    bool isProductOnOffer;
    Offer productOffer = Dummy.getDummyOffer();
    String categoryTitle = '';
    bool isCategoryChange;

    LinkedHashMap map = LinkedHashMap<int, String>();

    List<Product> subProducts = [];
    String curCategory = '';

    for (Category sub in _sCategoryType == 'Food'
        ? mFoodSubCategories
        : mAlcoholSubCategories) {
      for (Product product in _categoryProducts) {
        if (product.category == sub.name) {
          subProducts.add(product);

          // category determination logic
          if (subProducts.length == 1) {
            map.putIfAbsent(subProducts.length - 1, () => product.category);
            curCategory = product.category;
          } else {
            if (curCategory != product.category) {
              map.putIfAbsent(subProducts.length - 1, () => product.category);
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

            Category vCategory = mCategories.first;
            if (map.containsKey(index)) {
              isCategoryChange = true;
              categoryTitle = map[index];
              for (Category category in mCategories) {
                if (category.name == categoryTitle) {
                  vCategory = category;
                  break;
                }
              }
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
                              padding: const EdgeInsets.only(
                                  top: 10.0, bottom: 4, right: 20),
                              color: Theme.of(context).backgroundColor,
                              child: Text(
                                categoryTitle.toLowerCase(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          vCategory.description.isNotEmpty
                              ? SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 4.0,
                                        bottom: 8,
                                        left: 20,
                                        right: 20),
                                    color: Theme.of(context).backgroundColor,
                                    child: Text(
                                      vCategory.description.toLowerCase(),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      )
                    : const SizedBox(),
                GestureDetector(
                    child: ProductItem(
                      serviceId: widget.blocService.id,
                      product: subProducts[index],
                      tableNumber: mTable.tableNumber,
                      isCommunity: _isCommunity,
                      isOnOffer: isProductOnOffer,
                      offer: productOffer,
                      isCustomerSeated: _isCustomerSeated,
                    ),
                    onTap: () {
                      Product _sProduct = subProducts[index];
                      print(_sProduct.name.toLowerCase() + ' is selected');
                    }),
                index == subProducts.length - 1
                    ? displayExtraInfo()
                    : SizedBox()
              ],
            );
          }),
    );
  }

  displayExtraInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            'Info',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('. all prices are in INR'),
          Text('. standard measure pour for spirits is 30ml'),
          Text(
              '. if you have any allergies or dietary requirements, please let us know. Jain, vegan, gluten and dairy-allergy items are available.'),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
