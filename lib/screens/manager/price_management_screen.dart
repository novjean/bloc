import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/bloc_repository.dart';
import '../../db/dao/bloc_dao.dart';
import '../../db/entity/manager_service.dart';
import '../../db/entity/product.dart';
import '../../utils/product_utils.dart';
import '../../widgets/manager/manage_product_item.dart';
import '../../widgets/product_item.dart';

class PriceManagementScreen extends StatefulWidget{
  String serviceId;
  BlocDao dao;
  ManagerService managerService;


  PriceManagementScreen(
      {required this.serviceId,
        required this.dao,
        required this.managerService});

  @override
  State<PriceManagementScreen> createState() => _PriceManagementScreenState();
}

class _PriceManagementScreenState extends State<PriceManagementScreen> {
  late Future<List<Product>> fProducts;
  var _categorySelected = 0;
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
      appBar: AppBar(title: Text(widget.managerService.name)),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //           builder: (ctx) => NewServiceTableScreen(serviceId: serviceId)),
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context, widget.managerService),
    );
  }

  _buildBody(BuildContext context, ManagerService managerService) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // CoverPhoto(service.name, service.imageUrl),
          SizedBox(height: 2.0),
          // _buildTables(context),
          // SizedBox(height: 5.0),
          buildProducts(context),
          // SizedBox(height: 50.0),
        ],
      ),
    );
  }

  /** Items List **/
  buildProducts(BuildContext context) {
    final Stream<QuerySnapshot> _itemsStream = FirebaseFirestore.instance
        .collection('products')
        .where('serviceId', isEqualTo: widget.serviceId)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _itemsStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // if(snapshot.data!.docs.length>0) {
        //   BlocRepository.clearProducts(widget.dao);
        // }

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
    // if (_categorySelected == 0) {
    //   fProducts = BlocRepository.getProductsByCategory(widget.dao, "Food");
    // } else {
    //   fProducts = BlocRepository.getProductsByCategory(widget.dao, "Alcohol");
    // }

    fProducts = BlocRepository.getProductsByCategory(widget.dao, "Alcohol");

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

              return ManageProductItem(
                serviceId : widget.serviceId,
                product: product,
                dao: widget.dao,
              );
            },
          );
        });
  }
}