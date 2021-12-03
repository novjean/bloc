import 'package:bloc/screens/home_screen.dart';
import 'package:bloc/screens/manager_screen.dart';
import 'package:bloc/screens/owner_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('BLOC'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy_sharp),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushNamed(
                HomeScreen.routeName,
              );
            },
          ),
          const Divider(),
          MyApp.mClearanceLevel > 5
              ? ListTile(
                  leading: const Icon(Icons.adjust),
                  title: const Text('Manager'),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ManagerScreen.routeName,
                    );
                  },
                )
              : const SizedBox.shrink(),
          const Divider(),
          MyApp.mClearanceLevel > 5
              ? ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Owner'),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      OwnerScreen.routeName,
                    );
                  },
                )
              : const SizedBox.shrink(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              // the following line ensures that the home is what is the screen when app is opened
              Navigator.of(context).pushReplacementNamed('/');
              FirebaseAuth.instance.signOut();
              // Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
