import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../widgets/chat/recent_chats.dart';

class ChatHomeScreen extends StatefulWidget {

  ChatHomeScreen({key}):super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
                  loadLounges(context), // need to define lounges - community and artists

                  // RecentChats(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}