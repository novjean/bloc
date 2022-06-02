import 'package:bloc/screens/main_screen.dart';
import 'package:bloc/screens/manager/manager_main_screen.dart';
import 'package:bloc/screens/owner/owner_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../main.dart';

class AppDrawer extends StatelessWidget {
  final BlocDao dao;

  AppDrawer({key, required this.dao}) : super(key: key);

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
                MainScreen.routeName,
              );
            },
          ),
          const Divider(),
          MyApp.mClearanceLevel > 5
              ? ListTile(
                  leading: const Icon(Icons.adjust),
                  title: const Text('Manager'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) => ManagerMainScreen(dao:dao)),
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
                      arguments: dao,
                    );
                  },
                )
              : const SizedBox.shrink(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
