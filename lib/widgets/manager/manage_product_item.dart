import 'package:bloc/screens/forms/edit_product_screen.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../db/dao/bloc_dao.dart';
import '../../db/entity/product.dart';
import '../../providers/cart.dart';
import '../../screens/product_detail_screen.dart';

class ManageProductItem extends StatelessWidget {
  final Product product;
  final BlocDao dao;
  final String serviceId;

  ManageProductItem({required this.serviceId, required this.product, required this.dao});

  @override
  Widget build(BuildContext context) {
    var logger = Logger();
    final cart = Provider.of<Cart>(context, listen: false);

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
                        Text('\u20B9 ${product.price}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            // IconButton(
                            //   icon: Icon(Icons.remove),
                            //   onPressed: () {
                            //     logger.i('remove product from cart.');
                            //   },
                            // ),
                            Container(
                              color: primaryColor,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 12.0,
                              ),
                              child: TextButton(
                                child: Text(
                                  'Modify',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (ctx) => EditProductScreen(product: product)),
                                  );
                                  Toaster.shortToast(
                                      product.name + ' is clicked to be modified.');
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.local_drink_rounded),
                              color: primaryColor,
                              onPressed: () {
                                Toaster.shortToast(
                                    product.name + ' is clicked for offer.');
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
