import 'package:flutter/material.dart';

import '../../db/entity/lounge.dart';
import '../../utils/date_time_utils.dart';

class LoungeBanner extends StatelessWidget {
  static const String _TAG = 'LoungeBanner';

  Lounge lounge;

  LoungeBanner({Key? key, required this.lounge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
      child: ClipRRect(
        borderRadius:  BorderRadius.circular(15),
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
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: const BorderRadius.all(Radius.circular(0)),
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
                                children: <TextSpan>[
                                ]
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            '${DateTimeUtils.getChatDate(lounge.lastChatTime)}',
                            style: const TextStyle(fontSize: 18),
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