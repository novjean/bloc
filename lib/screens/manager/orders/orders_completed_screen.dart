import 'package:bloc/db/entity/manager_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/bloc_repository.dart';
import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/bill.dart';
import '../../../db/entity/cart_item.dart';
import '../../../db/entity/order.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/cart_item_utils.dart';
import '../../../widgets/order_table_item.dart';
import '../bill_screen.dart';

class OrdersCompletedScreen extends StatelessWidget {
  String serviceId;
  BlocDao dao;
  ManagerService managerService;

  OrdersCompletedScreen(
      {required this.serviceId,
        required this.dao,
        required this.managerService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(managerService.name + ' | Completed'),
      ),
      body: _buildBody(context, managerService),
    );
  }

  _buildBody(BuildContext context, ManagerService service) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // CoverPhoto(service.name, service.imageUrl),
          SizedBox(height: 2.0),
          _pullCartItems(context),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }

  _pullCartItems(BuildContext context) {
    final Stream<QuerySnapshot> _stream = FirestoreHelper.getCartItemsSnapshot(serviceId, true);

    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null) {
            return _displayOrdersListByTableNumber(context);
            // return displayOrdersList(context);
          }

          if (snapshot.data!.docs.isNotEmpty) {
            List<CartItem> cartItems = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              final CartItem ci = CartItem.fromMap(data);
              BlocRepository.insertCartItem(dao, ci);
              cartItems.add(ci);

              if (i == snapshot.data!.docs.length - 1) {
                return _displayOrdersListByTableNumber(context);
              }
            }
          } else {
            return Expanded(child: Center(child: Text('No completed orders to display.')));
          }

          return Expanded(child: Center(child:Text('Loading cart items...')));
        });
  }

  _displayOrdersListByTableNumber(BuildContext context) {
    Future<List<CartItem>> fCartItems =
    BlocRepository.getCompletedCartItemsByTableNumber(dao, serviceId);

    return FutureBuilder(
      future: fCartItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(child: Center(child: Text('Loading orders by table number...'),));
        } else {
          List<CartItem> cartItems = snapshot.data! as List<CartItem>;
          if(cartItems.length > 0){
            // List<Order> orders = CartItemUtils.extractOrdersByUserId(cartItems);
            List<Order> orders = CartItemUtils.extractOrdersByTableNumber(cartItems);
            return _displayOrderTables(context, orders);
          } else {
            return Expanded(child: Center(child: Text('No completed orders.')),);
          }
        }
      },
    );
  }

  _displayOrderTables(BuildContext context, List<Order> orders) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: orders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: OrderTableItem(
                  order: orders[index],
                ),
                onTap: () {
                  Order order = orders[index];

                  Bill bill = CartItemUtils.extractBill(order.cartItems);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => BillScreen(bill: bill)),
                  );

                  logger.d('Order selected : ' + order.customerId);
                });
          }),
    );
  }
}
