import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/bloc_order.dart';
import '../../db/entity/bill.dart';
import '../../db/entity/cart_item.dart';
import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../screens/manager/bill_screen.dart';
import '../../utils/cart_item_utils.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logx.dart';

class CaptainOrderItem extends StatefulWidget {
  final BlocOrder order;
  final String displayOption;
  final bool completed;
  final bool billed;

  CaptainOrderItem(
      {required this.order,
      required this.displayOption,
      required this.completed,
      required this.billed});

  @override
  State<CaptainOrderItem> createState() => _CaptainOrderItemState();
}

class _CaptainOrderItemState extends State<CaptainOrderItem> {
  static final String _TAG = 'CaptainOrderItem';

  bool isCustomerLoading = true;
  User mUser = Dummy.getDummyUser();

  @override
  void initState() {
    FirestoreHelper.pullUser(widget.order.customerId).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

        final User user = Fresh.freshUserMap(data, false);

        setState(() {
          mUser = user;
          isCustomerLoading = false;
        });
      } else {
        setState(() {
          isCustomerLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = 'order #${widget.order.createdAt}';
    String collapsed = '';

    for (int i = 0; i < widget.order.cartItems.length; i++) {
      CartItem item = widget.order.cartItems[i];

      if (i >= 1) {
        collapsed += ", ";
      }

      if (i < 5) {
        collapsed += item.productName.toLowerCase();
      }
    }

    return isCustomerLoading
        ? const Center(
            child: Text('loading customer details'),
          )
        : Container(
            margin: const EdgeInsets.only(bottom: 1.0),
            child: GestureDetector(
              onTap: () {
                BlocOrder order = widget.order;
                Logx.d(_TAG, 'order selected for cust id : ${order.customerId}, table num: ${order.tableNumber}');

                Bill bill = CartItemUtils.extractBill(order.cartItems);
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (ctx) => BillScreen(
                            bill: bill,
                            isPending: widget.completed ? false : true,
                          )),
                );
              },
              child: Hero(
                tag: StringUtils.getRandomString(28),
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        child: Center(
                            child: Text(
                          widget.order.tableNumber.toString(),
                          style: TextStyle(fontSize: 22),
                        )),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 1, bottom: 1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        mUser.name.toLowerCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      flex: 4,
                                    ),
                                    Flexible(
                                      child: Text(widget.order.total.toString(),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      flex: 1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(DateTimeUtils.getFormattedDateYear(
                                  widget.order.createdAt)),
                              SizedBox(height: 10),
                              Text(collapsed),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
