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
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:upgrader/upgrader.dart';

import '../db/entity/ad.dart';
import '../db/entity/friend.dart';
import '../db/entity/user_lounge.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../routes/route_constants.dart';
import '../services/notification_service.dart';
import '../utils/logx.dart';
import '../utils/number_utils.dart';
import '../widgets/ui/slider_view.dart';
import 'captain/captain_main_screen.dart';
import 'experimental/bloc_selection_screen.dart';
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
    Icons.music_note_outlined,
    Icons.photo_outlined,
    Icons.theater_comedy_outlined,
    Icons.person,
  ];

  @override
  void initState() {
    Logx.d(_TAG, 'MainScreen');

    title = "bloc";
    user = UserPreferences.myUser;

    _page = UiPreferences.getHomePageIndex();
    _pageController = PageController(initialPage: _page);

    FirestoreHelper.pullUserByPhoneNumber(user.phoneNumber).then((res) {
      if (res.docs.isEmpty) {
        Logx.i(_TAG, 'user not found, registering ${user.phoneNumber}');

        if (kIsWeb) {
          user = user.copyWith(
            isAppUser: false,
            appVersion: Constants.appVersion,
          );
        } else {
          user = user.copyWith(
            isAppUser: true,
            appVersion: Constants.appVersion,
            isIos: Theme.of(context).platform == TargetPlatform.iOS,
          );
        }

        UserPreferences.setUser(user);
        FirestoreHelper.pushUser(user);

        Logx.i(_TAG, '${user.phoneNumber} is now registered with bloc!');

        // lets grab more user details
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  ProfileAddEditRegisterPage(user: user, task: 'register')),
        );
      } else {
        Logx.d(_TAG, 'skipPhoneNumber logged in');

        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        blocUser.User user1 = Fresh.freshUserMap(data, false);
        user1 = user1.copyWith(
            lastSeenAt: Timestamp.now().millisecondsSinceEpoch,
            appVersion: Constants.appVersion);

        if (kIsWeb) {
          user1 = user1.copyWith(
            isAppUser: false,
          );
        } else {
          user1 = user1.copyWith(
            isAppUser: true,
            isIos: Theme.of(context).platform == TargetPlatform.iOS,
          );
        }

        if (user1.username.isEmpty) {
          String username = '';
          if (user1.surname.trim().isNotEmpty) {
            username =
                '${user1.name.trim().toLowerCase()}_${user1.surname.trim().toLowerCase()}';
          } else {
            username = user1.name.trim().toLowerCase();
          }

          //check if username is present in db
          FirestoreHelper.pullUserByUsername(username).then((res) {
            if (res.docs.isNotEmpty) {
              // username is already taken
              username = username +
                  NumberUtils.generateRandomNumber(1, 999).toString().trim();
              user1 = user1.copyWith(username: username);
              FirestoreHelper.pushUser(user1);
              UserPreferences.setUser(user1);
            } else {
              user1 = user1.copyWith(username: username);
              FirestoreHelper.pushUser(user1);
              UserPreferences.setUser(user1);
            }
          });
        } else {
          FirestoreHelper.pushUser(user1);
          UserPreferences.setUser(user1);
        }
      }
    }, onError: (e, s) {
      Logx.ex(
          _TAG, "error retrieving users for phone : ${user.phoneNumber}", e, s);
    });

    if (!kIsWeb) {
      final fbm = FirebaseMessaging.instance;

      fbm.onTokenRefresh.listen((token) {
        // Note: This callback is fired at each app startup and whenever a new
        // token is generated.
        if (UserPreferences.isUserLoggedIn()) {
          blocUser.User user = UserPreferences.myUser;
          user = user.copyWith(fcmToken: token);
          UserPreferences.setUser(user);

          FirestoreHelper.updateUserFcmToken(UserPreferences.myUser.id, token);
        }
      }).onError((err) {
        Logx.em(_TAG, err.toString());
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        NotificationService.handleMessage(message, false);
      });

      //clear out any previous subscriptions
      blocUser.User user = UserPreferences.getUser();
      fbm.unsubscribeFromTopic('sos');
      fbm.unsubscribeFromTopic('order');
      fbm.unsubscribeFromTopic('party_guest');
      fbm.unsubscribeFromTopic('reservations');
      fbm.unsubscribeFromTopic('celebrations');
      fbm.unsubscribeFromTopic('offer');
      fbm.unsubscribeFromTopic('user_photos');
      fbm.unsubscribeFromTopic('tixs');
      fbm.unsubscribeFromTopic('support_chats');
      fbm.unsubscribeFromTopic('notification_tests');
      fbm.unsubscribeFromTopic('notification_tests_2');

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
      if (user.clearanceLevel == Constants.ADMIN_LEVEL) {
        fbm.subscribeToTopic('user_photos');
        fbm.subscribeToTopic('tixs');
        fbm.subscribeToTopic('support_chats');
        fbm.subscribeToTopic('notification_tests');
        fbm.subscribeToTopic('notification_tests_2');
      }

      if (UserPreferences.isUserLoggedIn()) {
        FirestoreHelper.pullUserLounges(UserPreferences.myUser.id).then((res) {
          if (res.docs.isNotEmpty) {
            List<String> userLounges = [];
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);
              userLounges.add(userLounge.loungeId);

              FirebaseMessaging.instance
                  .unsubscribeFromTopic(userLounge.loungeId);
              FirebaseMessaging.instance.subscribeToTopic(userLounge.loungeId);
              Logx.d(
                  _TAG, 'subscribed to lounge topic: ${userLounge.loungeId}');

              if (userLounge.userFcmToken.isEmpty &&
                  UserPreferences.myUser.fcmToken.isNotEmpty) {
                userLounge = userLounge.copyWith(
                    userFcmToken: UserPreferences.myUser.fcmToken);
                FirestoreHelper.pushUserLounge(userLounge);
              }
            }
            UserPreferences.setListLounges(userLounges);
          }
        });

        FirestoreHelper.pullFriends(UserPreferences.myUser.id).then((res) {
          if (res.docs.isNotEmpty) {
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              Friend friend = Fresh.freshFriendMap(data, false);

              if (friend.isFollowing) {
                FirebaseMessaging.instance
                    .unsubscribeFromTopic(friend.friendUserId);

                FirebaseMessaging.instance
                    .subscribeToTopic(friend.friendUserId);
              } else {
                FirebaseMessaging.instance
                    .unsubscribeFromTopic(friend.friendUserId);
              }
            }
          }
        });
      }

      // awesome notification init
      NotificationService.initializeNotification();
    } else {
      Logx.d(_TAG, 'fcm in web mode');
    }

    super.initState();

    if(!kIsWeb){
      getToken();
    }
  }

  getToken() async {
    String? deviceToken = await FirebaseMessaging.instance.getToken();
    Logx.d(_TAG, 'fcm token: ${deviceToken!}');

    if (UserPreferences.isUserLoggedIn()) {
      blocUser.User user = UserPreferences.myUser;
      String oldToken = user.fcmToken;

      user = user.copyWith(fcmToken: deviceToken);
      UserPreferences.setUser(user);

      if (oldToken != deviceToken) {
        FirestoreHelper.updateUserFcmToken(
            UserPreferences.myUser.id, deviceToken);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    List pages = [
      const HomeScreen(),
      const PartiesScreen(),
      const PhotosScreen(),
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
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: Constants.background,
          body: SliderDrawer(
              appBar: SliderAppBar(
                  appBarColor: Colors.black,
                  appBarHeight: kIsWeb ? 60 : 100,
                  appBarPadding: kIsWeb
                      ? (const EdgeInsets.only(top: 10))
                      : (const EdgeInsets.only(top: 50)),
                  drawerIconColor: Constants.primary,
                  drawerIconSize: 30,
                  isTitleCenter: false,
                  trailing: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      UserPreferences.isUserLoggedIn()
                          ? Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (ctx) =>
                                            const BlocSelectionScreen()),
                                  );
                                },
                                child: SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: Image.asset(
                                    'assets/icons/ic_cube_sugar.png',
                                    width: 26,
                                    height: 26,
                                  ),
                                ),
                              ))
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.brightness_low_outlined,
                            color: Constants.primary,
                          ),
                          onPressed: () async {
                            _showAdsDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  title: const Padding(
                    padding: kIsWeb
                        ? EdgeInsets.only(top: 10.0, left: 20)
                        : EdgeInsets.only(left: 15, top: 5.0),
                    child: Text('bloc.',
                        style: TextStyle(
                            color: Constants.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w500)),
                  )),
              key: _sliderDrawerKey,
              sliderOpenSize: 179,
              slider: SliderView(
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
                SizedBox(width: 1),
                buildTabIcon(0),
                buildTabIcon(1),
                buildTabIcon(2),
                buildTabIcon(3),
                buildTabIcon(4),
                SizedBox(width: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();

    if (!kIsWeb) {
      final fbm = FirebaseMessaging.instance;
      fbm.unsubscribeFromTopic('sos');
      fbm.unsubscribeFromTopic('order');
      fbm.unsubscribeFromTopic('party_guest');
      fbm.unsubscribeFromTopic('reservations');
      fbm.unsubscribeFromTopic('celebrations');
      fbm.unsubscribeFromTopic('offer');
      fbm.unsubscribeFromTopic('user_photos');
      fbm.unsubscribeFromTopic('tixs');
      fbm.unsubscribeFromTopic('support_chats');
      fbm.unsubscribeFromTopic('notification_tests');
      fbm.unsubscribeFromTopic('notification_tests_2');
      fbm.unsubscribeFromTopic('lounge_chats');

      if (UserPreferences.isUserLoggedIn()) {
        FirestoreHelper.pullUserLounges(UserPreferences.myUser.id).then((res) {
          if (res.docs.isNotEmpty) {
            List<String> userLounges = [];
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);
              userLounges.add(userLounge.loungeId);

              FirebaseMessaging.instance
                  .unsubscribeFromTopic(userLounge.loungeId);
            }
            UserPreferences.setListLounges(userLounges);
          }
        });

        FirestoreHelper.pullFriends(UserPreferences.myUser.id).then((res) {
          if (res.docs.isNotEmpty) {
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              Friend friend = Fresh.freshFriendMap(data, false);

              FirebaseMessaging.instance
                  .unsubscribeFromTopic(friend.friendUserId);
            }
          }
        });
      }
    }

    super.dispose();
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
          GoRouter.of(context).goNamed(RouteConstants.landingRouteName);
          break;
        }
      case 'box office':
        {
          GoRouter.of(context).pushNamed(RouteConstants.boxOfficeRouteName);
          break;
        }
      case 'reservation':
        {
          GoRouter.of(context).pushNamed(RouteConstants.reservationRouteName);
          break;
        }
      case 'support':
        {
          GoRouter.of(context).pushNamed(RouteConstants.supportRouteName);
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
            MaterialPageRoute(builder: (ctx) => const PromoterMainScreen()),
          );
          break;
        }
      case 'manager':
        {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const ManagerMainScreen()),
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
          GoRouter.of(context).pushNamed(RouteConstants.accountRouteName);
          break;
        }
      case 'login':
        {
          UserPreferences.resetUser();
          TablePreferences.resetQuickTable();

          await FirebaseAuth.instance.signOut();

          GoRouter.of(context)
              .pushNamed(RouteConstants.loginRouteName, pathParameters: {
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
              .pushNamed(RouteConstants.loginRouteName, pathParameters: {
            'skip': 'false',
          });
          break;
        }
      default:
        {
          GoRouter.of(context).goNamed(RouteConstants.landingRouteName);
          break;
        }
    }

    _sliderDrawerKey.currentState!.closeSlider();
    setState(() {
      this.title = title;
    });
  }

  void _showAdsDialog(BuildContext context) {
    FirestoreHelper.pullAds().then((res) {
      if (res.docs.isNotEmpty) {
        List<Ad> ads = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Ad ad = Fresh.freshAdMap(data, false);
          ads.add(ad);
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'notifications'.toLowerCase(),
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
                            Text(
                              DateTimeUtils.getFormattedDate(ad.createdAt),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const Divider(),
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

class ThreeDBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
