import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/screens/manager/inventory/product_add_edit_screen.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../../../db/entity/category.dart';
import '../../../db/entity/manager_service.dart';
import '../../../db/entity/product.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/constants.dart';
import '../../../utils/file_utils.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/manager/manage_product_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/sized_listview_block.dart';

class ManageProductsScreen extends StatefulWidget {
  String serviceId;
  ManagerService managerService;

  ManageProductsScreen(
      {required this.serviceId, required this.managerService});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  static const String _TAG = 'ManageProductsScreen';

  String _sType = 'Alcohol';

  List<Category> mCategories = [];
  var isCategoriesLoading = true;

  List<String> sCategoryNames = [];
  List<Category> sCategories = [];
  List<String> sCategoryIds = [];

  List<Product> mProducts = [];
  List<Product> searchList = [];
  bool isSearching = false;

  @override
  void initState() {
    FirestoreHelper.pullCategories(widget.serviceId).then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
          final Category category = Fresh.freshCategoryMap(map, false);
          mCategories.add(category);
        }

        setState(() {
          isCategoriesLoading = false;
        });
      } else {
        setState(() {
          isCategoriesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: 'manage products'),
        titleSpacing: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showActionsDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'actions',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.science,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: isCategoriesLoading? const LoadingWidget(): _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        _displayOptions(context),
        const Divider(),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
          child: TextField(
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'search by name ',
                hintStyle: TextStyle(color: Constants.primary)
            ),
            autofocus: true,
            style: const TextStyle(fontSize: 17, color: Constants.primary),
            onChanged: (val) {
              if(val.trim().isNotEmpty){
                isSearching = true;
              } else {
                isSearching = false;
              }

              searchList.clear();

              for(var i in mProducts){
                if(i.name.toLowerCase().contains(val.toLowerCase())){
                  searchList.add(i);
                }
              }
              setState(() {
              });
            } ,
          ),
        ),
        const Divider(),
        buildProducts(context),
        const SizedBox(height: 10.0),
      ],
    );
  }

  _displayOptions(BuildContext context) {
    List<String> _options = ['Alcohol', 'Food'];
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: containerHeight,
      child: ListView.builder(
          itemCount: _options.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: _options[index].toLowerCase(),
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 2,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    _sType = _options[index];
                    Logx.i(_TAG, '$_sType products display option is selected');
                  });
                });
          }),
    );
  }

  buildProducts(BuildContext context) {
    Stream<QuerySnapshot<Object?>> stream;

    if(sCategoryIds.isEmpty){
      stream = FirestoreHelper.getProductsByType(widget.serviceId, _sType);
    } else {
      stream = FirestoreHelper().getProductByCategories(widget.serviceId, sCategoryNames);
    }

    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          mProducts = [];

          if(!snapshot.hasData){
            return const Center(child: Text('no products found!'));
          }

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Product product = Fresh.freshProductMap(map, false);
            mProducts.add(product);

            if (i == snapshot.data!.docs.length - 1) {
              mProducts.sort((a, b) => a.category.compareTo(b.category));
              return _displayProductsList(context);
            }
          }
          return const LoadingWidget();
        });
  }

  _displayProductsList(BuildContext context) {
    List<Product> products = isSearching?searchList:mProducts;

    return Expanded(
      child: ListView.builder(
          itemCount: products.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageProductItem(
                  serviceId: widget.serviceId,
                  product: products[index],
                ),
                onTap: () {
                  Product _sProduct = products[index];
                  print('${_sProduct.name} is selected');
                });
          }),
    );
  }

  showActionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'actions',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    width: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('add'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  ProductAddEditScreen(product: Dummy.getDummyProduct(widget.serviceId, UserPreferences.myUser.id),task: 'add',)),
                                        );
                                      },
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.add),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height:10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('filter'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        showFilterDialog(context);
                                      },
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.filter_list),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height:10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('share products'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () async {
                                        Navigator.of(ctx).pop();

                                        String listText = '';
                                        for(Product product in mProducts){
                                          listText += '${product.category}, ${product.name}, '
                                              '${product.description.replaceAll(',','.')}, ${product.price}, ${product.priceBottle}\n';
                                        }

                                        String rand = StringUtils.getRandomString(5);
                                        String fileName = 'bloc-products-$rand.csv';
                                        FileUtils.shareCsvFile(fileName, listText, 'bloc menu');
                                      },
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.share_outlined),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height:10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showFilterDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'filter',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 250,
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('categories:\n'),
                        _showCategoriesDropdown(context),
                        // const Text('\ngender:\n'),
                        // _displayGenderDropdown(context),
                        // const Text('\nmode:\n'),
                        // _displayModesDropdown(context)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text("confirm"),
              onPressed: () {
                setState(() {});
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showCategoriesDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: MultiSelectDialogField(
        items: mCategories
            .map((e) => MultiSelectItem(e,
            '${e.name.toLowerCase()} | ${e.type.toLowerCase()}'))
            .toList(),
        initialValue: sCategories.map((e) => e).toList(),
        listType: MultiSelectListType.CHIP,
        buttonIcon: Icon(
          Icons.arrow_drop_down,
          color: Colors.grey.shade700,
        ),
        title: const Text('select categories'),
        buttonText: const Text(
          'select',
          style: TextStyle(color: Constants.lightPrimary),
        ),
        decoration: BoxDecoration(
          color: Constants.background,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: Constants.primary,
            width: 0.0,
          ),
        ),
        searchable: true,
        onConfirm: (values) {
          sCategories = values as List<Category>;
          sCategoryIds = [];
          sCategoryNames = [];

          for (Category category in sCategories) {
            sCategoryIds.add(category.id);
            sCategoryNames.add(category.name);
          }

          if (sCategoryIds.isEmpty) {
            Logx.i(_TAG, 'no categories selected');
          } else {
            Logx.i(_TAG, '${sCategoryIds.length} categories selected');
          }
        },
      ),
    );
  }

}
