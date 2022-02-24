import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc_service.dart';

class CartScreen extends StatelessWidget {
  BlocService service;
  BlocDao dao;

  CartScreen({required this.service, required this.dao});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
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
                  // Chip(
                  //   label: Text(
                  //     '\$${cart.totalAmount.toStringAsFixed(2)}',
                  //     style: TextStyle(
                  //         color:
                  //         Theme.of(context).primaryTextTheme.headline6.color),
                  //   ),
                  //   backgroundColor: Theme.of(context).primaryColor,
                  // ),
                  // OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          // Expanded(
          //     child: ListView.builder(
          //       itemCount: cart.items.length,
          //       itemBuilder: (ctx, i) => CartItem(
          //         cart.items.values.toList()[i].id,
          //         cart.items.values.toList()[i].title,
          //         cart.items.values.toList()[i].price,
          //         cart.items.values.toList()[i].quantity,
          //         cart.items.keys.toList()[i],
          //       ),
          //     ))
        ],
      ),
    );
  }
}

