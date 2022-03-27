import 'package:bloc/db/entity/cart_item.dart';
import 'package:flutter/material.dart';

import '../db/entity/order.dart';

class OrderItem extends StatelessWidget {
  Order order;

  OrderItem({required this.order});

  @override
  Widget build(BuildContext context) {
    int cartItemsLength = order.cartItems.length;

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Add one stop for each color. Stops should increase from 0 to 1
                  stops: [0.2, 0.7],
                  colors: [
                    Color.fromARGB(100, 0, 0, 0),
                    Color.fromARGB(100, 0, 0, 0),
                  ],
                  // stops: [0.0, 0.1],
                ),
              ),
              height: (MediaQuery.of(context).size.height / 15) * cartItemsLength,
              width: MediaQuery.of(context).size.height / 1,
            ),
            Center(
              child: Container(
                height: (MediaQuery.of(context).size.height / 15) * cartItemsLength,
                width: MediaQuery.of(context).size.height / 1,
                padding: const EdgeInsets.all(0),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemExtent: 50,
                    itemCount: order.cartItems == null ? 0 : order.cartItems.length,
                    itemBuilder: (BuildContext ctx, int index){
                      CartItem ci = order.cartItems[index];

                      return CartItemList(context, ci);

                      // return Text(ci.productName + ' * ' + ci.productPrice.toString());

                    })
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget CartItemList(BuildContext context, CartItem cartItem) {
    return Card(
      // symmetric is used to have different margins for left, right, top and bottom
      // margin: EdgeInsets.symmetric(
      //   horizontal: 15,
      //   vertical: 4,
      // ),
      child: ListTile(
          dense:true,
        // leading: CircleAvatar(
        //   backgroundColor: Theme.of(context).highlightColor,
        //   child: Padding(
        //     padding: EdgeInsets.all(5),
        //     child: FittedBox(
        //       child: Text('\u20B9${cartItem.productPrice}'),
        //     ),
        //   ),
        // ),
        title: Text('${cartItem.productName} x ${cartItem.quantity}'),
        // subtitle: Text('Total: \u20B9${(cartItem.productPrice * cartItem.quantity)}'),
        trailing: Text('\u20B9${(cartItem.productPrice * cartItem.quantity)}'),
      ),
    );
  }
}