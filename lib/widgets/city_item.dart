import 'package:bloc/screens/city_detail_screen.dart';
import 'package:flutter/material.dart';

import '../db/entity/city.dart';

class CityItem extends StatelessWidget {
  final Key key;
  final City city;

  const CityItem(this.city, {required this.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CityDetailScreen(this.tag, this.cityName)),);
            Navigator.of(context).pushNamed(
              CityDetailScreen.routeName,
              arguments: city.name,
              );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: city.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(city.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          // leading is adding a widget at the beginning
          // leading: IconButton(
          //   icon: Icon(
          //     product.isFavorite ? Icons.favorite : Icons.favorite_border,
          //   ),
          //   // onPressed: () {
          //   //   product.toggleFavoriteStatus(authData.token, authData.userId);
          //   // },
          //   // so if we had something that is constant,
          //   // then point it to the child and it will not be reloaded
          //   // label: child,
          //   color: Theme.of(context).accentColor,
          // ),
          // child: Text('Never changes!'),,
          title: Text(
            city.name,
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
  }
}
