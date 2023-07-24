import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../db/entity/product.dart';
import '../db/entity/quick_order.dart';
import '../helpers/dummy.dart';

class QuickOrderItem extends StatefulWidget{
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
      if(res.docs.isNotEmpty){
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
    return _isProductLoading ? const SizedBox():

    Container(
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
                      fit: BoxFit.cover
                  ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              child: Text('x${widget.quickOrder.quantity}')
                            ),
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
                          ): const SizedBox()
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(mProduct.description.toLowerCase(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark)),

                      // widget.isCustomerSeated
                      //     ? showAddMinusButtons(cart)
                      //     : const SizedBox(),

                      Padding(
                        padding: const EdgeInsets.only(top:5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Ink(
                              decoration: ShapeDecoration(
                                color: Theme.of(context).primaryColorLight,
                                shape: const CircleBorder(
                                ),
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
                                          widget.quickOrder = widget.quickOrder.copyWith(quantity: quantity);
                                        });
                                    }
                                  });
                                },
                              ),
                            ),
                            Container(
                              // color: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 10),
                              child: Text(
                                widget.quickOrder.quantity.toString(),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Ink(
                                decoration: ShapeDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  shape: const CircleBorder(),
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
                                      widget.quickOrder = widget.quickOrder.copyWith(quantity: quantity);
                                    });
                                  },
                                ),
                              ),
                            ),
                            // DarkButtonWidget(
                            //   text: 'order',
                            //   onClicked: () {
                            //     handleOrderClicked(context, quantity);
                            //
                            //     setState(() {
                            //       quantity = 1;
                            //     });
                            //   },
                            // ),
                          ],
                        ),
                      ),

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




    // Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 5.0),
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(15),
    //     child: Hero(
    //       tag: widget.quickOrder.id,
    //       child: Card(
    //         elevation: 1,
    //         color: Constants.lightPrimary,
    //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //         child: Padding(
    //             padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
    //             child: ListTile(
    //               leading: mProduct.imageUrl.isNotEmpty? FadeInImage(
    //                 placeholder: const AssetImage(
    //                     'assets/icons/logo.png'),
    //                 image: NetworkImage(mProduct.imageUrl),
    //                 fit: BoxFit.cover,): const SizedBox(),
    //               title: RichText(
    //                 text: TextSpan(
    //                   text: '${mProduct.name} x ${widget.quickOrder.quantity} ',
    //                   style: const TextStyle(
    //                       fontFamily: Constants.fontDefault,
    //                       color: Colors.black,
    //                       overflow: TextOverflow.ellipsis,
    //                       fontSize: 18,
    //                       fontWeight: FontWeight.bold),
    //                 ),
    //               ),
    //
    //               subtitle: Text(widget.quickOrder.isAccepted? 'order has been confirmed!': 'order is placed successfully!') ,
    //               trailing: Padding(
    //                 padding: const EdgeInsets.only(top:5.0),
    //                 child: SizedBox(
    //                   width: 150,
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.end,
    //                     children: [
    //                       Ink(
    //                         decoration: ShapeDecoration(
    //                           color: Theme.of(context).primaryColorLight,
    //                           shape: const CircleBorder(
    //                           ),
    //                         ),
    //                         child: IconButton(
    //                           icon: const Icon(Icons.remove),
    //                           splashRadius: 10.0,
    //                           color: Colors.black,
    //                           onPressed: () {
    //                             setState(() {
    //
    //                               if (widget.quickOrder.quantity > 1) {
    //                                 int quantity = widget.quickOrder.quantity;
    //                                 quantity--;
    //                                 widget.quickOrder = widget.quickOrder.copyWith(quantity: quantity);
    //                               }
    //                             });
    //                           },
    //                         ),
    //                       ),
    //                       Container(
    //                         // color: primaryColor,
    //                         padding: const EdgeInsets.symmetric(
    //                             vertical: 2.0, horizontal: 10),
    //                         child: Text(
    //                           widget.quickOrder.quantity.toString(),
    //                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    //                         ),
    //                       ),
    //                       Padding(
    //                         padding: const EdgeInsets.only(right: 10.0),
    //                         child: Ink(
    //                           decoration: ShapeDecoration(
    //                             color: Theme.of(context).primaryColorLight,
    //                             shape: const CircleBorder(),
    //                           ),
    //                           child: IconButton(
    //                             icon: const Icon(Icons.add),
    //                             splashRadius: 10.0,
    //                             color: Colors.black87,
    //                             onPressed: () {
    //                               setState(() {
    //                                 int quantity = widget.quickOrder.quantity;
    //                                 quantity++;
    //                                 widget.quickOrder = widget.quickOrder.copyWith(quantity: quantity);
    //                               });
    //                             },
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //
    //
    //               // leadingAndTrailingTextStyle: TextStyle(
    //               //     color: Colors.black, fontFamily: 'BalsamiqSans_Regular'),
    //               // trailing: Text(time, style: TextStyle(fontSize: 10),),
    //             )),
    //       ),
    //     ),
    //   ),
    // );
  }

}