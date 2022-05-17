import 'package:bloc/db/entity/manager_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/cart_item.dart';
import '../db/entity/order.dart';
import '../db/entity/user.dart';
import '../helpers/firestore_helper.dart';
import '../utils/cart_item_utils.dart';
import '../widgets/order_line_item.dart';
import 'order_display_screen.dart';

class OrdersScreen extends StatelessWidget {
  String serviceId;
  BlocDao dao;
  ManagerService managerService;

  OrdersScreen(
      {required this.serviceId,
      required this.dao,
      required this.managerService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(managerService.name),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.shopping_cart,
        //     ),
        //     onPressed: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //             builder: (ctx) =>
        //                 CartScreen(service: widget.service, dao: widget.dao)),
        //       );
        //     },
        //   ),
        // ],
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
          _buildOrders(context),
          SizedBox(height: 5.0),
          // buildProducts(context),
          // SizedBox(height: 50.0),
        ],
      ),
    );
  }

  _buildOrders(BuildContext context) {
    final Stream<QuerySnapshot> _stream =
        FirestoreHelper.getCartItemsSnapshot(serviceId);

    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<CartItem> cartItems = [];
          String custId = "";

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final CartItem ci = CartItem.fromJson(data);
            BlocRepository.insertCartItem(dao, ci);
            cartItems.add(ci);
            custId = ci.userId;

            if (i == snapshot.data!.docs.length - 1) {
              return displayOrdersList(context);
            }
          }
          return Text('Loading cart items...');
        });
  }

  displayOrdersList(BuildContext context) {
    Future<List<CartItem>> fCartItems =
        BlocRepository.getSortedCartItems(dao, serviceId);

    return FutureBuilder(
      future: fCartItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading orders...');
        } else {
          List<CartItem> cartItems = snapshot.data! as List<CartItem>;
          List<Order> orders = CartItemUtils.extractOrders(cartItems);
          return _displayOrderList(context, orders);
        }
      },
    );
  }

  loadUser(BuildContext context, Order order) {
    final Stream<QuerySnapshot> _stream =
        FirestoreHelper.getUserSnapshot(order.customerId);
    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final User user = User.fromJson(data);

            // BlocRepository.insertManagerService(dao, ms);

            if (i == snapshot.data!.docs.length - 1) {
              return GestureDetector(
                child: OrderLineItem(user: user, order: order),
                onTap: () => {
                  // Toaster.shortToast(
                  //     "Order index : " + index.toString()),
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => OrderDisplayScreen(order: order)),
                  ),
                },
              );
            }
          }

          return Text('loading users...');
        });
  }

  Widget _displayOrderList(BuildContext context, List<Order> orders) {
    return ListView.builder(
      primary: false,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: orders == null ? 0 : orders.length,
      itemBuilder: (BuildContext ctx, int index) {
        Order order = orders[index];

        return loadUser(context, order);

        //  return GestureDetector(
        //           child: OrderLineItem (
        //               order:order
        //           ),
        //           onTap: () => {
        //             Toaster.shortToast(
        //                 "Order index : " + index.toString()),
        //             Navigator.of(context).push(
        //               MaterialPageRoute(
        //                   builder: (ctx) =>
        //                       OrderDisplayScreen(order: order)),
        //             ),
        //           },
        //         );
      },
    );
  }
}
