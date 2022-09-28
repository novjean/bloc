import 'package:bloc/widgets/manager/orders/order_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/cart_item.dart';
import '../../../db/entity/bloc_order.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/cart_item_utils.dart';
import '../../../widgets/ui/center_text_widget.dart';

class OrdersBilledScreen extends StatefulWidget {
  String serviceId;
  BlocDao dao;
  String titleHead;

  OrdersBilledScreen(
      {required this.serviceId, required this.dao, required this.titleHead});

  @override
  State<OrdersBilledScreen> createState() => _OrdersBilledScreenState();
}

class _OrdersBilledScreenState extends State<OrdersBilledScreen> {
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.titleHead + ' | Billed'),
        ),
        body: _isLoading
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
}
