import 'package:bloc/screens/bloc_detail_screen.dart';
import 'package:flutter/material.dart';

class BlocItem extends StatelessWidget {
  final Key key;
  final String tag;
  final String addressLine1;
  final String imageUrl;

  const BlocItem(this.tag, this.addressLine1, this.imageUrl, {this.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              BlocDetailScreen.routeName,
              arguments: addressLine1,
            );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: tag,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            addressLine1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

}