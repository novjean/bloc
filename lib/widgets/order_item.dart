import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/cart_item.dart';
import 'package:bloc/db/entity/user.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/entity/order.dart';
import '../utils/user_utils.dart';

class OrderItem extends StatelessWidget {
  Order order;
  BlocDao dao;

  OrderItem({required this.order, required this.dao});

  @override
  Widget build(BuildContext context) {
    int cartItemsLength = order.cartItems.length;

    return testItem(context, cartItemsLength);

    // return workingItem(context, cartItemsLength);
  }

  Widget CartItemList(BuildContext context, CartItem cartItem) {
    return Card(
      // symmetric is used to have different margins for left, right, top and bottom
      // margin: EdgeInsets.symmetric(
      //   horizontal: 15,
      //   vertical: 4,
      // ),
      child: ListTile(
          dense:true,
        title: Text('${cartItem.productName} x ${cartItem.quantity}'),
        // subtitle: Text('Total: \u20B9${(cartItem.productPrice * cartItem.quantity)}'),
        trailing: Text('\u20B9${(cartItem.productPrice * cartItem.quantity)}'),
      ),
    );
  }

  Widget workingItem(BuildContext context, int cartItemsLength) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Customer name / Invoice'),
                Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          // Add one stop for each color. Stops should increase from 0 to 1
                          stops: [0.2, 0.7],
                          colors: [
                            Color.fromARGB(100, 0, 0, 0),
                            Color.fromARGB(100, 0, 0, 0),
                          ],
                          // stops: [0.0, 0.1],
                        ),
                      ),
                      height: (MediaQuery.of(context).size.height / 15) * cartItemsLength,
                      width: MediaQuery.of(context).size.height / 1,
                    ),
                    Container(
                        height: (MediaQuery.of(context).size.height / 15) * cartItemsLength,
                        width: MediaQuery.of(context).size.height / 1,
                        padding: const EdgeInsets.all(0),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemExtent: 50,
                            itemCount: order.cartItems == null ? 0 : order.cartItems.length,
                            itemBuilder: (BuildContext ctx, int index){
                              CartItem ci = order.cartItems[index];
                              return CartItemList(context, ci);
                            })
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget testItem(BuildContext context, int cartItemsLength) {
    final Stream<QuerySnapshot> _userStream = FirestoreHelper.getUserSnapshot(order.customerId);


    return Container(
      height: (MediaQuery.of(context).size.height / 8) * cartItemsLength,

      child: StreamBuilder<QuerySnapshot>(
        stream: _userStream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // return ListView.builder(itemBuilder: (BuildContext ctx, int index) {

          // });

          return GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              final User user  = UserUtils.getUser(data, document.id);
              BlocRepository.insertUser(dao, user);

              return billBlock(context,user, cartItemsLength);

              // return BlocServiceItem(service, true, dao, key: ValueKey(document.id));
              return Text('Loading users...');
            }).toList(),
          );
        },
      ),
    );

    // return Container(
    //   height: MediaQuery.of(context).size.height,
    //   padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
    //   child:
    // );

  }

  Widget billBlock(BuildContext context, User user, int cartItemsLength) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),

      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user.name),
                        Stack(
                          children: <Widget>[
                            Container(
                                height: (MediaQuery.of(context).size.height / 16) * cartItemsLength,
                                width: MediaQuery.of(context).size.height / 1,
                                padding: const EdgeInsets.all(0),
                                constraints: BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemExtent: 50,
                                    itemCount: order.cartItems == null ? 0 : order.cartItems.length,
                                    itemBuilder: (BuildContext ctx, int index){
                                      CartItem ci = order.cartItems[index];
                                      return CartItemList(context, ci);
                                    })
                            ),
                          ],
                        ),
                        Text('Order Total : ' + order.total.toString()),
                        // BillTotal(context),
                      ],
                    ),
                  )
                ),


                SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget BillTotal(BuildContext context) {
    return Text('total displayed here');
  }



}