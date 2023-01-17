import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../db/entity/cart_item.dart';
import '../db/entity/offer.dart';
import '../db/entity/product.dart';
import '../providers/cart.dart';
import '../screens/bloc/product_detail_screen.dart';
import '../utils/string_utils.dart';

class ProductItem extends StatefulWidget {
  final Product product;
  final String serviceId;
  final int tableNumber;
  final bool isCommunity;
  final bool isOnOffer;
  final Offer offer;
  int addCount = 1;

  ProductItem(
      {required this.serviceId,
      required this.product,
      required this.tableNumber,
      required this.isCommunity,
      required this.isOnOffer,
      required this.offer});

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
                  height: 170,
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
                        left: 10, right: 10, top: 1, bottom: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(widget.product.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                )),

                            //check if offer
                            widget.isOnOffer
                                ? Text(
                                    '\u20B9 ${widget.isCommunity ? widget.offer.offerPriceCommunity.toStringAsFixed(2) : widget.offer.offerPricePrivate.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold))
                                : Text(
                                    '\u20B9 ${widget.isCommunity ? widget.product.priceCommunity.toStringAsFixed(2) : widget.product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                            // Icon(Icons.delete_outline)
                          ],
                        ),
                        SizedBox(height: 2),
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent)),
                                  widget.isOnOffer
                                      ? Text(
                                          ' | ' +
                                              widget.offer.offerPercent
                                                  .toStringAsFixed(0) +
                                              '% off',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        )
                                      : SizedBox(height: 0),
                                ],
                              )
                            : widget.isOnOffer
                                ? Text(
                                    ' | ' +
                                        widget.offer.offerPercent
                                            .toStringAsFixed(0) +
                                        '% off',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  )
                                : SizedBox(height: 0),
                        SizedBox(height: 2),
                        Text(
                            StringUtils.firstFewWords(
                                    widget.product.description, 15) +
                                '...',
                            style:
                                TextStyle(fontSize: 15, color: Colors.black54)),
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
                                    String cartId =
                                        StringUtils.getRandomString(20);
                                    //todo: this needs to increment
                                    int cartNumber = 0;
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    String userId = user!.uid;
                                    int timestamp =
                                        Timestamp.now().millisecondsSinceEpoch;
                                    CartItem cartItem = CartItem(
                                        cartId: cartId,
                                        serviceId: widget.serviceId,
                                        billId: '',
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
                                        isCommunity: widget.isCommunity,
                                        quantity: widget.addCount,
                                        createdAt: timestamp,
                                        isCompleted: false,
                                        isBilled: false);

                                    cart.addItem(
                                        cartId,
                                        widget.serviceId,
                                        cartItem.billId,
                                        widget.tableNumber,
                                        cartNumber,
                                        cartItem.userId,
                                        cartItem.productId,
                                        cartItem.productName,
                                        cartItem.productPrice,
                                        widget.isCommunity,
                                        cartItem.quantity,
                                        cartItem.createdAt,
                                        cartItem.isCompleted,
                                        cartItem.isBilled);

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
