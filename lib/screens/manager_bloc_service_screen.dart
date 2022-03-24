import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc_service.dart';
import '../helpers/firestore_helper.dart';

class ManagerBlocServiceScreen extends StatelessWidget {
  BlocDao dao;
  BlocService service;

  ManagerBlocServiceScreen({key, required this.dao, required this.service})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildOrders(context),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  _buildOrders(BuildContext context) {
    final Stream<QuerySnapshot> _cartStream = FirestoreHelper.getCartItemsSnapshot(service.id);

    return StreamBuilder<QuerySnapshot>(
      stream: _cartStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Text('Loading cart items...');
      },
    );
  }

}