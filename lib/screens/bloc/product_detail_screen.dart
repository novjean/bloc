import 'package:flutter/material.dart';

import '../../db/entity/product.dart';
import '../../widgets/ui/app_bar_title.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  Product product;

  ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: product.name.toLowerCase(),),
        titleSpacing: 0,
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
