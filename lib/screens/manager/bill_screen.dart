import 'package:bloc/utils/string_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bill.dart';
import '../../db/entity/cart_item.dart';
import '../../db/entity/bloc_order.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/bill_cart_item.dart';
import '../../widgets/ui/toaster.dart';

class BillScreen extends StatefulWidget {
  Bill bill;
  bool isPending;

  BillScreen(
      {required this.bill, required this.isPending});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  double total = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bills'),
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
    total = _calculateTotal();
    if (total <= 0) {
      Navigator.of(context).pop();
    }

    return ListView.builder(
        itemCount: widget.bill.orders.length,
        itemBuilder: (ctx, i) {
          BlocOrder order = widget.bill.orders[i];
          return Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('order# ' + widget.bill.orders[i].sequence.toString())
                  ]),
                ),
                renderCartItems(
                    order.cartItems, total, order.sequence.toString()),
                // OrderCardItem(order),
              ],
            ),
          );
        });
  }

  renderCartItems(cartItems, double total, String orderSequence) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: cartItems
            .map<Widget>((cartItem) => Flexible(
                  child: BillCartItem(
                    cartItem: cartItem,
                    update: _update,
                    orderSequence: orderSequence,
                  ),
                ))
            .toList());
  }

  Widget TotalBox(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'total',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            // spacer is a special widget which takes up all the space it can
            Spacer(),
            Chip(
              label: Text(
                '\u20B9${total.toStringAsFixed(2)}',
                style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.headline6!.color),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            widget.isPending
                ? CompletedButton(bill: widget.bill)
                : GenerateBillButton(bill: widget.bill),
          ],
        ),
      ),
    );
  }

  int _count = 0;

  // Pass this method to the child page.
  void _update(int count) {
    setState(() {
      _count = count;
    });
  }

  _calculateTotal() {
    double total = 0;

    for (BlocOrder order in widget.bill.orders) {
      for (CartItem cartItem in order.cartItems) {
        if (cartItem.quantity <= 0) continue;
        double amount = cartItem.productPrice * cartItem.quantity;
        total += amount;
      }
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
    return ElevatedButton(
      child: _isLoading ? CircularProgressIndicator() : Text('completed'),
      onPressed: (widget.bill.orders.length <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              // mark all cart items as completed
              List<CartItem> _cartItems = [];
              for (BlocOrder order in widget.bill.orders) {
                _cartItems.addAll(order.cartItems);
              }

              //todo: this can be used for order id logic later on
              // String billId = StringUtils.getRandomString(20);

              for (int i = 0; i < _cartItems.length; i++) {
                // _cartItems[i].billId = billId;
                FirestoreHelper.updateCartItemAsCompleted(_cartItems[i]);
              }

              print('order has been marked as completed');
              Toaster.shortToast("order is marked as completed");

              // this is where we send the order information to firebase
              // String orderId = StringUtils.getRandomString(20);
              // need to know if cart item is community
              // Order order = Order(id: orderId,customerId: _cartItems[0].userId,blocId: _cartItems[0].serviceId, isCommunity: _cartItems[0].)

              setState(() {
                _isLoading = false;
              });
            },
    );
  }
}

class GenerateBillButton extends StatefulWidget {
  final Bill bill;

  GenerateBillButton({key, required this.bill}) : super(key: key);

  @override
  _GenerateBillButtonState createState() => _GenerateBillButtonState();
}

class _GenerateBillButtonState extends State<GenerateBillButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: _isLoading ? CircularProgressIndicator() : Text('generate bill'),
      onPressed: (widget.bill.orders.length <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              // mark all cart items as completed
              List<CartItem> _cartItems = [];
              for (BlocOrder order in widget.bill.orders) {
                _cartItems.addAll(order.cartItems);
              }

              //todo: should consider changing this to time
              String billId = StringUtils.getRandomString(28);

              for (int i = 0; i < _cartItems.length; i++) {
                FirestoreHelper.updateCartItemBilled(
                    _cartItems[i].cartId, billId);
              }

              print("bill is generated with id : " + billId);
              Toaster.shortToast('bill has been generated');

              // this is where we send the order information to firebase
              // String orderId = StringUtils.getRandomString(20);
              // need to know if cart item is community
              // Order order = Order(id: orderId,customerId: _cartItems[0].userId,blocId: _cartItems[0].serviceId, isCommunity: _cartItems[0].)

              setState(() {
                _isLoading = false;
              });
            },
    );
  }
}
