import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../db/dao/bloc_dao.dart';
import '../../db/entity/bloc_service.dart';
import '../../db/entity/cart_item.dart';
import '../../providers/cart.dart' show Cart;
import '../../widgets/cart_block.dart';
import '../../widgets/ui/toaster.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  BlocDao dao;
  BlocService service;
  int tableNumber;

  CartScreen(
      {key,
      required this.dao,
      required this.service,
      required this.tableNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.length == 0
                ? Center(
                    child: Text('No items in the cart!'),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) => CartBlock(
                      cartItem: CartItem(
                        cartId: cart.items.values.toList()[i].cartId,
                        serviceId: cart.items.values.toList()[i].serviceId,
                        billId: cart.items.values.toList()[i].billId,
                        tableNumber: cart.items.values.toList()[i].tableNumber,
                        cartNumber: cart.items.values.toList()[i].cartNumber,
                        userId: cart.items.values.toList()[i].userId,
                        productId: cart.items.values.toList()[i].productId,
                        productName: cart.items.values.toList()[i].productName,
                        productPrice:
                            cart.items.values.toList()[i].productPrice,
                        isCommunity: cart.items.values.toList()[i].isCommunity,
                        quantity: cart.items.values.toList()[i].quantity,
                        createdAt: cart.items.values.toList()[i].createdAt,
                        isCompleted: cart.items.values.toList()[i].isCompleted,
                      ),
                      dao: dao,
                    ),
                  ),
          ),
          SizedBox(
            height: 10,
          ),
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  // spacer is a special widget which takes up all the space it can
                  Spacer(),
                  Chip(
                    label: Text(
                      '\u20B9${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6!
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart, dao: dao),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// leaving this widget here since it is only used by this screen
class OrderButton extends StatefulWidget {
  final Cart cart;
  final BlocDao dao;

  OrderButton({key, required this.cart, required this.dao}) : super(key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              //async above as add order returns a future
              setState(() {
                _isLoading = true;
              });

              // keeping this here for fixed timestamp throughout the cart
              Timestamp timestamp = Timestamp.now();
              final int millisecondsSinceEpoch = timestamp.millisecondsSinceEpoch;
              // need to store this in floor
              for (int i = 0; i < widget.cart.items.length; i++) {
                BlocRepository.insertCartItem(
                    widget.dao, widget.cart.items.values.elementAt(i));

                // send it to firebase
                //todo: will need to check if the upload actually went through
                FirestoreHelper.uploadCartItem(
                    widget.cart.items.values.elementAt(i),
                    timestamp,
                    millisecondsSinceEpoch);
              }

              Toaster.shortToast("Order sent.");

              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
