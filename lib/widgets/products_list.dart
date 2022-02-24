import 'package:bloc/widgets/product_item.dart';
import 'package:flutter/material.dart';

import '../db/entity/product.dart';

class ProductsList extends StatelessWidget{
  final List<Product> products;

  ProductsList(this.products);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.50 * products.length,
      width: size.width,
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: ListView.builder(
        primary: true,
        scrollDirection: Axis.vertical,
        shrinkWrap: false,
        itemCount: products.length,
        itemBuilder: (BuildContext ctx, int index)  {
          Product product = products[index];

          return ProductItem(
            product: product,
          );
        },
      ),
    );
  }

}