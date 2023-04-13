import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/screens/main_screen.dart';
import 'package:bloc/screens/manager/manager_main_screen.dart';
import 'package:bloc/screens/owner/owner_screen.dart';
import 'package:bloc/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/account_screen.dart';
import '../screens/box_office/box_office_screen.dart';
import '../screens/captain/captain_main_screen.dart';
import '../screens/login_screen.dart';
import '../screens/user/order_history_screen.dart';
import '../utils/logx.dart';

class AppDrawer extends StatelessWidget {
  static const String _TAG = 'AppDrawer';

  const AppDrawer({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = UserPreferences.getUser();

    return Drawer(
      width: MediaQuery.of(context).size.width / 2,
      child: Column(
        children: [
          AppBar(
            title: const Text('bloc'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.crop_square_sharp),
            title: const Text('home'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (ctx) => MainScreen(
                          user: UserPreferences.getUser(),
                        )),
              );
            },
          ),
          const Divider(),
          UserPreferences.isUserLoggedIn()
              ? Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.circle_outlined),
                      title: const Text('orders'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => OrderHistoryScreen()),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                )
              : const SizedBox(),
          UserPreferences.isUserLoggedIn()
              ? Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.play_arrow_outlined),
                      title: const Text('box office'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => BoxOfficeScreen()),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                )
              : const SizedBox(),
          user.clearanceLevel >= Constants.CAPTAIN_LEVEL
              ? Column(children: [
                  ListTile(
                    leading: const Icon(Icons.adjust),
                    title: const Text('captain'),
                    onTap: () {
                      Logx.i(_TAG, 'captain of bloc id : ' + user.blocServiceId);

                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (ctx) => CaptainMainScreen(
                                  blocServiceId: user.blocServiceId,
                                )),
                      );
                    },
                  ),
                  const Divider(),
                ])
              : const SizedBox(),
          user.clearanceLevel >= Constants.MANAGER_LEVEL
              ? Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_circle_outlined),
                      title: const Text('manager'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => ManagerMainScreen()),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                )
              : const SizedBox(),
          user.clearanceLevel >= Constants.OWNER_LEVEL
              ? Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.play_circle_outlined),
                      title: const Text('owner'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => OwnerScreen()),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                )
              : const SizedBox(),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'v1.4.3',
                  style: TextStyle(fontSize: 14),
                )),
          ),
          UserPreferences.isUserLoggedIn()
              ? Column(
                  children: [
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('account'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => AccountScreen()),
                        );
                      },
                    ),
                  ],
                )
              : const SizedBox(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: Text(UserPreferences.isUserLoggedIn() ? 'logout' : 'login'),
            onTap: () async {
              UserPreferences.resetUser();

              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen(shouldTriggerSkip: false,)),
              );
            },
          ),
        ],
      ),
    );
  }
}
