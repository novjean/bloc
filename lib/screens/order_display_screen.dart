import 'package:bloc/widgets/cart_block_item.dart';
import 'package:flutter/material.dart';

import '../db/entity/cart_item.dart';
import '../db/entity/order.dart';

class OrderDisplayScreen extends StatelessWidget {
  Order order;

  OrderDisplayScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order number here'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView.builder(
      itemCount: order.cartItems.length,
        itemBuilder: (ctx, i) {
          CartItem cartItem = order.cartItems[i];
          return CartBlockItem(cartItem);
    });
  }
  
}