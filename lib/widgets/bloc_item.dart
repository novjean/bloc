import 'package:bloc/screens/bloc/bloc_detail_screen.dart';
import 'package:flutter/material.dart';

import '../db/entity/bloc.dart';
import '../screens/owner/bloc_add_edit_screen.dart';

class BlocItem extends StatelessWidget {
  final Key key;
  final Bloc bloc;

  const BlocItem(this.bloc, {required this.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            bloc.name,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => BlocAddEditScreen(bloc: bloc, task: 'Edit',)),
              );
            },
            color: Theme.of(context).primaryColor,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => BlocDetailScreen(bloc: bloc)),
            );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: bloc.id,
            child: FadeInImage(
              placeholder:
                  const AssetImage('assets/images/product-placeholder.png'),
              image: bloc.imageUrls.first != "url"
                  ? NetworkImage(bloc.imageUrls.first)
                  : const NetworkImage("assets/images/product-placeholder.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
