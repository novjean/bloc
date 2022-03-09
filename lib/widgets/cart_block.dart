import 'package:bloc/db/bloc_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/cart_item.dart';
import '../providers/cart.dart';
import 'ui/Toaster.dart';

class CartBlock extends StatelessWidget {
  CartItem cartItem;
  BlocDao dao;

  CartBlock({required this.cartItem, required this.dao});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // the key is important to manage
      key: ValueKey(cartItem.id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      // defines the swiping direction
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text(
              'Do you want to remove the item from the cart?',
            ),
            actions: [
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        //direction to check which direction the swipe is going to
        BlocRepository.deleteCartItems(dao, cartItem.productId);
        Toaster.shortToast(cartItem.productName + ' has been removed.');

        Provider.of<Cart>(context, listen: false).removeItem(cartItem.productId);
      },
      child: Card(
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
                  child: Text('\u20B9${cartItem.productPrice}'),
                ),
              ),
            ),
            title: Text(cartItem.productName),
            subtitle: Text('Total: \u20B9${(cartItem.productPrice * cartItem.quantity)}'),
            trailing: Text('${cartItem.quantity} x'),
          ),
        ),
      ),
    );
  }
}
