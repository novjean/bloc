import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/cart_item.dart';
import '../db/entity/product.dart';
import '../providers/cart.dart';
import '../screens/bloc/product_detail_screen.dart';
import '../utils/string_utils.dart';

class ProductItem extends StatefulWidget {
  final Product product;
  final BlocDao dao;
  final String serviceId;
  final int tableNumber;
  final bool isCommunity;
  int addCount = 1;

  ProductItem(
      {required this.serviceId,
      required this.product,
      required this.dao,
      required this.tableNumber,
      required this.isCommunity});

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    var logger = Logger();
    final cart = Provider.of<Cart>(context, listen: false);

    Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 1.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => ProductDetailScreen(product: widget.product)),
          );
        },
        child: Hero(
          tag: widget.product.id,
          child: Card(
            child: Row(
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(widget.product.imageUrl),
                        fit: BoxFit.cover
                        // AssetImage(food['image']),
                        ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 9, right: 0, top: 0, bottom: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(widget.product.name,
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            Text(
                                '\u20B9 ${widget.isCommunity ? widget.product.priceCommunity.toStringAsFixed(2) : widget.product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            // Icon(Icons.delete_outline)
                          ],
                        ),
                        SizedBox(height: 5),
                        widget.isCommunity
                            ? Row(
                                children: [
                                  Text(
                                      '\u20B9 ${widget.product.priceLowest.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  Text(' | '),
                                  Text(
                                      '\u20B9 ${widget.product.priceHighest.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent)),
                                ],
                              )
                            : SizedBox(height: 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (widget.addCount > 1) {
                                    widget.addCount--;
                                    print('decrement add count to ' +
                                        widget.addCount.toString());
                                  } else {
                                    print('add count is at ' +
                                        widget.addCount.toString());
                                  }
                                });
                              },
                            ),
                            Container(
                                // color: primaryColor,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 2.0,
                                ),
                                child: ButtonWidget(
                                  text: widget.addCount == 1
                                      ? 'Add'
                                      : 'Add ' + widget.addCount.toString(),
                                  onClicked: () {
                                    // add it to the cart
                                    String id = StringUtils.getRandomString(20);
                                    //todo: this needs to increment
                                    int cartNumber = 0;
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    String userId = user!.uid;
                                    int timestamp =
                                        Timestamp.now().millisecondsSinceEpoch;
                                    CartItem cartitem = CartItem(
                                        id: id,
                                        serviceId: widget.serviceId,
                                        tableNumber: widget.tableNumber,
                                        cartNumber: cartNumber,
                                        userId: userId,
                                        productId: widget.product.id,
                                        productName: widget.product.name,
                                        productPrice: double.parse(widget
                                                .isCommunity
                                            ? widget.product.priceCommunity
                                                .toString()
                                            : widget.product.price.toString()),
                                        quantity: widget.addCount,
                                        createdAt: timestamp,
                                        isCompleted: false);

                                    cart.addItem(
                                        id,
                                        widget.serviceId,
                                        widget.tableNumber,
                                        cartNumber,
                                        userId,
                                        cartitem.productId,
                                        cartitem.productName,
                                        cartitem.productPrice,
                                        cartitem.quantity,
                                        cartitem.createdAt,
                                        false);

                                    setState(() {
                                      widget.addCount = 1;
                                    });

                                    Toaster.shortToast(widget.product.name +
                                        ' is added to cart.');
                                  },
                                )),
                            IconButton(
                              icon: Icon(Icons.add),
                              color: primaryColor,
                              onPressed: () {
                                setState(() {
                                  widget.addCount++;
                                });
                                print('increment add count to ' +
                                    widget.addCount.toString());
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
