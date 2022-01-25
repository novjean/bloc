import 'package:bloc/screens/city_detail_screen.dart';
import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/city.dart';

class CityItem extends StatelessWidget {
  final Key key;
  final City city;
  final BlocDao dao;

  const CityItem(this.city, this.dao, {required this.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => CityDetailScreen(dao: dao, city: city)),
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
          title: Text(
            city.name,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
