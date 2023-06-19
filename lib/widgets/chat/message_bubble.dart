import 'package:bloc/helpers/firestore_helper.dart';
import 'package:flutter/material.dart';

import '../../db/entity/chat.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';

class MessageBubble extends StatefulWidget {
  final Chat chat;
  final bool isMe;

  const MessageBubble({Key? key, required this.chat, required this.isMe})
      : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Hero(
        tag: widget.chat.id,
        child: Card(
          color: Constants.lightPrimary,

          child: Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.chat.userImage,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 10, right: 5
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.chat.userName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isMe ? Colors.black : Constants.darkPrimary,
                                ),
                              ),
                              Text(DateTimeUtils.getChatDate(widget.chat.time))
                            ],
                          ),
                        ),
                        Text(
                          widget.chat.message,
                          style: TextStyle(fontSize: 16),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.keyboard_arrow_up),
                                tooltip: 'up vote',
                                onPressed: () {
                                  if(widget.chat.upVoters.contains(UserPreferences.myUser.id)){
                                    // nothing to do
                                  } else if(widget.chat.downVoters.contains(UserPreferences.myUser.id)) {
                                    widget.chat.downVoters.remove(UserPreferences.myUser.id);
                                    widget.chat.vote++;
                                    FirestoreHelper.pushChat(widget.chat);
                                    setState(() {
                                    });
                                  } else{
                                    widget.chat.upVoters.add(UserPreferences.myUser.id);
                                    widget.chat.vote++;
                                    FirestoreHelper.pushChat(widget.chat);
                                    setState(() {
                                    });
                                  }

                                },
                                iconSize: 18.0
                            ),
                            Text(widget.chat.vote.toString()),
                            IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down),
                                tooltip: 'down vote',
                                onPressed: () {
                                  if(widget.chat.downVoters.contains(UserPreferences.myUser.id)){
                                    // nothing to do
                                  } else if(widget.chat.upVoters.contains(UserPreferences.myUser.id)){
                                    widget.chat.upVoters.remove(UserPreferences.myUser.id);
                                    widget.chat.vote--;
                                    FirestoreHelper.pushChat(widget.chat);
                                    setState(() {
                                    });
                                  }
                                  else {
                                    widget.chat.downVoters.add(UserPreferences.myUser.id);
                                    widget.chat.vote--;
                                    FirestoreHelper.pushChat(widget.chat);
                                    setState(() {
                                    });
                                  }
                                },
                                iconSize: 18.0
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
