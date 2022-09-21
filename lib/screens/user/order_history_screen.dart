import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bill.dart';
import '../../db/entity/cart_item.dart';
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../utils/cart_item_utils.dart';

class OrderHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders'),),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 2.0),
        _pullUserCompletedCartItems(context),
        SizedBox(height: 5.0),
      ],
    );
  }

  _pullUserCompletedCartItems(BuildContext context){
    final User user = UserPreferences.getUser();

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getUserCartItems(user.id, true),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData) {
          List<CartItem> cartItems = [];

          if(snapshot.data!.docs.length==0){
            return Expanded(
                child: Center(child: Text('No past orders.')));
          }

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            final CartItem ci = CartItem.fromMap(data);
            cartItems.add(ci);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayOrdersList(context, cartItems);
            }
          }
        } else {
          return Expanded(
              child: Center(child: Text('No past orders.')));
        }
        return Expanded(child: Center(child: Text('Loading cart items...')));
      }
    );

  }

  _displayOrdersList(BuildContext context, List<CartItem> cartItems) {
    List<Bill> bills = CartItemUtils.extractBills(cartItems);
    // return Center(child: Text('Loaded cart items count : ' + cartItems.length.toString()),);

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min, children: bills.map<Widget>((bill) =>
            Flexible(
              child: Text('Bill : ' + bill.orders.length.toString()),
            )
        ).toList());
  }

}