import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc_service.dart';
import '../db/entity/cart_item.dart';
import '../db/entity/order.dart';
import '../helpers/firestore_helper.dart';
import '../utils/cart_item_utils.dart';
import '../widgets/order_item.dart';

class ManagerBlocServiceScreen extends StatelessWidget {
  BlocDao dao;
  BlocService service;

  ManagerBlocServiceScreen({key, required this.dao, required this.service})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildOrders(context),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  _buildOrders(BuildContext context) {
    final Stream<QuerySnapshot> _cartStream = FirestoreHelper.getCartItemsSnapshot(service.id);

    return StreamBuilder<QuerySnapshot>(
      stream: _cartStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List<CartItem> cartItems = [];
        String custId ="";

        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot document = snapshot.data!.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final CartItem ci = CartItemUtils.getCartItem(data, document.id);
          BlocRepository.insertCartItem(dao, ci);
          cartItems.add(ci);
          custId = ci.userId;

          if (i == snapshot.data!.docs.length - 1) {
            return displayOrdersList(context, custId);
          }
        }

        return Text('Loading cart items...');
      },
    );
  }

  displayOrdersList(BuildContext context, String custId) {
    Future<List<CartItem>> fCartItems = BlocRepository.getSortedCartItems(dao,service.id);

    return FutureBuilder(
      future: fCartItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        } else {
          List<CartItem> cartItems = snapshot.data! as List<CartItem>;
          List<Order> orders = CartItemUtils.extractOrders(cartItems);

          return ListView.builder(
            primary: false,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: orders == null ? 0 : orders.length,
            itemBuilder: (BuildContext ctx, int index) {
              Order order = orders[index];

              return OrderItem(
                order : order
                // product: product,
                // dao: widget.dao,
              );
            },
          );
        }
        // return ListView.builder(itemBuilder: itemBuilder)
      },
    );
  }

}