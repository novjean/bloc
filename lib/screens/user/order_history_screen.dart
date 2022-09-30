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
  late List<CartItem?> billedCartItems;
  late List<BlocOrder> billedOrders;

  late List<CartItem?> completedCartItems;
  late List<BlocOrder> completedOrders;

  bool _isPastLoading = true;
  bool _isOngoingLoading = true;

  @override
  void initState() {
    final user = UserPreferences.getUser();

    FirestoreHelper.pullBilledCartItemsByUser(user.id, true, true)
        .then((res) {
      print("Successfully retrieved cart items by bloc");
      List<CartItem> _billedCartItems = [];

      if (res.docs.length == 0) {
        setState(() {
          billedCartItems = [];
          billedOrders = [];
          _isPastLoading = false;
        });
      }

      for (int i = 0; i < res.docs.length; i++) {
        DocumentSnapshot document = res.docs[i];
        Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
        final CartItem cartItem = CartItem.fromMap(map);
        _billedCartItems.add(cartItem);

        if (i == res.docs.length - 1) {
          setState(() {
            billedCartItems = _billedCartItems;
            billedOrders = CartItemUtils.extractOrdersByTime(_billedCartItems);
            _isPastLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders'),),
      body:  _buildBody(context)
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 5.0),
        buildSectionTitleRow('Ongoing Orders', context),
        SizedBox(height: 2.0),
        _isOngoingLoading ? Text('Loading ongoing orders...') : _displayBilledOrders(context),
        SizedBox(height: 2.0),
        buildSectionTitleRow('Past Orders', context),
        SizedBox(height: 2.0),
        _isPastLoading ? Text('Loading past orders...') : _displayBilledOrders(context),
        SizedBox(height: 2.0),
      ],
    );
  }

  buildSectionTitleRow(String category, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "$category",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          // FlatButton(
          //   child: Text(
          //     "See all",
          //     style: TextStyle(
          //       color: Theme.of(context).accentColor,
          //     ),
          //   ),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (BuildContext context) {
          //todo: need to navigate to show list of users or friends
          //           return Categories();
          //         },
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  _displayBilledOrders(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: billedOrders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            String title = 'Order ID: ' + billedOrders[index].createdAt.toString();

            String collapsed = '';
            String expanded = '';

            for(int i=0; i<billedOrders[index].cartItems.length; i++) {
              CartItem item = billedOrders[index].cartItems[i];

              if(i<2){
                collapsed += item.productName + ' x ' + item.quantity.toString() + '\n';
              }
              expanded += item.productName + ' x ' + item.quantity.toString() + '\n';

              if(i==billedOrders[index].cartItems.length-1){
                expanded += '\n\n' + 'Total : ' + billedOrders[index].total.toString();
              }
            }

            return OrderCard(title: title, collapsed: collapsed, expanded: expanded, imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/34/LaceUp-Invoicing-851_%C3%97_360.jpg');
          }),
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