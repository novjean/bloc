import 'package:bloc/screens/manager/inventory/add_product_offer_screen.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:flutter/material.dart';

import '../../db/entity/product.dart';
import '../../screens/bloc/product_detail_screen.dart';
import '../../screens/manager/inventory/product_add_edit_screen.dart';

class ManageProductItem extends StatelessWidget {
  final Product product;
  final String serviceId;

  ManageProductItem({required this.serviceId, required this.product});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => ProductDetailScreen(product: product)),
          );
        },
        child: Hero(
          tag: product.id,
          // 'detail_food$index',
          child: Card(
            child: Row(
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 9, right: 0, top: 0, bottom: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(product.name,
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            Text('\u20B9 ${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5),

                        Row(
                          children: [
                            Text(
                                '\u20B9 ${product.priceLowest.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                            Text(' | '),
                            Text(
                                '\u20B9 ${product.priceHighest.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent)),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            // IconButton(
                            //   icon: Icon(Icons.remove),
                            //   onPressed: () {
                            //     logger.i('remove product from cart.');
                            //   },
                            // ),
                            ButtonWidget(
                              text: 'Edit',
                              onClicked: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (ctx) =>
                                          ProductAddEditScreen(product: product, task: 'Edit',)),
                                );
                                print(product.name +
                                    ' is clicked to be modified.');
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.whatshot),
                              color: primaryColor,
                              onPressed: () {
                                print(product.name + ' is clicked for offer.');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (ctx) => AddProductOfferScreen(product: product)),
                                );
                              },
                            ),
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
