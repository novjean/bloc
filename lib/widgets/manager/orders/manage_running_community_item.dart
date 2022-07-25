import 'package:bloc/db/entity/cart_item.dart';
import 'package:flutter/material.dart';

class ManageRunningCommunityItem extends StatelessWidget {
  CartItem cartItem;

  ManageRunningCommunityItem(this.cartItem);

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
                child: Text('ON'),
              ),
            ),
          ),
          title: Text(cartItem.productName),
          subtitle: Text('Offer : 10% off until 20:25'),
          trailing: Text('Price: \u20B9' + cartItem.productPrice.toStringAsFixed(2)),
        ),
      ),
    );

  }
}
