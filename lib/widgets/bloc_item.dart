import 'package:bloc/screens/bloc_detail_screen.dart';
import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc.dart';

class BlocItem extends StatelessWidget {
  final Key key;
  final Bloc bloc;
  final BlocDao dao;

  const BlocItem(this.bloc, this.dao, {required this.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              BlocDetailScreen.routeName,
              arguments: bloc.addressLine1,
            );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: bloc.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(bloc.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            bloc.addressLine1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

}