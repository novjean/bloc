import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/lounge_chat.dart';
import '../../db/entity/lounge.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logx.dart';

class LoungeItem extends StatelessWidget {
  static const String _TAG = 'LoungeItem';

  Lounge lounge;

  LoungeItem({Key? key, required this.lounge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: lounge.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading: FadeInImage(
                    placeholder: const AssetImage('assets/icons/logo.png'),
                    image: NetworkImage(lounge.imageUrl),
                    fit: BoxFit.cover,
                  ),
                  title: RichText(
                    text: TextSpan(
                      text: '${lounge.name} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  subtitle: _showLastChat(context),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                          '${DateTimeUtils.getChatDate(lounge.lastChatTime)} ',
                      style: const TextStyle(
                        fontFamily: Constants.fontDefault,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // leadingAndTrailingTextStyle: TextStyle(
                  //     color: Colors.black, fontFamily: 'BalsamiqSans_Regular'),
                  // trailing: Text(time, style: TextStyle(fontSize: 10),),
                )),
          ),
        ),
      ),
    );
  }

  _showLastChat(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getLastLoungeChat(lounge.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const Text('...');
          case ConnectionState.active:
          case ConnectionState.done:
            {
              try {
                DocumentSnapshot document = snapshot.data!.docs[0];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                final LoungeChat chat = Fresh.freshLoungeChatMap(data, false);

                String photoUrl = '';
                String photoChat = '';

                if (chat.type == 'image') {
                  int firstDelimiterIndex = chat.message.indexOf(',');
                  if (firstDelimiterIndex != -1) {
                    // Use substring to split the string into two parts
                    photoUrl = chat.message.substring(0, firstDelimiterIndex);
                    photoChat = chat.message.substring(firstDelimiterIndex + 1);
                  } else {
                    // Handle the case where the delimiter is not found
                    photoUrl = chat.message;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: chat.type == 'text'
                        ? Text(
                            '${chat.userName} : ${chat.message}',
                            style: const TextStyle(
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                            ),
                          )
                        : Text(
                            '${chat.userName} : 📸 $photoChat',
                            style: const TextStyle(
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                            ),
                          ),
                  ),
                );
              } catch (e) {
                Logx.em(_TAG, e.toString());
              }
            }

            return Text('...');
        }
      },
    );
  }
}
