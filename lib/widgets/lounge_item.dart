import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../db/entity/lounge.dart';

class LoungeItem extends StatelessWidget {
  static const String _TAG = 'LoungeItem';

  Lounge lounge;

  LoungeItem({Key? key, required this.lounge}) : super(key: key);

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
              height: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 75,
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
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 5),
                              child: RichText(
                                text: TextSpan(
                                  text: '${lounge.name} ',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 5.0, top: 5),
                              child: RichText(
                                text: TextSpan(
                                  text:
                                      '${DateTimeUtils.getChatDate(lounge.lastChatTime)} ',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              '${lounge.lastChat}',
                              // children: <TextSpan>[
                              //   TextSpan(text: lounge.lastChat),
                              // ],
                              style: const TextStyle(
                                  color: Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic),
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
