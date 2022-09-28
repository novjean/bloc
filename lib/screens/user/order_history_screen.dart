import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bill.dart';
import '../../db/entity/bloc_order.dart';
import '../../db/entity/cart_item.dart';
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../utils/cart_item_utils.dart';
import '../../widgets/manager/orders/order_card.dart';
import '../../widgets/ui/center_text_widget.dart';

class OrderHistoryScreen extends StatefulWidget {
  // todo: we should not be relying on service Id as the user can order from multiple blocs
  String serviceId;

  OrderHistoryScreen({required this.serviceId});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late List<CartItem?> cartItems;
  late List<BlocOrder> orders;
  bool _isLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullBilledCartItemsByBloc(widget.serviceId, true, true)
        .then((res) {
      print("Successfully retrieved cart items");
      List<CartItem> _cartItems = [];
      if (res.docs.length == 0) {
        setState(() {
          cartItems = [];
          orders = [];
          _isLoading = false;
        });
      }

      for (int i = 0; i < res.docs.length; i++) {
        DocumentSnapshot document = res.docs[i];
        Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
        final CartItem cartItem = CartItem.fromMap(map);
        _cartItems.add(cartItem);
        if (i == res.docs.length - 1) {
          setState(() {
            cartItems = _cartItems;
            orders = CartItemUtils.extractOrdersByTime(_cartItems);
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders'),),
      body:  _isLoading
          ? CenterTextWidget(text: 'Loading orders...')
          : ListView.builder(
          itemCount: orders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            String title = 'Order ID: ' + orders[index].createdAt.toString();

            String collapsed = '';
            String expanded = '';

            for(int i=0; i<orders[index].cartItems.length; i++) {
              CartItem item = orders[index].cartItems[i];

              if(i<2){
                collapsed += item.productName + ' x ' + item.quantity.toString() + '\n';
              }
              expanded += item.productName + ' x ' + item.quantity.toString() + '\n';

              if(i==orders[index].cartItems.length-1){
                expanded += '\n\n' + 'Total : ' + orders[index].total.toString();
              }
            }

            return OrderCard(title: title, collapsed: collapsed, expanded: expanded, imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/34/LaceUp-Invoicing-851_%C3%97_360.jpg');
          })
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