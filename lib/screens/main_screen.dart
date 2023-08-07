import 'dart:convert';

import 'package:bloc/db/entity/celebration.dart';
import 'package:bloc/db/entity/lounge_chat.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/db/shared_preferences/table_preferences.dart';
import 'package:bloc/db/shared_preferences/ui_preferences.dart';
import 'package:bloc/screens/lounge/lounges_screen.dart';

import 'package:bloc/screens/profile/profile_login_screen.dart';
import 'package:bloc/screens/promoter/promoter_main_screen.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:upgrader/upgrader.dart';

import '../db/entity/ad.dart';
import '../db/entity/party_guest.dart';
import '../db/entity/reservation.dart';
import '../db/entity/user_lounge.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../routes/route_constants.dart';
import '../utils/logx.dart';
import 'account_screen.dart';
import 'captain/captain_main_screen.dart';
import 'photos/photos_screen.dart';
import 'home_screen.dart';
import 'manager/manager_main_screen.dart';
import 'owner/owner_screen.dart';
import 'parties/parties_screen.dart';
import 'profile/profile_add_edit_register_page.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _TAG = 'MainScreen';

  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();

  late blocUser.User user;

  late PageController _pageController;
  late int _page;

  late String title;

  List icons = [
    Icons.home,
    Icons.event,
    Icons.whatshot_sharp,
    Icons.theater_comedy_outlined,
    Icons.person,
  ];

  @override
  void initState() {
    title = "bloc";

    user = UserPreferences.myUser;

    _page = UiPreferences.getHomePageIndex();
    _pageController = PageController(initialPage: _page);

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
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final blocUser.User user = Fresh.freshUserMap(data, false);
          users.add(user);

          if (i == res.docs.length - 1) {
            user.lastSeenAt = Timestamp.now().millisecondsSinceEpoch;
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
      Logx.ex(
          _TAG, "error retrieving users for phone : ${user.phoneNumber}", e, s);
    });

    if(UserPreferences.isUserLoggedIn()){
      FirestoreHelper.pullUserLounges(UserPreferences.myUser.id).then((res) {
        if(res.docs.isNotEmpty){
          List<String> userLounges = [];
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);

            userLounges.add(userLounge.loungeId);
          }
          UserPreferences.setListLounges(userLounges);
        }
      });
    }

    if (!kIsWeb) {
      //the following lines are essential for notification to work in iOS
      final fbm = FirebaseMessaging.instance;
      fbm.requestPermission();

      fbm.getToken().then((t) {
        if(t!=null){
          UserPreferences.myUser.fcmToken = t;

          FirestoreHelper.updateUserFcmToken(UserPreferences.myUser.id, t);
          Logx.d(_TAG, 'user token: $t');
        }else {
          Logx.em(_TAG, 'fcm token came in null');
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Map<String, dynamic> data = message.data;
        String type = data['type'];

        switch(type){
          case 'lounge_chats':{
            UiPreferences.setHomePageIndex(2);
            LoungeChat chat = Fresh.freshLoungeChatMap(jsonDecode(data['document']), false);
            if(UserPreferences.isUserLoggedIn() && chat.userId != UserPreferences.myUser.id){
              if(UserPreferences.getListLounges().contains(chat.loungeId)){

                RemoteNotification notification = RemoteNotification(
                  title: '🫶 ${chat.loungeName}',
                  body: chat.type == 'text'? chat.message : '🖼️ photo' ,
                );
                showNotificationChatChannel(notification);
              }
            }
            break;
          }
          case 'ads':{
            Ad ad = Fresh.freshAdMap(jsonDecode(data['document']), false);
            showNotificationHighChannel(message);
            break;
          }
          case 'party_guest':{
            PartyGuest partyGuest = Fresh.freshPartyGuestMap(jsonDecode(data['document']), false);
            if(!partyGuest.isApproved){
              showNotificationHighChannel(message);
            } else {
              Logx.ist(_TAG, 'guest list: ${partyGuest.name} added');
            }
            break;
          }
          case 'reservations':{
            Reservation reservation = Fresh.freshReservationMap(jsonDecode(data['document']), false);
            showNotificationHighChannel(message);
            break;
          }
          case 'celebrations':{
            Celebration celebration = Fresh.freshCelebrationMap(jsonDecode(data['document']), false);
            showNotificationHighChannel(message);
            break;
          }
          case 'offer':
          case 'order':
          case 'sos':
          default:{
            showNotificationHighChannel(message);
          }
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      //clear out any previous subscriptions
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
        fbm.unsubscribeFromTopic('offer');
      }

      // subscribe to topics
      fbm.subscribeToTopic('ads');
      fbm.subscribeToTopic('lounge_chats');
      if (user.clearanceLevel >= Constants.CAPTAIN_LEVEL) {
        fbm.subscribeToTopic('sos');
        fbm.subscribeToTopic('order');
      }
      if (user.clearanceLevel >= Constants.PROMOTER_LEVEL) {
        fbm.subscribeToTopic('party_guest');
        fbm.subscribeToTopic('reservations');
        fbm.subscribeToTopic('celebrations');
      }
      if (user.clearanceLevel >= Constants.MANAGER_LEVEL) {
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
    super.initState();
  }

  void _handleMessage(RemoteMessage message) {

    if (UserPreferences.myUser.id.isNotEmpty) {
      GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
    } else {
      GoRouter.of(context).pushNamed(RouteConstants.loginRouteName, params: {
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
    mq = MediaQuery.of(context).size;

    List pages = [
      const HomeScreen(),
      const PartiesScreen(),
      PhotosScreen(),
      LoungesScreen(),
      UserPreferences.isUserLoggedIn()
          ? const ProfileScreen()
          : ProfileLoginScreen(),
    ];

    return UpgradeAlert(
      upgrader: Upgrader(
          dialogStyle: Theme.of(context).platform == TargetPlatform.iOS
              ? UpgradeDialogStyle.cupertino
              : UpgradeDialogStyle.material),
      child: Scaffold(
        backgroundColor: Constants.background,
        body: SliderDrawer(
            appBar: SliderAppBar(
                appBarColor: Colors.black,
                appBarHeight: kIsWeb ? 60 : 100,
                appBarPadding: kIsWeb
                    ? (EdgeInsets.only(top: 10))
                    : (EdgeInsets.only(top: 50)),
                drawerIconColor: Constants.primary,
                drawerIconSize: 35,
                isTitleCenter: false,
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(icon: Icon(Icons.brightness_low_outlined, color: Constants.primary,),
                    onPressed: () {
                      _showAdsDialog(context);
                    },),
                ),
                title: Padding(
                  padding: kIsWeb
                      ? EdgeInsets.only(top: 10.0, left: 20)
                      : EdgeInsets.only(left: 15, top: 5.0),
                  child: Text('bloc.',
                      style: TextStyle(
                          color: Constants.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w500)),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //
                  //     // IconButton(icon: Icon(Icons.brightness_low_outlined, color: Constants.primary,),
                  //     //   onPressed: () {
                  //     //     Logx.ist(_TAG, 'mandala');
                  //     //   },)
                  //   ],
                  // ),
                )),
            key: _sliderDrawerKey,
            sliderOpenSize: 179,
            slider: _SliderView(
              onItemClick: (title) {
                handleAppDrawerClick(context, title);
              },
            ),
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: onPageChanged,
              children: List.generate(5, (index) => pages[index]),
            )),
        bottomNavigationBar: BottomAppBar(
          elevation: 1,
          color: Colors.black,
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
              buildTabIcon(4),
              // SizedBox(width: 7),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();

    if (!kIsWeb) {
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
        fbm.unsubscribeFromTopic('offer');
      }
    }
  }

  void onPageChanged(int page) {
    Logx.d(_TAG, 'onPageChanged() : $page');

    UiPreferences.setHomePageIndex(page);
    _sliderDrawerKey.currentState!.closeSlider();

    setState(() {
      _page = page;
    });
  }

  buildTabIcon(int index) {
    Logx.d(_TAG, 'buildTabIcon() : $index');

    return IconButton(
      icon: Icon(
        icons[index],
        size: 24.0,
      ),
      color:
          _page == index ? Theme.of(context).highlightColor : Constants.primary,
      onPressed: () {
        _pageController.jumpToPage(index);
      },
    );
  }

  void handleAppDrawerClick(BuildContext context, String title) async {
    switch (title) {
      case 'home':
        {
          GoRouter.of(context).goNamed(RouteConstants.homeRouteName);
          break;
        }
      case 'box office':
        {
          GoRouter.of(context).pushNamed(RouteConstants.boxOfficeRouteName);
          break;
        }
      case 'captain':
        {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => CaptainMainScreen(
                      blocServiceId: user.blocServiceId,
                    )),
          );
          break;
        }
      case 'promoter':
        {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => PromoterMainScreen()),
          );
          break;
        }
      case 'manager':
        {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => ManagerMainScreen()),
          );
          break;
        }
      case 'owner':
        {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => OwnerScreen()),
          );
          break;
        }
      case 'account':
        {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AccountScreen()),
          );
          break;
        }
      case 'login':
        {
          UserPreferences.resetUser();
          TablePreferences.resetQuickTable();

          await FirebaseAuth.instance.signOut();

          GoRouter.of(context)
              .pushNamed(RouteConstants.loginRouteName, params: {
            'skip': 'false',
          });
          break;
        }
      case 'logout':
        {
          UserPreferences.resetUser();
          TablePreferences.resetQuickTable();

          await FirebaseAuth.instance.signOut();

          GoRouter.of(context)
              .pushNamed(RouteConstants.loginRouteName, params: {
            'skip': 'false',
          });
          break;
        }
      default:
        {
          GoRouter.of(context).goNamed(RouteConstants.homeRouteName);
          break;
        }
    }

    _sliderDrawerKey.currentState!.closeSlider();
    setState(() {
      this.title = title;
    });
  }

  void showNotificationChatChannel(RemoteNotification? notification) {
    Logx.d(_TAG, 'showNotificationChatChannel');

    if(notification!=null){
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            chatChannel.id,
            chatChannel.name,
            // channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@drawable/ic_launcher',
          ),
        ),
      );
    }
  }

  void showNotificationHighChannel(RemoteMessage message) {
    Logx.d(_TAG, 'showNotificationHighChannel');

    RemoteNotification? notification = message.notification;

    if(notification!=null){
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            // channel.description,
            icon: '@drawable/ic_launcher',
          ),
        ),
      );
    }
  }

  void _showAdsDialog(BuildContext context) {
    FirestoreHelper.pullAds().then((res) {
      if(res.docs.isNotEmpty){
        List<Ad> ads = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data =
          document.data()! as Map<String, dynamic>;
          final Ad ad = Fresh.freshAdMap(data, false);
          ads.add(ad);
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'notifications'
                    .toLowerCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, color: Colors.black),
              ),
              backgroundColor: Constants.lightPrimary,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.all(16.0),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ads.length,
                  itemBuilder: (BuildContext context, int index) {
                    Ad ad = ads[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Text(ad.message),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(DateTimeUtils.getFormattedDate(ad.createdAt),
                              style: TextStyle(fontSize: 14),),
                          ],
                        ),
                        Divider(),
                        const SizedBox(height: 5),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('close',
                      style: TextStyle(color: Constants.background)),
                ),
              ],
            );
          },
        );
      }
    });

  }
}

