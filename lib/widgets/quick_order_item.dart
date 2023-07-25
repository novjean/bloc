import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../db/entity/product.dart';
import '../db/entity/quick_order.dart';
import '../helpers/dummy.dart';
import '../main.dart';

class QuickOrderItem extends StatefulWidget {
  QuickOrder quickOrder;

  QuickOrderItem({Key? key, required this.quickOrder}) : super(key: key);

  @override
  State<QuickOrderItem> createState() => _QuickOrderItemState();
}

class _QuickOrderItemState extends State<QuickOrderItem> {
  static const String _TAG = 'QuickOrderItem';

  Product mProduct = Dummy.getDummyProduct('', UserPreferences.myUser.id);
  var _isProductLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullProduct(widget.quickOrder.productId).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mProduct = Fresh.freshProductMap(data, false);

        setState(() {
          _isProductLoading = false;
        });
      } else {
        Logx.est(_TAG, 'product not found!');
        setState(() {
          _isProductLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isProductLoading
        ? const SizedBox()
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            margin: const EdgeInsets.only(bottom: 1.0),
            child: Hero(
              tag: widget.quickOrder.id,
              child: Card(
                color: Constants.lightPrimary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    mProduct.imageUrl.isNotEmpty
                        ? Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(mProduct.imageUrl),
                                  fit: BoxFit.cover),
                            ),
                          )
                        : const SizedBox(),
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
                                    flex: 4,
                                    child: Text(
                                      mProduct.name.toLowerCase(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                      flex: 1,
                                      child: Text(
                                          DateTimeUtils.getFormattedTime2(
                                              widget.quickOrder.createdAt))),
                                ],
                              ),
                            ),
                            // const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                mProduct.type == 'Food'
                                    ? Image.asset(
                                        mProduct.isVeg
                                            ? 'assets/icons/ic_veg_food.png'
                                            : 'assets/icons/ic_non_veg_food.png',
                                        width: 15,
                                        height: 15,
                                      )
                                    : const SizedBox()
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(mProduct.description.toLowerCase(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Constants.darkPrimary)),
                            !widget.quickOrder.isAccepted
                                ? _showAddMinusButton(context)
                                : const Text(
                                    'order is accepted and it shall reach you soon!',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Constants.darkPrimary)),

                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void _showOrderRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.lightPrimary,
          content: SizedBox(
            height: mq.height * 0.25,
            width: mq.width * 0.60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '👩‍🎤 cancel order of ${mProduct.name}?',
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                Text(
                  'Are you absolutely positive you want to part ways with this delicious delight? It\'s ready to party in your taste buds!'
                      .toLowerCase(),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("yes, cancel"),
              onPressed: () {
                FirestoreHelper.deleteQuickOrder(widget.quickOrder.id);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("💛 no, i'll have it"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showAddMinusButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Ink(
            decoration: const ShapeDecoration(
              color: Constants.lightPrimary,
              shape: CircleBorder(),
            ),
            child: IconButton(
              icon: const Icon(Icons.remove),
              splashRadius: 5.0,
              iconSize: 16,
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (widget.quickOrder.quantity > 1) {
                    setState(() {
                      int quantity = widget.quickOrder.quantity;
                      quantity--;
                      widget.quickOrder =
                          widget.quickOrder.copyWith(quantity: quantity);
                    });
                  } else {
                    _showOrderRemoveDialog(context);
                  }
                });
              },
            ),
          ),
          Container(
            // color: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10),
            child: Text(
              widget.quickOrder.quantity.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Ink(
              decoration: const ShapeDecoration(
                color: Constants.lightPrimary,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                splashRadius: 5.0,
                iconSize: 16,
                color: Colors.black87,
                onPressed: () {
                  setState(() {
                    int quantity = widget.quickOrder.quantity;
                    quantity++;
                    widget.quickOrder =
                        widget.quickOrder.copyWith(quantity: quantity);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
