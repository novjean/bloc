import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../db/entity/cart_item.dart';
import '../db/entity/product.dart';
import '../screens/product_detail_screen.dart';
import '../utils/string_utils.dart';

class NewProductItem extends StatelessWidget {
  final Product product;

  NewProductItem({required this.product});

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
                                  Timestamp timestamp = Timestamp.now();
                                  CartItem cartitem = CartItem(id, cartNumber, userId, product.id, 1, timestamp);

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