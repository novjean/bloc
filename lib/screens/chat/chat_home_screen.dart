import 'package:flutter/material.dart';

import '../../db/dao/bloc_dao.dart';
import '../../widgets/chat/recent_chats.dart';

class ChatHomeScreen extends StatefulWidget {
  BlocDao dao;

  ChatHomeScreen({key, required this.dao}):super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon:const Icon(
      //       Icons.menu,
      //     ),
      //     onPressed: (){},
      //   ),
      //   title:Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children:const[
      //       Text("Chatting App",
      //         style: TextStyle(
      //             fontSize: 19.0,
      //             fontWeight: FontWeight.bold
      //         ),  ),
      //     ],
      //   ),
      //   elevation: 0.0,
      //   actions: <Widget>[
      //     IconButton(
      //       icon:const Icon(
      //         Icons.search,
      //       ),
      //       onPressed: (){},
      //     ),
      //   ],
      // ),
      body: Column(
        children: <Widget>[
          // const  CategorySelector(),
          Expanded(
            child: Container(
              decoration:const BoxDecoration(
                color: Color(0xFFFDF8E9),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0)
                ),
              ),
              child: Column(
                children:  <Widget>[
                  // FavoriteContacts(),
                  RecentChats(dao: widget.dao),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}