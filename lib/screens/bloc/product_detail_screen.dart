import 'package:flutter/material.dart';

import '../../db/entity/product.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  Product product;

  ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text(product.category.toLowerCase() +
            ' | ' +
            product.name.toLowerCase()),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 0.0),
          product.imageUrl.isNotEmpty
              ? Container(
                  width: double.infinity,
                  child: Hero(
                    tag: product.id,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: Text(product.description.toLowerCase(),
                textAlign: TextAlign.start,
                softWrap: true,
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 20,
                )),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
