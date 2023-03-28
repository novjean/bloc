import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/screens/profile/profile_login_screen.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../db/shared_preferences/user_preferences.dart';
import '../../db/entity/user.dart' as blocUser;
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../utils/logx.dart';
import 'home_screen.dart';
import 'parties/party_screen.dart';
import 'profile/profile_add_edit_register_page.dart';
import 'profile/profile_page.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  final blocUser.User user;

  MainScreen({key, required this.user}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _TAG = 'PartyAddEditScreen';

  late PageController _pageController;
  int _page = 0;

  List icons = [
    Icons.home,
    Icons.whatshot_sharp,
    // Icons.notifications,
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
        if (res.docs.isEmpty) {
          Logx.i(_TAG, "user not found, registering " + widget.user.phoneNumber.toString());
          // register the user, and we might need to get more info about the user
          FirestoreHelper.pushUser(widget.user);
          Logx.i(_TAG, widget.user.phoneNumber.toString() +
              ' is now registered with bloc!');

          UserPreferences.setUser(widget.user);

          // lets grab more user details
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ProfileAddEditRegisterPage(
                    user: widget.user, task: 'register')),
          );
        } else {
          Logx.i(_TAG, "user found for " + widget.user.phoneNumber.toString());
          List<blocUser.User> users = [];

          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final blocUser.User user = Fresh.freshUserMap(data, true);
            users.add(user);

            if (i == res.docs.length - 1) {
              user.lastSeenAt = Timestamp.now().millisecondsSinceEpoch;
              FirestoreHelper.pushUser(user);

              UserPreferences.setUser(user);
            }
          }
        }
      },
      onError: (e,s) {
        Logx.ex(_TAG, "error completing retrieving users for phone number : " +
            widget.user.phoneNumber.toString(), e, s);
      }
    );

    if (!kIsWeb) {
      //the following lines are essential for notification to work in iOS
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
                // channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: '@mipmap/launcher_icon',
              ),
            ),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        Logx.i(_TAG, 'a new onMessageOpenedApp event was published!');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => HomeScreen()),
        );

        return;
      });
      // fbm.subscribeToTopic('chat');
      fbm.subscribeToTopic('offer');

      blocUser.User user = UserPreferences.getUser();
      if (user.clearanceLevel >= Constants.CAPTAIN_LEVEL) {
        fbm.subscribeToTopic('sos');
        fbm.subscribeToTopic('order');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      HomeScreen(),
      // OfferScreen(),
      PartyScreen(),
      // ChatScreen(),
      UserPreferences.isUserLoggedIn() ? ProfilePage() : ProfileLoginScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text('bloc'),
        backgroundColor: Theme.of(context).backgroundColor,
        // actions: [
        //   DropdownButton(
        //     dropdownColor: Theme.of(context).primaryColorLight,
        //     underline: Container(),
        //     icon: Icon(Icons.more_vert,
        //         color: Theme.of(context).primaryIconTheme.color),
        //     items: [
        //       DropdownMenuItem(
        //         child: Container(
        //           child: Row(
        //             children: [
        //               Icon(Icons.exit_to_app),
        //               SizedBox(
        //                 width: 8,
        //               ),
        //               Text(UserPreferences.isUserLoggedIn() ? 'logout' : 'login'),
        //             ],
        //           ),
        //         ),
        //         value: UserPreferences.isUserLoggedIn() ? 'logout' : 'login',
        //       ),
        //     ],
        //     onChanged: (itemIdentifier) {
        //       if (itemIdentifier == 'logout' || itemIdentifier == 'login') {
        //         UserPreferences.resetUser();
        //
        //         FirebaseAuth.instance.signOut();
        //         Navigator.of(context).pushReplacement(
        //           MaterialPageRoute(builder: (context) => LoginScreen()),
        //         );
        //       }
        //     },
        //   )
        // ],
      ),
      drawer: AppDrawer(),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: List.generate(3, (index) => pages[index]),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // SizedBox(width: 7),
            buildTabIcon(0),
            buildTabIcon(1),
            buildTabIcon(2),
            // buildTabIcon(3),
            // SizedBox(width: 7),
          ],
        ),
        color: Theme.of(context).primaryColor,
        shape: CircularNotchedRectangle(),
      ),
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
      // margin:
      //     EdgeInsets.fromLTRB(index == 3 ? 0 : 0, 0, index == 1 ? 30 : 0, 0),
      child: IconButton(
        icon: Icon(
          icons[index],
          size: 24.0,
        ),
        color: _page == index
            ? Theme.of(context).highlightColor
            : Theme.of(context).backgroundColor,
        onPressed: () => _pageController.jumpToPage(index),
      ),
    );
  }
}
