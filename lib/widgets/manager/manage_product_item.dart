import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/screens/manager/inventory/add_product_offer_screen.dart';
import 'package:flutter/material.dart';

import '../../db/entity/product.dart';
import '../../helpers/fresh.dart';
import '../../screens/manager/inventory/product_add_edit_screen.dart';

class ManageProductItem extends StatelessWidget {
  final Product product;
  final String serviceId;

  ManageProductItem({Key? key, required this.serviceId, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 2.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => ProductAddEditScreen(
                      product: product,
                      task: 'edit',
                    )),
          );
        },
        child: Hero(
          tag: product.id,
          child: Card(
            child: Row(
              children: <Widget>[
                product.imageUrl.isNotEmpty
                    ? Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(product.imageUrl),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      )
                    : const SizedBox(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Text(product.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal)),
                              flex: 3,
                            ),
                            Flexible(
                              child: Text(
                                  '\u20B9 ${product.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal)),
                              flex: 1,
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                '\u20B9 ${product.priceLowest.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                            Text(' | '),
                            Text(
                                '\u20B9 ${product.priceHighest.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent)),
                            const Spacer(),
                            Text(
                                '\u20B9 ${product.priceBottle.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            const Text('available '),
                            Checkbox(
                              value: product.isAvailable,
                              onChanged: (value) {
                                Product updatedProduct =
                                    product.copyWith(isAvailable: value);
                                print('product ' +
                                    updatedProduct.name +
                                    ' available ' +
                                    value.toString());
                                Product freshProduct = Fresh.freshProduct(updatedProduct);
                                FirestoreHelper.pushProduct(freshProduct);
                              },
                            ),
                            // IconButton(
                            //   icon: const Icon(Icons.percent),
                            //   color: primaryColor,
                            //   onPressed: () {
                            //     print(product.name + ' is clicked for offer.');
                            //     Navigator.of(context).push(
                            //       MaterialPageRoute(
                            //           builder: (ctx) => AddProductOfferScreen(
                            //               product: product)),
                            //     );
                            //   },
                            // ),
                          ],
                        ),
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
