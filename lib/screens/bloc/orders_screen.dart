import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/quick_order.dart';
import '../../helpers/fresh.dart';
import '../../utils/date_time_utils.dart';
import '../../widgets/quick_order_item.dart';
import '../../widgets/ui/app_bar_title.dart';

class OrdersScreen extends StatefulWidget {
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const String _TAG = 'OrdersScreen';

  List<QuickOrder> mQuickOrders = [];
  var _isOrdersLoading = true;


  @override
  void initState() {

    FirestoreHelper.pullQuickOrders(UserPreferences.myUser.id).then((res) {
      int now = Timestamp.now().millisecondsSinceEpoch;

      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final QuickOrder quickOrder = Fresh.freshQuickOrderMap(data, false);

          if(now - quickOrder.createdAt < DateTimeUtils.millisecondsDay){
            FirestoreHelper.deleteQuickOrder(quickOrder.id);
          } else {
            mQuickOrders.add(quickOrder);
          }
        }
        setState(() {
          _isOrdersLoading = false;
        });
      } else {
        //no orders
        setState(() {
          _isOrdersLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: 'orders'),
        titleSpacing: 0,
      ),
      body: _isOrdersLoading ? const LoadingWidget():_buildBody(context)
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        mQuickOrders.isNotEmpty?_showOrders(context): const Center(child: Text('no orders placed yet! 😲'),),
        const SizedBox(height: 10.0),
      ],
    );
  }

  _showOrders(BuildContext context) {
    return Expanded(
      child: ListView.builder(itemCount: mQuickOrders.length, scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index){
        QuickOrder quickOrder = mQuickOrders[index];
        return QuickOrderItem(quickOrder: quickOrder,);
          }),
    );
  }
}