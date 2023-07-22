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
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.quickOrder.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading: mProduct.imageUrl.isNotEmpty? FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(mProduct.imageUrl),
                    fit: BoxFit.cover,): const SizedBox(),
                  title: RichText(
                    text: TextSpan(
                      text: '${mProduct.name} x ${widget.quickOrder.quantity} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  subtitle: Text(widget.quickOrder.isAccepted? 'order has been confirmed!': 'order is placed successfully!') ,
                  trailing: Padding(
                    padding: const EdgeInsets.only(top:5.0),
                    child: SizedBox(
                      width: 150,
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
                              splashRadius: 10.0,
                              color: Colors.black,
                              onPressed: () {
                                setState(() {

                                  if (widget.quickOrder.quantity > 1) {
                                    int quantity = widget.quickOrder.quantity;
                                    quantity--;
                                    widget.quickOrder = widget.quickOrder.copyWith(quantity: quantity);
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
                                splashRadius: 10.0,
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
                        ],
                      ),
                    ),
                  ),


                  // leadingAndTrailingTextStyle: TextStyle(
                  //     color: Colors.black, fontFamily: 'BalsamiqSans_Regular'),
                  // trailing: Text(time, style: TextStyle(fontSize: 10),),
                )),
          ),
        ),
      ),
    );
  }

}