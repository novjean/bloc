import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../screens/bloc/cart_screen.dart';

class CartWidget extends StatefulWidget {

  CartWidget({key}) : super(key: key);

  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (ctx) => CartScreen()),
        );
      },
      child: Card(
        color: Theme.of(context).primaryColorLight,
        margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cart.itemCount.toString() + ' item',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              // spacer is a special widget which takes up all the space it can
              Spacer(),
              Text(
                  '\u20B9${cart.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).focusColor,)

              ),


              SizedBox(width: 15),
              OrderButton(cart: cart),
            ],
          ),
        ),
      ),
    );
  }
}