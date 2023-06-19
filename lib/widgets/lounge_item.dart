import 'package:flutter/material.dart';

import '../db/entity/lounge.dart';

class LoungeItem extends StatelessWidget {
  static const String _TAG = 'LoungeItem';

  Lounge lounge;

  LoungeItem(
      {Key? key,
      required this.lounge})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: lounge.id,
          child: Card(
            elevation: 1,
            color: Theme.of(context).primaryColorLight,
            child: SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(0)),
                        image: DecorationImage(
                          image: NetworkImage(lounge.imageUrl),
                          fit: BoxFit.cover,
                          // AssetImage(food['image']),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: RichText(
                            text: TextSpan(
                              text: '${lounge.name.toLowerCase()} ',
                              style: const TextStyle(
                                  color: Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}
