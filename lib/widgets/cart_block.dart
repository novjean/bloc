import 'package:bloc/db/bloc_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/cart_item.dart';
import '../providers/cart.dart';
import 'cart_block_item.dart';
import 'ui/toaster.dart';

class CartBlock extends StatelessWidget {
  CartItem cartItem;
  BlocDao dao;

  CartBlock({required this.cartItem, required this.dao});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // the key is important to manage
      key: ValueKey(cartItem.cartId),
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

        Provider.of<Cart>(context, listen: false).removeItem(Cart.getCartKey(cartItem.productId, cartItem.productPrice));
      },
      child: CartBlockItem(cartItem)
    );
  }
}
