import 'package:bloc/screens/bloc/bloc_detail_screen.dart';
import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc.dart';
import '../screens/owner/bloc_add_edit_screen.dart';

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
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => BlocDetailScreen(dao: dao, bloc: bloc)),
            );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: bloc.id,
            child: FadeInImage(
              placeholder:
                  const AssetImage('assets/images/product-placeholder.png'),
              image: bloc.imageUrl != "url"
                  ? NetworkImage(bloc.imageUrl)
                  : NetworkImage("assets/images/product-placeholder.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            bloc.name,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => BlocAddEditScreen(bloc: bloc, task: 'Edit',)),
              );
            },
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
