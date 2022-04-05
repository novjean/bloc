import 'package:bloc/widgets/cart_block_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/entity/cart_item.dart';
import '../db/entity/order.dart';
import '../db/entity/user.dart';
import '../helpers/firestore_helper.dart';
import '../utils/user_utils.dart';

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

  // loadUser(BuildContext context) {
  //   final Stream<QuerySnapshot> _stream = FirestoreHelper.getUserSnapshot(order.customerId);
  //   return StreamBuilder<QuerySnapshot>(stream: _stream,
  //       builder: (ctx, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         }
  //
  //         for (int i = 0; i < snapshot.data!.docs.length; i++) {
  //           DocumentSnapshot document = snapshot.data!.docs[i];
  //           Map<String, dynamic> data =
  //           document.data()! as Map<String, dynamic>;
  //           final User user  = UserUtils.getUser(data, document.id);
  //
  //           // BlocRepository.insertManagerService(dao, ms);
  //
  //           if (i == snapshot.data!.docs.length - 1) {
  //             return _buildBody(context);
  //           }
  //         }
  //
  //         return Text('loading users...');
  //       });
  // }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(child: buildCartItems(context)),
        SizedBox(height: 10.0),
        TotalBox(context),
      ],
    );
  }

  Widget buildCartItems(BuildContext context) {
    return ListView.builder(
        itemCount: order.cartItems.length,
        itemBuilder: (ctx, i) {
          CartItem cartItem = order.cartItems[i];
          return CartBlockItem(cartItem);
        });
  }

  Widget TotalBox(BuildContext context) {
    return Card(
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
            Chip(
              label: Text(
                '\u20B9${order.total.toStringAsFixed(2)}',
                style: TextStyle(
                    color: Theme.of(context)
                        .primaryTextTheme
                        .headline6!
                        .color),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            // OrderButton(cart: cart, dao: dao),
          ],
        ),
      ),
    );
  }
}



