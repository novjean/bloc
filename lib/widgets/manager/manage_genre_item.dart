import 'package:bloc/db/entity/genre.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class ManageGenreItem extends StatelessWidget{
  static const String _TAG = 'ManageGenreItem';

  Genre genre;

  ManageGenreItem({Key? key, required this.genre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: genre.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: genre.name,
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }


}