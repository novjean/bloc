import 'package:bloc/db/bloc_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/cart_item.dart';
import '../db/entity/product.dart';
import '../screens/product_detail_screen.dart';
import '../utils/string_utils.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final BlocDao dao;

  ProductItem({required this.product, required this.dao});

  @override
  Widget build(BuildContext context) {
    var logger = Logger();
    Color primaryColor = Theme
        .of(context)
        .primaryColor;

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
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover
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
                                child: Text('Add',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                ),
                                onPressed: () {
                                  // add it to the cart
                                  String id = StringUtils.getRandomString(20);
                                  int cartNumber = 0;
                                  final user = FirebaseAuth.instance.currentUser;
                                  String userId = user!.uid;
                                  String timestamp = Timestamp.now().toString();
                                  CartItem cartitem = CartItem(id, cartNumber, userId, product.id, product.name, product.price, 1, timestamp);
                                  BlocRepository.insertCartItem(dao, cartitem);

                                  Fluttertoast.showToast(
                                      msg: product.name + ' is added to cart.',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
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