class _SliderView extends StatelessWidget {
  final Function(String)? onItemClick;

  const _SliderView({Key? key, this.onItemClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 30),
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          CircleAvatar(
            radius: 65,
            backgroundColor: Colors.grey,
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  Image.network(UserPreferences.myUser.imageUrl).image,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            UserPreferences.myUser.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ...getMenuList()
              .map((menu) => _SliderMenuItem(
                  title: menu.title,
                  iconData: menu.iconData,
                  onTap: onItemClick))
              .toList(),
        ],
      ),
    );
  }
}

List<Menu> getMenuList() {
  List<Menu> menuItems = [];

  final user = UserPreferences.getUser();

  menuItems.add(Menu(Icons.home, 'home'));
  if (UserPreferences.isUserLoggedIn()) {
    menuItems.add(Menu(Icons.keyboard_command_key_sharp, 'box office'));
    if (user.clearanceLevel == Constants.CAPTAIN_LEVEL ||
        user.clearanceLevel >= Constants.MANAGER_LEVEL) {
      menuItems.add(Menu(Icons.adjust, 'captain'));
    }

    if (user.clearanceLevel == Constants.PROMOTER_LEVEL ||
        user.clearanceLevel >= Constants.MANAGER_LEVEL) {
      menuItems.add(Menu(Icons.adjust, 'promoter'));
    }

    if (user.clearanceLevel >= Constants.MANAGER_LEVEL) {
      menuItems.add(Menu(Icons.account_circle_outlined, 'manager'));
    }
    if (user.clearanceLevel >= Constants.OWNER_LEVEL) {
      menuItems.add(Menu(Icons.play_circle_outlined, 'owner'));
    }
    menuItems.add(Menu(Icons.settings, 'account'));
    menuItems.add(Menu(Icons.exit_to_app, 'logout'));
  } else {
    menuItems.add(Menu(Icons.exit_to_app, 'login'));
  }

  return menuItems;
}

class _SliderMenuItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Function(String)? onTap;

  const _SliderMenuItem(
      {Key? key,
      required this.title,
      required this.iconData,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(title,
            style: const TextStyle(
                color: Colors.black, fontFamily: 'BalsamiqSans_Regular')),
        leading: Icon(iconData, color: Colors.black),
        onTap: () => onTap?.call(title));
  }
}

class Menu {
  final IconData iconData;
  final String title;

  Menu(this.iconData, this.title);
}
