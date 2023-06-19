import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/shared_preferences/user_preferences.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../login_screen.dart';

class ProfileLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Attention, human! Access to the realm of wonders requires proper authentication. Please login and let the magic unfold! ✨'.toLowerCase(),
                style: TextStyle(fontSize: 22, color: Constants.primary,),
              ),
              const SizedBox(height: 16),
              Text(
                'click below to login!'.toLowerCase(),
                style: TextStyle(fontSize: 16, color: Constants.primary),
              ),
              const SizedBox(height: 16),
              ButtonWidget(
                height: 50,
                text:  'login',
                onClicked: () async {
                  UserPreferences.resetUser();

                  await FirebaseAuth.instance.signOut();

                  GoRouter.of(context)
                      .pushNamed(RouteConstants.loginRouteName, params: {
                    'skip': 'false',
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
