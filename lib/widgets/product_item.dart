import 'package:flutter/material.dart';

import '../db/entity/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProductDetailScreen(title)),);
            // Navigator.of(context).pushNamed(
            //   ProductDetailScreen.routeName,
            //   arguments: product.id,
            // );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          // leading is adding a widget at the beginning
          // leading: Consumer<Product>(
          //   builder: (ctx, product, child) => IconButton(
          //     icon: Icon(
          //       product.isFavorite ? Icons.favorite : Icons.favorite_border,
          //     ),
          //     onPressed: () {
          //       product.toggleFavoriteStatus(authData.token, authData.userId);
          //     },
          //     // so if we had something that is constant,
          //     // then point it to the child and it will not be reloaded
          //     // label: child,
          //     color: Theme.of(context).accentColor,
          //   ),
          //   child: Text('Never changes!'),
          // ),
          title: Text(
            product.name,
            textAlign: TextAlign.center,
          ),
          // trailing: IconButton(
          //   icon: Icon(Icons.shopping_cart),
          //   onPressed: () {
          //     cart.addItem(product.id, product.price, product.title);
          //
          //     // info popup
          //     // this captures the nearest widget that controls the page
          //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
          //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //       content: Text('Added item to cart!'),
          //       duration: Duration(seconds: 2),
          //       action: SnackBarAction(
          //         label: 'UNDO',
          //         onPressed: () {
          //           cart.removeSingleItem(product.id);
          //         },
          //       ),
          //     ));
          //     // Scaffold.of(context).openDrawer();
          //   },
          //   color: Theme.of(context).accentColor,
          // ),
        ),
      ),
    );

    // return Padding(
    //   padding: const EdgeInsets.only(right: 10.0),
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(8.0),
    //     child: Stack(
    //       children: <Widget>[
    //         FadeInImage(
    //           placeholder: AssetImage('assets/images/product-placeholder.png'),
    //           height: MediaQuery.of(context).size.height / 4,
    //           width: MediaQuery.of(context).size.height / 1,
    //           image: item.imageUrl != "url"
    //               ? NetworkImage(item.imageUrl)
    //               : NetworkImage(
    //               "assets/images/product-placeholder.png"),
    //           fit: BoxFit.cover,
    //         ),
    //         // Image.asset(
    //         //   cat["img"],
    //         //   height: MediaQuery.of(context).size.height / 6,
    //         //   width: MediaQuery.of(context).size.height / 6,
    //         //   fit: BoxFit.cover,
    //         // ),
    //         Container(
    //           decoration: BoxDecoration(
    //             gradient: LinearGradient(
    //               begin: Alignment.topCenter,
    //               end: Alignment.bottomCenter,
    //               // Add one stop for each color. Stops should increase from 0 to 1
    //               stops: [0.2, 0.7],
    //               colors: [
    //                 Color.fromARGB(100, 0, 0, 0),
    //                 Color.fromARGB(100, 0, 0, 0),
    //               ],
    //               // stops: [0.0, 0.1],
    //             ),
    //           ),
    //           height: MediaQuery.of(context).size.height / 6,
    //           width: MediaQuery.of(context).size.height / 6,
    //         ),
    //         Center(
    //           child: Container(
    //             height: MediaQuery.of(context).size.height / 6,
    //             width: MediaQuery.of(context).size.height / 6,
    //             padding: const EdgeInsets.all(1),
    //             constraints: BoxConstraints(
    //               minWidth: 20,
    //               minHeight: 20,
    //             ),
    //             child: Center(
    //               child: Text(
    //                 item.name,
    //                 style: TextStyle(
    //                   color: Colors.white,
    //                   fontSize: 20,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //                 textAlign: TextAlign.center,
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

}