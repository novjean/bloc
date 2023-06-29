import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/shared_preferences/user_preferences.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';

class ProfileLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'attention, human! access to the realm of wonders requires proper authentication. please login and let the magic unfold! ✨',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, color: Constants.primary,),
              ),
              const SizedBox(height: 16),
              const Text(
                'click below to login!',
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
