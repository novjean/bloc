import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc_service.dart';
import '../widgets/ui/cover_photo.dart';

class CartScreen extends StatelessWidget {
  BlocService service;
  BlocDao dao;

  CartScreen({key, required this.dao, required this.service})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: _buildBody(context, service)
    );
  }
}

Widget _buildBody(BuildContext context, BlocService service) {
  return SingleChildScrollView(
    child: Column(
      children: [
        CoverPhoto(service.name, service.imageUrl),
        SizedBox(height: 20.0),
        _invoiceDetailsItem(),
        SizedBox(height: 10),
        _orderConfirmItem(context),
      ],
    ),
  );
}

Widget _invoiceDetailsItem() {
  return Text('Loading invoice details...');
  // Expanded(
  //     child: ListView.builder(
  //       itemCount: cart.items.length,
  //       itemBuilder: (ctx, i) => CartItem(
  //         cart.items.values.toList()[i].id,
  //         cart.items.values.toList()[i].title,
  //         cart.items.values.toList()[i].price,
  //         cart.items.values.toList()[i].quantity,
  //         cart.items.keys.toList()[i],
  //       ),
  //     ))

}

Widget _orderConfirmItem(BuildContext context) {
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
          // Chip(
          //   label: Text(
          //     '\$${cart.totalAmount.toStringAsFixed(2)}',
          //     style: TextStyle(
          //         color:
          //         Theme.of(context).primaryTextTheme.headline6.color),
          //   ),
          //   backgroundColor: Theme.of(context).primaryColor,
          // ),
          // OrderButton(cart: cart),
        ],
      ),
    ),
  );
}

