import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/cart_item.dart';

class CartBlock extends StatelessWidget {
  CartItem cartItem;
  BlocDao dao;

  CartBlock({required this.cartItem, required this.dao});

  @override
  Widget build(BuildContext context) {
    return Text('Loading cart item...');
  }

}