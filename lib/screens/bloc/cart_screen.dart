import 'package:bloc/db/shared_preferences/table_preferences.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../db/entity/cart_item.dart';
import '../../db/entity/order_bloc.dart';
import '../../providers/cart.dart' show Cart;
import '../../utils/string_utils.dart';
import '../../widgets/cart_block.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/toaster.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  CartScreen({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'cart',),
        titleSpacing: 0,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Text(
                      'no items in the cart!',
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
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
                        isBilled: cart.items.values.toList()[i].isBilled,
                      ),
                    ),
                  ),
          ),
          SizedBox(
            height: 10,
          ),
          Card(
            color: Theme.of(context).primaryColorLight,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'total',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // spacer is a special widget which takes up all the space it can
                  Spacer(),
                  Text(
                    '\u20B9${cart.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16),
                  ),
                  const SizedBox(width: 15),
                  OrderButton(cart: cart),
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

  OrderButton({key, required this.cart}) : super(key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: _isLoading ? const LoadingWidget() : const Text('order now'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              //async above as add order returns a future
              setState(() {
                _isLoading = true;
              });

              if (widget.cart.items.isNotEmpty) {
                // keeping this here for fixed timestamp throughout the cart
                Timestamp timestamp = Timestamp.now();
                final int createdAtMillis = timestamp.millisecondsSinceEpoch;
                double amount = 0.0;
                int tableNumber =
                    widget.cart.items.values.elementAt(0).tableNumber;

                List<String> cartIds = [];
                for (int i = 0; i < widget.cart.items.length; i++) {
                  //todo: will need to check if the upload actually went through
                  CartItem cartItem = widget.cart.items.values.elementAt(i);
                  cartItem.createdAt = createdAtMillis;
                  FirestoreHelper.pushCartItem(cartItem);
                  cartIds.add(cartItem.cartId);
                  amount += cartItem.productPrice * cartItem.quantity;
                }

                //create an order object and push it
                OrderBloc order = OrderBloc(
                    id: StringUtils.getRandomString(28),
                    customerId: UserPreferences.myUser.id,
                    blocServiceId: UserPreferences.myUser.blocServiceId,
                    creationTime: createdAtMillis,
                    isCommunity: false,
                    amount: amount,
                    completionTime: 0,
                    cartIds: cartIds,
                    tableNumber: tableNumber,
                    captainId: TablePreferences.myTable.captainId,
                    sequence: 1);

                FirestoreHelper.pushOrder(order);

                Toaster.shortToast("order sent");

                setState(() {
                  _isLoading = false;
                });
                widget.cart.clear();
              }
            },
    );
  }
}
