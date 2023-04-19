import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../db/shared_preferences/user_preferences.dart';
import '../login_screen.dart';

class ProfileLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: ButtonWidget(
            text: 'login',
            onClicked: () async {
              UserPreferences.resetUser();

              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen(shouldTriggerSkip: false,)),
              );
            }),
      ),
    );
  }
}
