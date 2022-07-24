import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/cart_block_item.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bill.dart';
import '../../db/entity/cart_item.dart';
import '../../db/entity/bloc_order.dart';
import '../../db/entity/order.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/ui/Toaster.dart';

class BillScreen extends StatelessWidget {
  Bill bill;
  // todo: this is what we going to use for invoice button creation in the future
  bool isPending;

  BillScreen({required this.bill, required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Screen'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildOrderItems(context)),
        SizedBox(height: 10.0),
        TotalBox(context),
      ],
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    return ListView.builder(
        itemCount: bill.orders.length,
        itemBuilder: (ctx, i) {
          BlocOrder order = bill.orders[i];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,

              children: [
                Text('Order number : ' + order.sequence.toString()),
                renderCartItems(order.cartItems),
                // OrderCardItem(order),
              ],
            ),
          );
        });
  }

  renderCartItems(cartItems) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min, children: cartItems.map<Widget>((cartItem) =>
        Flexible(
          child: CartBlockItem(
            cartItem
          ),
        )
    ).toList());
  }

  Widget TotalBox(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: EdgeInsets.all(5),
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
                '\u20B9${_calculateTotal().toStringAsFixed(2)}',

                style: TextStyle(
                    color: Theme.of(context)
                        .primaryTextTheme
                        .headline6!
                        .color),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            isPending?CompletedButton(bill: bill):SizedBox(),
          ],
        ),
      ),
    );
  }

  _calculateTotal() {
    double total = 0;

    for(BlocOrder order in bill.orders){
      total += order.total;
    }
    return total;
  }
}

class CompletedButton extends StatefulWidget {
  final Bill bill;

  CompletedButton({key, required this.bill}) : super(key: key);

  @override
  _CompletedButtonState createState() => _CompletedButtonState();
}

class _CompletedButtonState extends State<CompletedButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('COMPLETED'),
      onPressed: (widget.bill.orders.length <= 0 || _isLoading)
          ? null : () async {
        setState(() {
          _isLoading = true;
        });

        // mark all cart items as completed
        List<CartItem> _cartItems = [];
        for(BlocOrder order in widget.bill.orders) {
          _cartItems.addAll(order.cartItems);
        }

        for(int i=0;i<_cartItems.length;i++) {
          FirestoreHelper.updateCartItemAsCompleted(_cartItems[i]);
        }

        Toaster.shortToast("Order is marked as completed.");

        // this is where we send the order information to firebase
        String orderId = StringUtils.getRandomString(20);
        // need to know if cart item is community
        // Order order = Order(id: orderId,customerId: _cartItems[0].userId,blocId: _cartItems[0].serviceId, isCommunity: _cartItems[0].)

        setState(() {
          _isLoading = false;
        });
        // widget.cart.clear();
      },
      textColor: Theme.of(context).primaryColor,
    );
  }
}







