import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/bill.dart';
import '../../../db/entity/cart_item.dart';
import '../../../db/entity/bloc_order.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/cart_item_utils.dart';
import '../../../utils/logx.dart';
import '../../../widgets/manager/orders/order_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';
import '../bill_screen.dart';

class OrdersCompletedScreen extends StatefulWidget {
  String serviceId;
  String titleHead;

  OrdersCompletedScreen(
      {required this.serviceId, required this.titleHead});

  @override
  State<OrdersCompletedScreen> createState() => _OrdersCompletedScreenState();
}

class _OrdersCompletedScreenState extends State<OrdersCompletedScreen> {
  static const String _TAG = 'OrdersCompletedScreen';

  String _optionName = 'Table';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleHead + ' | completed'),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 2.0),
        _displayDisplayOption(context),
        SizedBox(height: 2.0),
        const Divider(),
        SizedBox(height: 2.0),
        _pullCartItemsTest(context),
        SizedBox(height: 5.0),
      ],
    );
  }

  _pullCartItemsTest(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCartItemsByCompleteBilled(
            widget.serviceId, true, false),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingWidget();
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
                  child:
                      Center(child: Text('no completed orders to display.')));
            }
          } else {
            return Expanded(
                child: Center(child: Text('no completed orders to display.')));
          }

          return Expanded(
              child: Center(child: Text('loading completed cart items...')));
        });
  }

  _displayOrdersList(BuildContext context, List<CartItem> cartItems) {
    if (cartItems.length > 0) {
      List<BlocOrder> orders = _optionName == 'Table'
          ? CartItemUtils.extractOrdersByTableNumber(cartItems)
          : CartItemUtils.extractOrdersByUserId(cartItems);
      return _displayOrdersListByType(context, orders);
    } else {
      return Expanded(child: Center(child: Text('No completed orders.')));
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
                  Logx.i(_TAG, 'order selected for cust id : ' +
                      order.customerId +
                      ", table num: " +
                      order.tableNumber.toString());

                  Bill bill = CartItemUtils.extractBill(order.cartItems);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => BillScreen(
                              bill: bill,
                              isPending: false,
                            )),
                  );
                });
          }),
    );
  }

  _displayDisplayOption(BuildContext context) {
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
                  color: Theme.of(context).primaryColor,
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
}
