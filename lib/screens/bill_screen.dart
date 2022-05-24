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
            CompletedButton(bill: bill),
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

        // keeping this here for fixed timestamp throughout the cart
        // Timestamp timestamp = Timestamp.now();
        // int millisecondsSinceEpoch = timestamp.millisecondsSinceEpoch;
        // // need to store this in floor
        // for (int i = 0; i < widget.cart.items.length; i++) {
        //   BlocRepository.insertCartItem(
        //       widget.dao, widget.cart.items.values.elementAt(i));
        //
        //   // send it to firebase
        //   //todo: will need to check if the upload actually went through
        //   FirestoreHelper.uploadCartItem(
        //       widget.cart.items.values.elementAt(i), timestamp, millisecondsSinceEpoch);
        // }
        //
        // Toaster.shortToast("Order sent.");

        setState(() {
          _isLoading = false;
        });
        // widget.cart.clear();
      },
      textColor: Theme.of(context).primaryColor,
    );
  }
}







