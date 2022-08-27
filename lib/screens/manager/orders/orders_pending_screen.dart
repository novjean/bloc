import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/bloc_repository.dart';
import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/bill.dart';
import '../../../db/entity/cart_item.dart';
import '../../../db/entity/bloc_order.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/cart_item_utils.dart';
import '../../../widgets/manager/orders/order_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';
import '../bill_screen.dart';

class OrdersPendingScreen extends StatefulWidget {
  String serviceId;
  BlocDao dao;
  String titleHead;

  OrdersPendingScreen(
      {required this.serviceId,
      required this.dao,
      required this.titleHead});

  @override
  State<OrdersPendingScreen> createState() => _OrdersPendingScreenState();
}

class _OrdersPendingScreenState extends State<OrdersPendingScreen> {
  String _optionName = 'Table';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleHead + ' | Pending'),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 2.0),
        _displayOptions(context),
        const Divider(),
        SizedBox(height: 2.0),
        _pullCartItems(context),
        SizedBox(height: 5.0),
      ],
    );
  }

  _pullCartItems(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCartItemsSnapshot(widget.serviceId, false),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null) {
            return _displayOrdersList(context);
          }

          if (snapshot.data!.docs.isNotEmpty) {
            List<CartItem> cartItems = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              final CartItem ci = CartItem.fromMap(data);
              BlocRepository.insertCartItem(widget.dao, ci);
              cartItems.add(ci);

              if (i == snapshot.data!.docs.length - 1) {
                return _displayOrdersList(context);
              }
            }
          } else {
            return Expanded(
                child: Center(child: Text('No orders to display!')));
          }

          return Expanded(child: Center(child: Text('Loading cart items...')));
        });
  }

  _displayOrdersList(BuildContext context) {
    return FutureBuilder(
      future: BlocRepository.getPendingCartItemsByTableNumber(
          widget.dao, widget.serviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
              child: Center(child: Text('Loading orders by table number...')));
        } else {
          if (snapshot.data == null)
            return Expanded(child: Center(child: Text('No pending orders.')));
          List<CartItem> cartItems = snapshot.data! as List<CartItem>;
          if (cartItems.length > 0) {
            List<BlocOrder> orders = _optionName == 'Table'
                ? CartItemUtils.extractOrdersByTableNumber(cartItems)
                : CartItemUtils.extractOrdersByUserId(cartItems);
            return _displayOrdersListByType(context, orders);
          } else {
            return Expanded(
              child: Center(child: Text('No pending orders')),
            );
          }
        }
      },
    );
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
                  logger.d('Order selected for cust id : ' +
                      order.customerId +
                      ", table num: " +
                      order.tableNumber.toString());

                  Bill bill = CartItemUtils.extractBill(order.cartItems);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => BillScreen(bill: bill, isPending: true,)),
                  );
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
                    // _sCategory = categories[index];
                    _optionName = _options[index];
                    print(_optionName + ' order display option is selected.');
                  });
                  // displayProductsList(context, categories[index].id);
                });
          }),
    );
  }

}