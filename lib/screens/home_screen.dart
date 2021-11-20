import 'package:bloc/widgets/app_drawer.dart';
import 'package:bloc/widgets/display_image_box.dart';
import 'package:bloc/widgets/map/location_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final int mClearanceLevel;

  const HomeScreen(this.mClearanceLevel, {key}) : super(key: key);

  // void loadUser(String uid) async {
  //   final userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  //   int clearanceLevel =  userData.data()['clearance_level'];
  // }

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    // loadUser(user.uid);

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
              }
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LocationInput(null),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Center(
              child: Text('Welcome to BLOC!'),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          mClearanceLevel > 5
              ? DisplayImageBox(
                  'manager', 'assets/images/textblock-manager.png')
              : SizedBox(
                  height: 10,
                ),
          mClearanceLevel > 7
              ? DisplayImageBox('owner', 'assets/images/textblock-owner.png')
              : SizedBox(
                  height: 10,
                ),
        ],
      ),
    );
  }
}
