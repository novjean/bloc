import 'package:flutter/material.dart';

import '../../db/entity/product.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    // final productId = ModalRoute.of(context).settings.arguments as String;

    // lean widget by retrieving only the data we need
    // listen false will not listen to the notify listeners, use only when the data is going to be static such as product title
    // final loadedProduct =
    // Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        // slivers are scrollable areas on the screen
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            // pinned so that it stays on top
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product.name),
              background: Hero(
                tag: product.id,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Text(
                  '\$${product.price}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    product.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: 800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
