import 'package:bloc/screens/owner/owner_city_screen.dart';
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
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => OwnerCityScreen(city: city)),
            );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: city.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/logo.png'),
              image: NetworkImage(city.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            city.name,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
