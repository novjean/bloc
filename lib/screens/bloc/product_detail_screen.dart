import 'package:flutter/material.dart';

import '../../db/entity/product.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.category + ' | ' + product.name),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.0),
          Container(
            width:  double.infinity,
            child: Hero(
              tag: product.id,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            '\u20B9${product.price}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
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
            child: Text(product.description,
                textAlign: TextAlign.start,
                softWrap: true,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                )),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
