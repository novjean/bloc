import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/dao/bloc_dao.dart';
import '../../db/entity/chat.dart';
import '../../db/entity/message.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/firestore_helper.dart';

class RecentChats extends StatelessWidget {
  BlocDao dao;

  RecentChats({key, required this.dao}):super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _stream = FirestoreHelper.getChatsSnapshot();

    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Chat> chats = [];

          for (int i=0; i<chatSnapshot.data!.docs.length; i++) {
            DocumentSnapshot document = chatSnapshot.data!.docs[i];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            final Chat chat = Chat.fromJson(data);
            chats.add(chat);

            if (i == chatSnapshot.data!.docs.length - 1) {
              return _displayChats(context, chats);
            }
          }
          return Text('Loading chats...');
        });
  }

  _displayChats(BuildContext context, List<Chat> chats){
    return Expanded(
      child: Container(
        decoration:const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0)
          ),
        ),
        child: ClipRRect(
          borderRadius:const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0)
          ),
          child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index){
                final Message chat = _getMessage(chats[index]);
                return GestureDetector(
                  onTap: (){
                    // final User user;
                    // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                    //     ChatScreens(user: chat.sender,)));
                  },
                  child: Container(
                    margin:const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0, left : 5.0),
                    padding:const EdgeInsets.symmetric(horizontal: 20.0 , vertical: 10.0),
                    decoration: BoxDecoration(
                      color: chat.unread ? Theme.of(context).primaryColor : Colors.white,
                      borderRadius:const BorderRadius.only(
                        topRight:Radius.circular(0.0),
                        bottomRight: Radius.circular(10.0),
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(0.0)
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: <Widget>[
                            CircleAvatar(radius: 35.0,
                              backgroundImage: NetworkImage(chat.sender.imageUrl),),
                            const   SizedBox(width: 10.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chat.sender.name,
                                  style:const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const   SizedBox(height: 5.0,),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.45,
                                  child: Text(chat.text,
                                    style:const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(chat.time,
                              style:const TextStyle(
                                color: Colors.grey,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const  SizedBox(height: 5.0,),
                            chat.unread ?  Container(
                              width: 40.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child:const Text("NEW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              alignment: Alignment.center,
                            ) : Text(""),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
          ),
        ),
      ),
    );;
  }

  Message _getMessage(Chat chat) {
    Message message = Message(
      sender: UserPreferences.getUser(),
      time: "4:20",
      text: chat.text,
      isLiked: true,
      unread: true,
    );
    return message;
  }
}