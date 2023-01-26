import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/screens/main_screen.dart';
import 'package:bloc/screens/manager/manager_main_screen.dart';
import 'package:bloc/screens/owner/owner_screen.dart';
import 'package:bloc/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/captain/captain_main_screen.dart';
import '../screens/login_screen.dart';
import '../screens/user/order_history_screen.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = UserPreferences.getUser();

    return Drawer(
      width: 240,
      child: Column(
        children: [
          AppBar(
            title: const Text('bloc'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy_sharp),
            title: const Text('home'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (ctx) => MainScreen(
                          user: UserPreferences.getUser(),
                        )),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('orders'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (ctx) => OrderHistoryScreen()),
              );
            },
          ),
          const Divider(),
          user.clearanceLevel > Constants.CAPTAIN_LEVEL
              ? ListTile(
                  leading: const Icon(Icons.adjust),
                  title: const Text('captain'),
                  onTap: () {
                    print('captain of bloc id : ' + user.blocServiceId);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) => CaptainMainScreen(
                                blocServiceId: user.blocServiceId,
                              )),
                    );
                  },
                )
              : const SizedBox.shrink(),
          const Divider(),
          user.clearanceLevel > Constants.MANAGER_LEVEL
              ? ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('manager'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) => ManagerMainScreen()),
                    );
                  },
                )
              : const SizedBox.shrink(),
          const Divider(),
          user.clearanceLevel > Constants.OWNER_LEVEL
              ? ListTile(
                  leading: const Icon(Icons.play_circle_outlined),
                  title: const Text('owner'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) => OwnerScreen()),
                    );
                  },
                )
              : const SizedBox.shrink(),
          const Divider(),
          Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('logout'),
            onTap: () {
              UserPreferences.resetUser();

              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
