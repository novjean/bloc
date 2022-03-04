import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/cart_item.dart';
import '../utils/string_utils.dart';

class CartBlock extends StatelessWidget {
  CartItem cartItem;
  BlocDao dao;

  CartBlock({required this.cartItem, required this.dao});

  @override
  Widget build(BuildContext context) {
    var logger = Logger();
    Color primaryColor = Theme
        .of(context)
        .primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      child: GestureDetector(
        onTap: () {
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //       builder: (ctx) => ProductDetailScreen(product: product)),
          // );
        },
        child: Hero(
          tag: cartItem.id,
          child: Card(
            child: Row(
              children: <Widget>[
                // Container(
                //   height: 60,
                //   width: 100,
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //         image: NetworkImage(product.imageUrl),
                //         fit: BoxFit.cover
                //       // AssetImage(food['image']),
                //     ),
                //   ),
                // ),
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
                            Text(cartItem.productName),
                            // Icon(Icons.delete_outline)
                          ],
                        ),
                        Text('\u20B9 ${cartItem.productPrice * cartItem.quantity}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                logger.i('remove product from cart.');
                              },
                            ),

                            // Container(
                            //   color: primaryColor,
                            //   margin: const EdgeInsets.symmetric(
                            //     horizontal: 10.0,
                            //   ),
                            //   padding: const EdgeInsets.symmetric(
                            //     vertical: 4.0,
                            //     horizontal: 12.0,
                            //   ),
                            //   child: TextButton(
                            //     child: Text('Add',
                            //       style: TextStyle(
                            //         color: Colors.white,
                            //       ),
                            //     ),
                            //     onPressed: () {
                            //       // add it to the cart
                            //       // String id = StringUtils.getRandomString(20);
                            //       // int cartNumber = 0;
                            //       // final user = FirebaseAuth.instance.currentUser;
                            //       // String userId = user!.uid;
                            //       // String timestamp = Timestamp.now().toString();
                            //       // CartItem cartitem = CartItem(id, cartNumber, userId, product.id, 1, timestamp);
                            //       // BlocRepository.insertCartItem(dao, cartitem);
                            //       //
                            //       // Fluttertoast.showToast(
                            //       //     msg: product.name + ' is added to cart.',
                            //       //     toastLength: Toast.LENGTH_SHORT,
                            //       //     gravity: ToastGravity.BOTTOM,
                            //       //     timeInSecForIosWeb: 1,
                            //       //     backgroundColor: Colors.grey,
                            //       //     textColor: Colors.white,
                            //       //     fontSize: 16.0
                            //       // );
                            //     },
                            //   ),
                            // ),

                            IconButton(
                              icon: Icon(Icons.add),
                              color: primaryColor,
                              onPressed: () {
                                logger.i('add product to cart.');
                              },
                            ),
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