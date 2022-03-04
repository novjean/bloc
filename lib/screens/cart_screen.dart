import 'package:bloc/db/entity/cart_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc_service.dart';
import '../widgets/cart_block.dart';

class CartScreen extends StatelessWidget {
  BlocDao dao;
  BlocService service;

  CartScreen({key, required this.dao, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cart'),
        ),
        body: _buildBody(context, service, dao));
  }
}

Widget _buildBody(BuildContext context, BlocService service, BlocDao dao) {
  final user = FirebaseAuth.instance.currentUser;
  String userId = user!.uid;
  Future<List<CartItem>> fItems = BlocRepository.getCartItems(dao, userId);

  return FutureBuilder(
      future: fItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading cart items...');
        } else {
          List<CartItem> items = snapshot.data! as List<CartItem>;
          return SingleChildScrollView(
            child: Column(
              children: [
                // CoverPhoto(service.name, service.imageUrl),
                SizedBox(height: 20.0),
                _displayCartItems(dao, items),
                // _invoiceDetailsItem(dao),
                SizedBox(height: 10),
                _orderConfirmItem(context, items),
              ],
            ),
          );
        }
      });
}

Widget _displayCartItems(BlocDao dao, List<CartItem> items) {
  List<CartItem> billItems = _createBill(items);

  return ListView.builder(
    primary: false,
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
    itemCount: billItems == null ? 0 : billItems.length,
    itemBuilder: (BuildContext ctx, int index) {
      CartItem item = billItems[index];

      return CartBlock(
        cartItem: item,
        dao: dao,
      );
    },
  );
}

List<CartItem> _createBill(List<CartItem> items) {
  List<CartItem> bill=[];
  int j=0;
  for(int i = 0; i<items.length; i++){
    CartItem item = items[i];
    if(i==0){
      bill.insert(j, item);
      j++;
      continue;
    }
    // check if it is already present in bill
    int checkIndex = -1;
    checkIndex = getItemInBill(item.productId, bill);
    if(checkIndex == -1){
      // then item not present in bill
      bill.insert(j, item);
      j++;
    } else {
      // item is in bill
      CartItem billItem = bill[checkIndex];
      billItem.quantity++;
      bill[checkIndex] = billItem;
    }
  }
  return bill;
}

int getItemInBill(String productId, List<CartItem> bill) {
  for(int i=0;i<bill.length;i++){
    CartItem item = bill[i];
    if(item.productId == productId){
      return i;
    }
  }
  return -1;
}

Widget _orderConfirmItem(BuildContext context, List<CartItem> items) {
  double _cartTotal = _calculateTotal(items);

  return Card(
    margin: EdgeInsets.all(15),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          // spacer is a special widget which takes up all the space it can
          Spacer(),
          Chip(
            label: Text(
              '\u20B9${_cartTotal.toStringAsFixed(2)}',
              style: TextStyle(
                  color:
                  Theme.of(context).cardColor),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          // OrderButton(cart: cart),
        ],
      ),
    ),
  );
}

double _calculateTotal(List<CartItem> items) {
  double total = 0;
  for(int i=0;i<items.length;i++){
    total += items[i].productPrice;
  }
  return total;
}
