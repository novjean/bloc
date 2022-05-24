import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/cart_item.dart';
import '../db/entity/product.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../utils/string_utils.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final BlocDao dao;
  final String serviceId;
  final int tableNumber;

  ProductItem({required this.serviceId, required this.product, required this.dao, required this.tableNumber});

  @override
  Widget build(BuildContext context) {
    var logger = Logger();
    final cart = Provider.of<Cart>(context, listen: false);

    Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => ProductDetailScreen(product: product)),
          );
        },
        child: Hero(
          tag: product.id,
          // 'detail_food$index',
          child: Card(
            child: Row(
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(product.imageUrl), fit: BoxFit.cover
                        // AssetImage(food['image']),
                        ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(product.name),
                            // Icon(Icons.delete_outline)
                          ],
                        ),
                        Text('\u20B9 ${product.price}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            // IconButton(
                            //   icon: Icon(Icons.remove),
                            //   onPressed: () {
                            //     logger.i('remove product from cart.');
                            //   },
                            // ),
                            Container(
                              color: primaryColor,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 12.0,
                              ),
                              child: TextButton(
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  // add it to the cart
                                  String id = StringUtils.getRandomString(20);
                                  //todo: this needs to increment
                                  int cartNumber = 0;
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  String userId = user!.uid;
                                  int timestamp = Timestamp.now().millisecondsSinceEpoch;
                                  CartItem cartitem = CartItem(
                                      id: id,
                                      serviceId: serviceId,
                                      tableNumber: tableNumber,
                                      cartNumber: cartNumber,
                                      userId: userId,
                                      productId: product.id,
                                      productName: product.name,
                                      productPrice: double.parse(
                                          product.price.toString()),
                                      quantity: 1,
                                      createdAt: timestamp,
                                      isCompleted: false);

                                  cart.addItem(
                                      id,
                                      serviceId,
                                      tableNumber,
                                      cartNumber,
                                      userId,
                                      cartitem.productId,
                                      cartitem.productName,
                                      cartitem.productPrice,
                                      cartitem.createdAt, false);

                                  Toaster.shortToast(
                                      product.name + ' is added to cart.');
                                },
                              ),
                            ),
                            // IconButton(
                            //   icon: Icon(Icons.add),
                            //   color: primaryColor,
                            //   onPressed: () {
                            //     logger.i('add product to cart.');
                            //   },
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
