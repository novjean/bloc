import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../db/entity/cart_item.dart';
import '../providers/cart.dart';
import '../utils/string_utils.dart';

class BillCartItem extends StatefulWidget {
  CartItem cartItem;
  final ValueChanged<int> update;
  String orderSequence;

  BillCartItem(
      {Key? key, required this.cartItem,
      required this.update,
      required this.orderSequence}) : super(key: key);

  @override
  State<BillCartItem> createState() => _BillCartItemState();
}

class _BillCartItemState extends State<BillCartItem> {

  @override
  Widget build(BuildContext context) {
    return widget.cartItem.quantity <= 0
        ? const SizedBox()
        : displayCard(context);
  }

  displayCard(BuildContext context) {
    return Card(
      // symmetric is used to have different margins for left, right, top and bottom
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          child: Hero(
            tag: StringUtils.getRandomString(28),
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 1, bottom: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    widget.cartItem.productName.toLowerCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  flex: 4,
                                ),

                                Flexible(
                                  child: Text('\u20B9' +
                                      (widget.cartItem.productPrice *
                                              widget.cartItem.quantity)
                                          .toStringAsFixed(2)),
                                  flex: 1,
                                ),

                                // Icon(Icons.delete_outline)
                              ],
                            ),
                          ),
                          // widget.isCommunity
                          //     ? Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     //\u20B9
                          //     Text(
                          //         widget.product.priceLowest
                          //             .toStringAsFixed(0),
                          //         style: const TextStyle(
                          //             fontSize: 14,
                          //             fontWeight: FontWeight.bold,
                          //             color: Colors.green)),
                          //     Text(' | '),
                          //     Text(
                          //         widget.product.priceHighest
                          //             .toStringAsFixed(0),
                          //         style: const TextStyle(
                          //             fontSize: 14,
                          //             fontWeight: FontWeight.bold,
                          //             color: Colors.redAccent)),
                          //     widget.isOnOffer
                          //         ? Text(
                          //       ' | ' +
                          //           widget.offer.offerPercent
                          //               .toStringAsFixed(0) +
                          //           '% off',
                          //       style: const TextStyle(
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.blue),
                          //     )
                          //         : const SizedBox(height: 0),
                          //   ],
                          // )
                          //     : widget.isOnOffer
                          //     ? Text(
                          //   ' | ' +
                          //       widget.offer.offerPercent
                          //           .toStringAsFixed(0) +
                          //       '% off',
                          //   style: const TextStyle(
                          //       fontSize: 14,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.blue),
                          // )
                          //     : const SizedBox(height: 0),
                          const SizedBox(height: 5),

                          Text('price: \u20B9' +
                              widget.cartItem.productPrice.toStringAsFixed(2)),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    int quantity = widget.cartItem.quantity;

                                    if (quantity > 1) {
                                      widget.cartItem.quantity =
                                          widget.cartItem.quantity - 1;
                                      print('decrement count to ' +
                                          widget.cartItem.quantity.toString());

                                      FirestoreHelper.pushCartItem(
                                          widget.cartItem);
                                    } else {
                                      widget.cartItem.quantity =
                                          widget.cartItem.quantity - 1;
                                      FirestoreHelper.deleteCartItem(
                                          widget.cartItem.cartId);
                                      print('removed cart item ' +
                                          widget.cartItem.productName);

                                      widget.update(100);
                                    }
                                  });
                                },
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 1.0,
                                    horizontal: 0.0,
                                  ),
                                  child: ButtonWidget(
                                    text: widget.cartItem.quantity.toString(),
                                    onClicked: () {
                                      // addProductToCart(cart);
                                    },
                                  )),
                              IconButton(
                                icon: const Icon(Icons.add),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  setState(() {
                                    int quantity = widget.cartItem.quantity + 1;
                                    widget.cartItem.quantity = quantity;

                                    if (quantity > 1) {
                                      print('increment count to ' +
                                          widget.cartItem.quantity.toString());

                                      FirestoreHelper.pushCartItem(
                                          widget.cartItem);
                                    }
                                  });
                                },
                              )
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

        // ListTile(
        //   leading: CircleAvatar(
        //     backgroundColor: Theme.of(context).highlightColor,
        //     child: Padding(
        //       padding: EdgeInsets.all(5),
        //       child: FittedBox(
        //         child: Text('${cartItem.quantity} x'),
        //       ),
        //     ),
        //   ),
        //   title: Text(cartItem.productName),
        //   subtitle: Text('price: \u20B9' + cartItem.productPrice.toStringAsFixed(2)),
        //   trailing: Text('\u20B9' + (cartItem.productPrice * cartItem.quantity).toStringAsFixed(2)),
        // ),
      ),
    );
  }

  addProductToCart(Cart cart) {
    // add it to the cart
    String cartId = StringUtils.getRandomString(20);
    //todo: this needs to increment
    int cartNumber = 0;
    final user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    int timestamp = Timestamp.now().millisecondsSinceEpoch;
    CartItem cartItem = CartItem(
        cartId: cartId,
        serviceId: widget.cartItem.serviceId,
        billId: '',
        tableNumber: widget.cartItem.tableNumber,
        cartNumber: cartNumber,
        userId: userId,
        productId: widget.cartItem.productId,
        productName: widget.cartItem.productName,
        productPrice: widget.cartItem.productPrice,
        isCommunity: false,
        quantity: widget.cartItem.quantity,
        createdAt: timestamp,
        isCompleted: false,
        isBilled: false);

    cart.addItem(
        cartId,
        widget.cartItem.serviceId,
        cartItem.billId,
        widget.cartItem.tableNumber,
        cartNumber,
        cartItem.userId,
        cartItem.productId,
        cartItem.productName,
        cartItem.productPrice,
        //todo: hardcoding not community, fix this later
        false,
        cartItem.quantity,
        cartItem.createdAt,
        cartItem.isCompleted,
        cartItem.isBilled);

    print(widget.cartItem.productName + ' is altered in billing');

    // setState(() {
    //   widget.addCount = 1;
    // });

    // Toaster.shortToast(widget.product.name.toLowerCase() + ' is added to cart');
  }

  void updateCartItem(CartItem cartItem) {}
}
