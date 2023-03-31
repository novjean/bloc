import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bill.dart';
import '../../db/entity/bloc_order.dart';
import '../../db/entity/cart_item.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../utils/cart_item_utils.dart';
import '../../widgets/manager/orders/order_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late List<CartItem?> billedCartItems;
  late List<BlocOrder> billedOrders;

  late List<Bill> billedBills;

  late List<CartItem?> completedCartItems;
  late List<BlocOrder> completedOrders;

  bool _isPastLoading = true;
  bool _isOngoingLoading = true;

  @override
  void initState() {
    final user = UserPreferences.getUser();

    FirestoreHelper.pullCompletedCartItemsByUser(user.id, true).then((res) {
      print("successfully retrieved cart items by bloc");
      List<CartItem> _billedCartItems = [];
      List<CartItem> _completedCartItems = [];

      if (res.docs.length == 0) {
        setState(() {
          billedCartItems = [];
          billedOrders = [];

          completedCartItems = [];
          completedOrders = [];

          _isPastLoading = false;
          _isOngoingLoading = false;
        });
      }

      for (int i = 0; i < res.docs.length; i++) {
        DocumentSnapshot document = res.docs[i];
        Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
        final CartItem cartItem = CartItem.fromMap(map);

        if (cartItem.isBilled)
          _billedCartItems.add(cartItem);
        else
          _completedCartItems.add(cartItem);

        if (i == res.docs.length - 1) {
          setState(() {
            if (_billedCartItems.isNotEmpty) {
              billedCartItems = _billedCartItems;
              billedOrders = CartItemUtils.extractOrdersByTime(_billedCartItems);

              billedBills = CartItemUtils.extractBills(_billedCartItems);

            } else {
              billedCartItems = [];
              billedOrders = [];
            }

            if (_completedCartItems.isNotEmpty) {
              completedCartItems = _completedCartItems;
              completedOrders = CartItemUtils.createOngoingOrdersBill(_completedCartItems);
              // completedOrders = CartItemUtils.extractOrdersByTime(_completedCartItems);
            } else {
              completedCartItems = [];
              completedOrders = [];
            }

            _isPastLoading = false;
            _isOngoingLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('bloc | orders'),
        ),
        body: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        // SizedBox(height: 5.0),
        // buildSectionTitleRow('ongoing orders', context),
        // SizedBox(height: 2.0),
        // _isOngoingLoading
        //     ? Text('loading ongoing orders...')
        //     : completedOrders.isNotEmpty
        //         ? _displayOngoingOrder(context)
        //         : Text('no current orders!'),
        // SizedBox(height: 2.0),
        // buildSectionTitleRow('Past Orders', context),
        const SizedBox(height: 5.0),
        _isPastLoading
            ? const LoadingWidget()
            : billedOrders.isNotEmpty
                ? _displayBilledOrders(context)
                : const Expanded(child: Center(child: Text('no past orders'))),
        const SizedBox(height: 5.0),
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
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  _displayOngoingOrder(BuildContext context) {
    BlocOrder order = completedOrders[0];
    return OrderCard(blocOrder: order);
  }
  
  _displayBilledOrders(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: billedOrders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {

            return OrderCard(blocOrder: billedOrders[index]);
          }),
    );
  }
}
