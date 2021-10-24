import 'package:bloc/screens/manager_screen.dart';
import 'package:bloc/screens/owner_screen.dart';
import 'package:flutter/material.dart';

class DisplayImageBox extends StatelessWidget {
  String imageTitle;
  String imageUrl;

  DisplayImageBox(this.imageTitle,
      this.imageUrl); // const DisplayBox(String s, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProductDetailScreen(title)),);
            Navigator.of(context).pushNamed(
              imageTitle == 'manager'
                  ? ManagerScreen.routeName
                  : OwnerScreen.routeName,
              // arguments: product.id,
            );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: imageTitle,
            child:
                FadeInImage(
              placeholder: AssetImage(imageUrl),
              image: AssetImage(imageUrl),
              // NetworkImage(''),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
