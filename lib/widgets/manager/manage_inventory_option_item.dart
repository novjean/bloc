import 'package:bloc/db/entity/inventory_option.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class ManageInventoryOptionItem extends StatelessWidget{
  static const String _TAG = 'ManageInventoryOptionItem';

  InventoryOption inventoryOption;

  ManageInventoryOptionItem({Key? key, required this.inventoryOption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: inventoryOption.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: '${inventoryOption.title} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  // subtitle: Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('${inventoryOption.views} 👁️'),
                  //     Text('${inventoryOption.likers.length} 🖤'),
                  //     Text('${inventoryOption.downloadCount} 💾'),
                  //   ],
                  // ),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      '${inventoryOption.sequence}',
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