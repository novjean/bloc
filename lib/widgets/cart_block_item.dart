import 'package:bloc/db/entity/cart_item.dart';
import 'package:flutter/material.dart';

class CartBlockItem extends StatelessWidget {
  CartItem cartItem;

  CartBlockItem(this.cartItem);

  @override
  Widget build(BuildContext context) {
    return Card(
      // symmetric is used to have different margins for left, right, top and bottom
      margin: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).highlightColor,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: FittedBox(
                child: Text('${cartItem.quantity} x'),
              ),
            ),
          ),
          title: Text(cartItem.productName),
          subtitle: Text('Price: \u20B9' + cartItem.productPrice.toStringAsFixed(2)),
          trailing: Text('\u20B9' + (cartItem.productPrice * cartItem.quantity).toStringAsFixed(2)),
        ),
      ),
    );

  }
}
