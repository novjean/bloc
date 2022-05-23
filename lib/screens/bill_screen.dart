import 'package:bloc/widgets/cart_block_item.dart';
import 'package:flutter/material.dart';

import '../db/entity/bill.dart';
import '../db/entity/order.dart';

class BillScreen extends StatelessWidget {
  Bill bill;

  BillScreen({required this.bill});

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
          Order order = bill.orders[i];


          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,

              children: [
                Text('Order number : ' + order.number.toString()),
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

  // Widget buildCartItems(BuildContext context) {
  //   return ListView.builder(
  //       itemCount: order.cartItems.length,
  //       itemBuilder: (ctx, i) {
  //         CartItem cartItem = order.cartItems[i];
  //         return CartBlockItem(cartItem);
  //       });
  // }

  Widget TotalBox(BuildContext context) {
    return Card(
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
                '\u20B9${_calculateTotal().toStringAsFixed(2)}',

                style: TextStyle(
                    color: Theme.of(context)
                        .primaryTextTheme
                        .headline6!
                        .color),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            // OrderButton(cart: cart, dao: dao),
          ],
        ),
      ),
    );
  }

  _calculateTotal() {
    double total = 0;

    for(Order order in bill.orders){
      total += order.total;
    }
    return total;
  }
}







