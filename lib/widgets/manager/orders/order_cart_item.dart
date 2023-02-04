import 'package:flutter/material.dart';

import '../../../db/entity/cart_item.dart';

class OrderCartItem extends StatelessWidget {
  CartItem cartItem;

  OrderCartItem({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(cartItem.productName.toLowerCase()),
          ),
          flex: 2,
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\u20B9' +
                  cartItem.productPrice.toStringAsFixed(2) +
                  ' x ${cartItem.quantity}'),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text('\u20B9' +
                    (cartItem.productPrice * cartItem.quantity)
                        .toStringAsFixed(2)),
              )
            ],
          ),
          flex: 2,
        ),
      ]),
    );
  }
}
