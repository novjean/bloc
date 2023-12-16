import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/support_chat.dart';
import '../../main.dart';
import '../../utils/constants.dart';

class SupportChatItem extends StatefulWidget {
  final SupportChat chat;
  final bool isMe;

  const SupportChatItem(
      {Key? key,
        required this.chat,
        required this.isMe,})
      : super(key: key);

  @override
  State<SupportChatItem> createState() => _SupportChatItemState();
}

class _SupportChatItemState extends State<SupportChatItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Hero(
        tag: widget.chat.id,
        child: Card(
          elevation: 0.5,
          color: widget.isMe ? Constants.lightPrimary: Colors.white70,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
              child: ListTile(
                // leading: Padding(
                //   padding: const EdgeInsets.only(right: 5.0, top: 2),
                //   child: CircleAvatar(
                //     backgroundImage: NetworkImage(
                //       widget.chat.userImage,
                //     ),
                //   ),
                // ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.chat.userName.toLowerCase(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      DateTimeUtils.getChatDate(widget.chat.time),
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
                subtitle: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    widget.chat.type == FirestoreHelper.CHAT_TYPE_TEXT
                        ? Text(
                      widget.chat.message,
                      style: const TextStyle(
                          fontSize: 17, color: Colors.black),
                    )
                        : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: mq.width * 0.75,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: FadeInImage(
                                placeholder: const AssetImage(
                                    'assets/images/logo.png'),
                                image: NetworkImage(widget.chat.imageUrl),
                                fit: BoxFit.cover,
                              )),
                        ),
                        Text(widget.chat.message,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
