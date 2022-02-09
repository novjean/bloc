import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc_service.dart';
import '../screens/bloc_service_detail_screen.dart';

class BlocServiceItem extends StatelessWidget {
  final Key key;
  final BlocService service;
  final BlocDao dao;

  const BlocServiceItem(this.service, this.dao, {required this.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => BlocServiceDetailScreen(dao: dao, service: service)),
            );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: service.id,
            child: FadeInImage(
              placeholder:
              const AssetImage('assets/images/product-placeholder.png'),
              image: service.imageUrl != "url"
                  ? NetworkImage(service.imageUrl)
                  : NetworkImage("assets/images/product-placeholder.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            service.name,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
