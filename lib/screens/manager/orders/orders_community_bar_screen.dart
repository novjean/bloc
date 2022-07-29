import 'package:bloc/screens/manager/orders/community_offer_screen.dart';
import 'package:bloc/widgets/manager/orders/manage_running_community_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/bloc_repository.dart';
import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/cart_item.dart';
import '../../../helpers/firestore_helper.dart';

class OrdersCommunityBarScreen extends StatefulWidget {
  String serviceId;
  BlocDao dao;
  String titleHead;

  OrdersCommunityBarScreen(
      {required this.serviceId,
        required this.dao,
        required this.titleHead});

  @override
  State<OrdersCommunityBarScreen> createState() => _OrdersCommunityBarScreenState();
}

class _OrdersCommunityBarScreenState extends State<OrdersCommunityBarScreen> {
  // String _optionName = 'Table';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleHead + ' | Community'),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        // SizedBox(height: 2.0),
        // _displayDisplayOption(context),
        // SizedBox(height: 2.0),
        // const Divider(),
        SizedBox(height: 2.0),
        _pullCartItems(context),
        SizedBox(height: 5.0),
      ],
    );
  }

  _pullCartItems(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCartItemsCommunity(widget.serviceId, false),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null) {
            // return _displayOrdersList(context);
          }

          if (snapshot.data!.docs.isNotEmpty) {
            List<CartItem> cartItems = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              final CartItem ci = CartItem.fromMap(data);

              // check if item is already present in the
              if(!isCartItemPresent(cartItems, ci))
                cartItems.add(ci);

              if (i == snapshot.data!.docs.length - 1) {
                // return Text('Work in progress!');
                return _displayCommunityOrderItems(context, cartItems);
              }
            }
          } else {
            return Expanded(
                child: Center(child: Text('No orders to display!')));
          }

          return Expanded(child: Center(child: Text('Loading cart items...')));
        });
  }

  _displayCommunityOrderItems(BuildContext context, List<CartItem> cartItems) {
    return Expanded(
      child: ListView.builder(
          itemCount: cartItems.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageRunningCommunityItem(
                  cartItems[index],
                ),
                onTap: () {
                  CartItem _cartItem = cartItems[index];
                  logger.d('clicked cart item : ' + _cartItem.toString());

                  // Bill bill = CartItemUtils.extractBill(order.cartItems);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => CommunityOfferScreen(cartItem: _cartItem)),
                  );
                });
          }),
    );
  }

  bool isCartItemPresent(List<CartItem> cartItems, CartItem ci) {
    for(CartItem cartItem in cartItems){
      if(cartItem.productId == ci.productId){
        return true;
      }
    }
    return false;
  }

}
