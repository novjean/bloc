import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/quick_order.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/quick_order_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/sized_listview_block.dart';

class OrdersScreen extends StatefulWidget {
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const String _TAG = 'OrdersScreen';

  List<QuickOrder> mPendingOrders = [];
  List<QuickOrder> mCompletedOrders = [];

  late List<String> mOptions;
  String sOption = '';

  @override
  void initState() {
    mOptions = ['pending', 'completed'];
    sOption = mOptions.first;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.background,
        appBar: AppBar(
          title: AppBarTitle(title: 'orders'),
          titleSpacing: 0,
        ),
        body: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
            _showOrderOptions(context),
            _loadOrders(context),
        const SizedBox(height: 10.0),
      ],
    );
  }

  _showOrderOptions(BuildContext context) {
    double containerHeight = mq.height * 0.2;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 15,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: mq.width / 2,
                  color: Constants.primary,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                    Logx.i(_TAG, '$sOption at box office is selected');
                  });
                });
          }),
    );
  }

  _loadOrders(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getQuickOrders(UserPreferences.myUser.id),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          mPendingOrders = [];
          mCompletedOrders = [];

          if(snapshot.data!.docs.isNotEmpty){
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
              final QuickOrder quickOrder = Fresh.freshQuickOrderMap(map, false);

              if(quickOrder.status == 'ordered'){
                mPendingOrders.add(quickOrder);
              } else {
                mCompletedOrders.add(quickOrder);
              }

              if (i == snapshot.data!.docs.length - 1) {
                return _showOrders(context);
              }
            }
          } else {
          return const Center(
            child: Text('no orders placed yet! 😲',
            style: TextStyle(fontSize: 20, color: Constants.primary)),
            );
          }

          Logx.i(_TAG, 'loading orders...');
          return const LoadingWidget();
        });
  }

  _showOrders(BuildContext context) {
    List<QuickOrder> quickOrders = sOption == mOptions.first? mPendingOrders : mCompletedOrders;
    return Expanded(
      child: ListView.builder(
          itemCount: quickOrders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            QuickOrder quickOrder = quickOrders[index];
            return QuickOrderItem(
              quickOrder: quickOrder,
            );
          }),
    );
  }
}
