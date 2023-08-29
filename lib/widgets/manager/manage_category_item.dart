import 'package:flutter/material.dart';

import '../../../db/entity/party_photo.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../db/entity/category.dart';

class ManageCategoryItem extends StatelessWidget{
  static const String _TAG = 'ManageCategoryItem';

  Category category;

  ManageCategoryItem({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: category.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: '${category.name} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  subtitle: Text(category.type),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      '${category.sequence} ',
                      style: const TextStyle(
                        fontFamily: Constants.fontDefault,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }

}