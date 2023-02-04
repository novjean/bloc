import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/bloc_order.dart';
import '../../../db/entity/cart_item.dart';
import '../../../utils/date_time_utils.dart';

class OrderCard extends StatelessWidget {
  BlocOrder blocOrder;

  OrderCard({required this.blocOrder});

  @override
  Widget build(BuildContext context) {
    String title = 'order #' + blocOrder.createdAt.toString();
    String collapsed = '';
    String expanded = '';

    for (int i = 0; i < blocOrder.cartItems.length; i++) {
      CartItem item = blocOrder.cartItems[i];

      if (i < 2) {
        collapsed += item.productName.toLowerCase() + ' x ' + item.quantity.toString() + '\n';
      }
      expanded += item.productName.toLowerCase() + ' x ' + item.quantity.toString() + '\n';
    }

    return ExpandableNotifier(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // GestureDetector(
              //   onTap: () => controller.toggle(),
              //   child: Image.network(urlImage),
              // ),
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
                              DateTimeUtils.getFormattedDateYear(blocOrder.createdAt),
                              style: const TextStyle(fontSize: 14),
                            )),
                      ],
                    ),
                  ),
                  collapsed: Padding(
                    padding: const EdgeInsets.only(top:10.0),
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

                  expanded:

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              expanded,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          ButtonWidget(
                            text: '\u20B9 ${blocOrder.total}',
                            onClicked: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                  builder: (_, collapsed, expanded) => Padding(
                    padding: EdgeInsets.all(10).copyWith(top: 0),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
