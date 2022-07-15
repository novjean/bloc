import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/screens/login_screen.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

import '../db/shared_preferences/user_preferences.dart';
import '../../db/entity/user.dart' as blocUser;
import '../helpers/firestore_helper.dart';
import '../main.dart';
import 'experimental/offers_screen.dart';
import 'home_screen.dart';
import 'events/event_screen.dart';
import 'chat/chat_screen.dart';
import 'profile/profile_page.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  final BlocDao dao;
  final blocUser.User user;

  MainScreen({key, required this.dao, required this.user}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var logger = Logger();
  late PageController _pageController;
  int _page = 0;

  List icons = [
    Icons.home,
    Icons.label,
    Icons.add,
    Icons.notifications,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // lets check if the user is already registered
    FirebaseFirestore.instance
        .collection(FirestoreHelper.USERS)
        .where('phoneNumber', isEqualTo: widget.user.phoneNumber)
        .get()
        .then(
      (res) {
        print("Successfully retrieved users for " +
            widget.user.phoneNumber.toString());

        if (res.docs.isEmpty) {
          // register the user, and we might need to get more info about the user
          FirestoreHelper.insertPhoneUser(widget.user);
          print(widget.user.phoneNumber.toString() +
              ' is now registered with bloc!');
        } else {
          List<blocUser.User> users = [];

          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final blocUser.User user = blocUser.User.fromMap(data);
            // BlocRepository.insertProduct(widget.dao, product);
            users.add(user);

            if (i == res.docs.length - 1) {
              UserPreferences.setUser(user);
            }
          }
        }
      },
      onError: (e) => print(
          "Error completing retrieving users for phone number : " +
              widget.user.phoneNumber.toString() +
              " : $e"),
    );

    // disabling this as it is only for ios
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: '@mipmap/launcher_icon',
            ),
          ),
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => ChatScreen(dao: widget.dao)),
      );

      return;
    });
    fbm.subscribeToTopic('chat');

    blocUser.User user = UserPreferences.getUser();
    if (user.clearanceLevel > Constants.MANAGER_LEVEL) {
      fbm.subscribeToTopic('sos');
    }
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      HomeScreen(dao: widget.dao),
      EventScreen(),
      OfferScreen(),
      ChatScreen(dao: widget.dao),
      ProfilePage(dao: widget.dao),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLOC'),
        actions: [
          DropdownButton(
            underline: Container(),
            icon: Icon(Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: const [
                      Icon(Icons.exit_to_app),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => LoginScreen(dao: widget.dao)),
                );
              }
            },
          )
        ],
      ),
      drawer: AppDrawer(dao: widget.dao),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: List.generate(5, (index) => pages[index]),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // SizedBox(width: 7),
            buildTabIcon(0),
            buildTabIcon(1),
            buildTabIcon(3),
            buildTabIcon(4),
            // SizedBox(width: 7),
          ],
        ),
        color: Theme.of(context).primaryColor,
        shape: CircularNotchedRectangle(),
      ),
      // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   elevation: 10.0,
      //   child: Icon(
      //     Icons.add,
      //   ),
      //   onPressed: () => _pageController.jumpToPage(2),
      // ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  buildTabIcon(int index) {
    return Container(
      margin:
          EdgeInsets.fromLTRB(index == 3 ? 30 : 0, 0, index == 1 ? 30 : 0, 0),
      child: IconButton(
        icon: Icon(
          icons[index],
          size: 24.0,
        ),
        color: _page == index
            ? Theme.of(context).accentColor
            : Theme.of(context).textTheme.caption!.color,
        onPressed: () => _pageController.jumpToPage(index),
      ),
    );
  }
}
