import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/bloc_order.dart';
import '../../../db/entity/cart_item.dart';
import '../../../utils/date_time_utils.dart';
import '../../cart_block.dart';
import 'order_cart_item.dart';

class OrderCard extends StatelessWidget {
  BlocOrder blocOrder;

  OrderCard({required this.blocOrder});

  @override
  Widget build(BuildContext context) {
    String title = 'order #' + blocOrder.createdAt.toString();
    String collapsed = '';

    for (int i = 0; i < blocOrder.cartItems.length; i++) {
      CartItem item = blocOrder.cartItems[i];

      if (i >= 1) {
        collapsed += ", ";
      }

      if (i < 5) {
        collapsed += item.productName.toLowerCase();
      }
    }

    return ExpandableNotifier(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ScrollOnExpand(
                child: ExpandablePanel(
                  // controller: controller,
                  theme: ExpandableThemeData(
                    expandIcon: Icons.arrow_downward,
                    collapseIcon: Icons.arrow_upward,
                    tapBodyToCollapse: true,
                    tapBodyToExpand: true,
                  ),
                  header: Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              DateTimeUtils.getFormattedDateYear(
                                  blocOrder.createdAt),
                              style: const TextStyle(fontSize: 14),
                            )),
                      ],
                    ),
                  ),
                  collapsed: Padding(
                    padding: const EdgeInsets.only(
                        top: 5.0, left: 10, bottom: 5, right: 10),
                    child: Text(
                      collapsed,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  expanded: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      displayCartItems(context, blocOrder.cartItems),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            ButtonWidget(
                              text: '\u20B9 ${blocOrder.total}',
                              onClicked: () {},
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  builder: (_, collapsed, expanded) => Expandable(
                    collapsed: collapsed,
                    expanded: expanded,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  displayCartItems(BuildContext context, List<CartItem> cartItems) {
    double height = 20 * cartItems.length.roundToDouble();
    return SizedBox(
      height: height,
      child: ListView.builder(
        itemCount: cartItems.length,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: OrderCartItem(cartItem: cartItems[index]),
            onTap: () {
              CartItem _sCartItem = cartItems[index];
              print(_sCartItem.createdAt.toString() + ' is selected.');
            },
          );
        },
      ),
    );
  }
}
