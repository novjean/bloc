import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/lounge_chat.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../ui/toaster.dart';

class ChatItem extends StatefulWidget {
  final LoungeChat chat;
  final bool isMe;
  final bool isMember;

  const ChatItem(
      {Key? key,
      required this.chat,
      required this.isMe,
      required this.isMember})
      : super(key: key);

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  static const String _TAG = 'ChatItem';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Hero(
        tag: widget.chat.id,
        child: Card(
          elevation: 0.5,
          color: Constants.lightPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(right: 5.0, top: 2),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.chat.userImage,
                    ),
                  ),
                ),
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
                                width: MediaQuery.of(context).size.width * 0.75,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'like',
                                onPressed: () {
                                  if(widget.isMember){
                                    if (widget.chat.upVoters
                                        .contains(UserPreferences.myUser.id)) {
                                      // nothing to do
                                      if(UserPreferences.myUser.clearanceLevel==Constants.ADMIN_LEVEL){
                                        widget.chat.vote++;
                                        FirestoreHelper.pushLoungeChat(widget.chat);
                                        setState(() {});
                                      } else {
                                        Logx.ist(_TAG, 'your ❤️ is already there. much love, wow 🐶');
                                      }
                                    } else if (widget.chat.downVoters
                                        .contains(UserPreferences.myUser.id)) {
                                      widget.chat.downVoters
                                          .remove(UserPreferences.myUser.id);
                                      widget.chat.vote++;
                                      FirestoreHelper.pushLoungeChat(widget.chat);
                                      setState(() {});
                                    } else {
                                      widget.chat.upVoters
                                          .add(UserPreferences.myUser.id);
                                      widget.chat.vote++;
                                      FirestoreHelper.pushLoungeChat(widget.chat);
                                      setState(() {});
                                    }
                                  } else {
                                    Toaster.shortToast('have a 🍕 slice and join us to vote');
                                  }
                                },
                                iconSize: 18.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 5, top: 4),
                            child: Text(
                              widget.chat.vote.toString(),
                              style: const TextStyle(
                                color: Constants.darkPrimary,
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: IconButton(
                                icon: const Icon(Icons.thumb_down, color: Colors.black54, size: 23,),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'dislike',
                                onPressed: () {
                                  if(widget.isMember){
                                    if (widget.chat.downVoters
                                        .contains(UserPreferences.myUser.id)) {
                                      // nothing to do
                                    } else if (widget.chat.upVoters
                                        .contains(UserPreferences.myUser.id)) {
                                      widget.chat.upVoters
                                          .remove(UserPreferences.myUser.id);
                                      widget.chat.vote--;
                                      FirestoreHelper.pushLoungeChat(widget.chat);
                                      setState(() {});
                                    } else {
                                      widget.chat.downVoters
                                          .add(UserPreferences.myUser.id);
                                      widget.chat.vote--;
                                      FirestoreHelper.pushLoungeChat(widget.chat);
                                      setState(() {});
                                    }
                                  } else {
                                    Toaster.shortToast('have a 🍕 slice and join us to vote');
                                  }
                                },
                                iconSize: 18.0),
                          ),
                          const Spacer(),
                          UserPreferences.myUser.clearanceLevel == Constants.ADMIN_LEVEL ? Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                                '👁️‍🗨️ ${widget.chat.views}'
                            ),
                          ) : const SizedBox()
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
