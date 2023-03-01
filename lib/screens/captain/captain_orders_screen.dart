import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bill.dart';
import '../../db/entity/bloc_order.dart';
import '../../db/entity/cart_item.dart';
import '../../helpers/firestore_helper.dart';
import '../../utils/cart_item_utils.dart';
import '../../widgets/manager/orders/order_item.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../manager/bill_screen.dart';

class CaptainOrdersScreen extends StatefulWidget{
  String serviceId;

  CaptainOrdersScreen({required this.serviceId});

  @override
  State<CaptainOrdersScreen> createState() => _CaptainOrdersScreenState();
}

class _CaptainOrdersScreenState extends State<CaptainOrdersScreen> {
  List<String> mOptions = ['pending', 'completed', 'billed'];
  String sOption = 'pending';

  String _optionName = 'Table';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('captain | orders'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _displayOrderOptions(context),
        SizedBox(height: 2.0),
        _displayOptions(context),
        const Divider(),
        SizedBox(height: 5.0),
        _buildOrders(context),
        SizedBox(height: 5.0),
      ],
    );
  }

  _displayOrderOptions(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return Container(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 14,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 3,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                    print(sOption + ' order level is selected');
                  });
                });
          }),
    );
  }

  _displayOptions(BuildContext context) {
    List<String> _options = ['Table', 'Customer'];
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: containerHeight,
      child: ListView.builder(
          itemCount: _options.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: _options[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 2,
                ),
                onTap: () {
                  setState(() {
                    _optionName = _options[index];
                    print(_optionName + ' order display option is selected.');
                  });
                });
          }),
    );
  }

  _buildOrders(BuildContext context) {
    String serviceId = UserPreferences.myUser.blocServiceId;

    bool completed = false;
    bool billed = false;

    if(sOption == 'completed'){
      completed = true;
      billed = false;
    } else if(sOption == 'billed'){
      completed = true;
      billed = true;
    } else {
      completed = false;
      billed = false;
    }

    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCartItemsByCompleteBilled(
            serviceId, completed, billed),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              List<CartItem> cartItems = [];
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
                final CartItem ci = CartItem.fromMap(data);
                // BlocRepository.insertCartItem(widget.dao, ci);
                cartItems.add(ci);

                if (i == snapshot.data!.docs.length - 1) {
                  return _displayOrdersList(context, cartItems);
                }
              }
            } else {
              return Expanded(
                  child: Center(child: Text('no ' + sOption + ' orders to display')));
            }
          } else {
            return Expanded(
                child: Center(child: Text('no ' + sOption + ' orders to display')));
          }
          return Expanded(
              child: Center(child: Text('no ' + sOption + ' orders to display')));
        });

  }

  _displayOrdersList(BuildContext context, List<CartItem> cartItems) {
    if (cartItems.length > 0) {
      List<BlocOrder> orders = _optionName == 'Table'
          ? CartItemUtils.extractOrdersByTableNumber(cartItems)
          : CartItemUtils.extractOrdersByUserId(cartItems);
      return _displayOrdersListByType(context, orders);
    } else {
      return Expanded(child: Center(child: Text('No pending orders.')));
    }
  }

  _displayOrdersListByType(BuildContext context, List<BlocOrder> orders) {
    return Expanded(
      child: ListView.builder(
          itemCount: orders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: OrderItem(
                  order: orders[index],
                  displayOption: _optionName,
                ),
                onTap: () {
                  BlocOrder order = orders[index];
                  print('order selected for cust id : ' +
                      order.customerId +
                      ", table num: " +
                      order.tableNumber.toString());

                  Bill bill = CartItemUtils.extractBill(order.cartItems);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => BillScreen(
                          bill: bill,
                          isPending: true,
                        )),
                  );
                });
          }),
    );
  }

}

