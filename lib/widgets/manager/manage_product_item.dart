import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../db/dao/bloc_dao.dart';
import '../../db/entity/product.dart';
import '../../screens/bloc/product_detail_screen.dart';
import '../../screens/manager/inventory/edit_product_screen.dart';

class ManageProductItem extends StatelessWidget {
  final Product product;
  final BlocDao dao;
  final String serviceId;

  ManageProductItem({required this.serviceId, required this.product, required this.dao});

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
                        image: NetworkImage(product.imageUrl), fit: BoxFit.cover
                      // AssetImage(food['image']),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(product.name),
                            // Icon(Icons.delete_outline)
                          ],
                        ),
                        Text('\u20B9 ${product.price.toStringAsFixed(2)}'),
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
                                  MaterialPageRoute(builder: (ctx) => EditProductScreen(product: product)),
                                );
                                print(product.name + ' is clicked to be modified.');
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.local_drink_rounded),
                              color: primaryColor,
                              onPressed: () {
                                print(product.name + ' is clicked for offer.');
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
