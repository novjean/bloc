import 'package:bloc/db/entity/user.dart' as blocUser;

import 'package:bloc/screens/profile/profile_login_screen.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../routes/app_route_constants.dart';
import '../utils/logx.dart';
import 'chat/chat_screen.dart';
import 'home_screen.dart';
import 'parties/party_screen.dart';
import 'profile/profile_add_edit_register_page.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _TAG = 'MainScreen';

  late blocUser.User user;

  String? fcmToken = '';

  late PageController _pageController;
  int _page = 0;

  List icons = [
    Icons.home,
    Icons.whatshot_sharp,
    Icons.notifications,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    user = UserPreferences.myUser;

    // lets check if the user is already registered
    FirebaseFirestore.instance
        .collection(FirestoreHelper.USERS)
        .where('phoneNumber', isEqualTo: user.phoneNumber)
        .get()
        .then((res) {
      if (res.docs.isEmpty) {
        Logx.i(_TAG, 'user not found, registering ${user.phoneNumber}');

        if (kIsWeb) {
          user.isAppUser = false;
        } else {
          user.isAppUser = true;
        }

        FirestoreHelper.pushUser(user);
        Logx.i(_TAG, '${user.phoneNumber} is now registered with bloc!');

        UserPreferences.setUser(user);

        // lets grab more user details
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  ProfileAddEditRegisterPage(user: user, task: 'register')),
        );
      } else {
        Logx.i(_TAG, 'user found for ${user.phoneNumber}');
        List<blocUser.User> users = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String,
              dynamic>;
          final blocUser.User user = Fresh.freshUserMap(data, false);
          users.add(user);

          if (i == res.docs.length - 1) {
            user.lastSeenAt = Timestamp
                .now()
                .millisecondsSinceEpoch;
            if (UserPreferences.isUserLoggedIn()) {
              if (kIsWeb) {
                user.isAppUser = false;
              } else {
                user.isAppUser = true;
              }
            }
            FirestoreHelper.pushUser(user);
            UserPreferences.setUser(user);
          }
        }
      }
    }, onError: (e, s) {
      Logx.ex(_TAG, "error completing retrieving users for phone number : ${user.phoneNumber}", e, s);
    });

    if (!kIsWeb) {
      //the following lines are essential for notification to work in iOS
      final fbm = FirebaseMessaging.instance;
      fbm.requestPermission();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        Map<String, dynamic> data = message.data;
        // String type = data['type'];
        // Reservation reservation = Fresh.freshReservationMap(jsonDecode(data['document']), false);

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        // AppleNotification? apple = message.notification?.apple;

        if (notification != null && android != null) {
          // String? title = notification.title;
          // String? body = notification.body;

          // await NotificationService.showNotification(
          //   title: "Title of the notification",
          //   body: "Body of the notification",
          //   summary: "Small Summary",
          //   notificationLayout: NotificationLayout.ProgressBar,
          // );

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

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      fbm.subscribeToTopic('ads');

      blocUser.User user = UserPreferences.getUser();
      if (user.clearanceLevel >= Constants.CAPTAIN_LEVEL) {
        fbm.subscribeToTopic('sos');
        fbm.subscribeToTopic('order');
      }

      if (user.clearanceLevel >= Constants.PROMOTER_LEVEL) {
        fbm.subscribeToTopic('party_guest');
        fbm.subscribeToTopic('reservations');
      }

      if (user.clearanceLevel >= Constants.MANAGER_LEVEL) {
        fbm.subscribeToTopic('celebrations');
        fbm.subscribeToTopic('chat');
        fbm.subscribeToTopic('offer');
      }

      if (UserPreferences.isUserLoggedIn()) {
        // update the user is in app mode
        blocUser.User user = UserPreferences.myUser;
        user.isAppUser = true;
        FirestoreHelper.pushUser(user);
      }
    } else {
      // in web mode
      if (UserPreferences.isUserLoggedIn()) {
        // update the user is in web mode
        blocUser.User user = UserPreferences.myUser;
        user.isAppUser = false;
        FirestoreHelper.pushUser(user);
      }
    }
  }

  void _handleMessage(RemoteMessage message) {
    if(UserPreferences.myUser.id.isNotEmpty){
      GoRouter.of(context)
          .pushNamed(MyAppRouteConstants.homeRouteName);
    } else {
      GoRouter.of(context)
          .pushNamed(MyAppRouteConstants.loginRouteName, params: {
        'skip': 'true',
      });
    }

    // if (message.data['notification_type'] == 'party_guest') {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(builder: (ctx) => HomeScreen()
    //       // MainScreen(user: UserPreferences.myUser,)
    //     ),
    //   );
    // } else {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(builder: (ctx) => LoginScreen(shouldTriggerSkip: false)
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      HomeScreen(),
      // OfferScreen(),
      PartyScreen(),
      // ChatHomeScreen(),
      ChatScreen(),
      UserPreferences.isUserLoggedIn() ? ProfileScreen() : ProfileLoginScreen(),
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
      drawer: const AppDrawer(),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: List.generate(4, (index) => pages[index]),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        color: Theme.of(context).primaryColor,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // SizedBox(width: 7),
            buildTabIcon(0),
            buildTabIcon(1),
            buildTabIcon(2),
            buildTabIcon(3),
            // SizedBox(width: 7),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();

    if(!kIsWeb){
      final fbm = FirebaseMessaging.instance;

      blocUser.User user = UserPreferences.getUser();
      if (user.clearanceLevel >= Constants.CAPTAIN_LEVEL) {
        fbm.unsubscribeFromTopic('sos');
        fbm.unsubscribeFromTopic('order');
      }

      if (user.clearanceLevel >= Constants.PROMOTER_LEVEL) {
        fbm.unsubscribeFromTopic('party_guest');
        fbm.unsubscribeFromTopic('reservations');
      }

      if (user.clearanceLevel >= Constants.MANAGER_LEVEL) {
        fbm.unsubscribeFromTopic('celebrations');
        fbm.unsubscribeFromTopic('chat');
        fbm.unsubscribeFromTopic('offer');
      }
    }
  }

  void onPageChanged(int page) {
    // setState(() {
    //   this._page = page;
    // });

    if (mounted) {
      setState(() {
        this._page = page;
      });
    }
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
            : Constants.background,
        onPressed: () => _pageController.jumpToPage(index),
      ),
    );
  }
}
