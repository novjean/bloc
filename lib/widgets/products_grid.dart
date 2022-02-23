
import 'package:bloc/widgets/product_item.dart';
import 'package:flutter/material.dart';

import '../db/entity/product.dart';

class ProductsGrid extends StatelessWidget{
  final List<Product> products;

  ProductsGrid(this.products);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // const keyword can be used so that it does not rebuild when the build method is called
      // useful for performance improvement
      padding: const EdgeInsets.all(10.0),
      scrollDirection: Axis.vertical,
      itemCount: products.length,
      physics: NeverScrollableScrollPhysics(),
      // grid delegate describes how many grids should be there
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      // item builder defines how the grid should look
      itemBuilder: (ctx, i) {
        Product product = products[i];
        return ProductItem(product:product);
      },
    );
  }

}