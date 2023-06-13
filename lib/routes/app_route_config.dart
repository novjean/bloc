import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/screens/main_screen.dart';
import 'package:bloc/screens/parties/event_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bloc/db/entity/user.dart' as blocUser;

import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../screens/error_page.dart';
import '../screens/login_screen.dart';
import '../screens/ui/splash_screen.dart';
import '../utils/logx.dart';
import '../widgets/ui/loading_widget.dart';
import 'app_route_constants.dart';

class BlocRouter{
  static const String _TAG = 'BlocRouter';

  static GoRouter returnRouter(bool isAuth) {
    GoRouter router = GoRouter(
      routes: [
        GoRoute(
          name: MyAppRouteConstants.landingRouteName,
          path: '/',
          builder: (context, state) {

            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                Logx.i(_TAG, 'checking for auth state changes...');

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  if (!kIsWeb) {
                    return SplashScreen();
                  } else {
                    return const LoadingWidget();
                  }
                }

                if (userSnapshot.hasData) {
                  final user = FirebaseAuth.instance.currentUser;
                  CollectionReference users = FirestoreHelper.getUsersCollection();

                  return FutureBuilder<DocumentSnapshot>(
                    future: users.doc(user!.uid).get(),
                    builder: (BuildContext ctx,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingWidget();
                      }

                      if (snapshot.hasError) {
                        Logx.em(_TAG, 'user snapshot has error: ${snapshot.error}');
                        return LoginScreen(shouldTriggerSkip: false);
                      }

                      if (snapshot.hasData && !snapshot.data!.exists) {
                        Logx.i(_TAG,
                            'user snapshot has data but not registered in bloc ');
                        // user not registered in bloc, will be picked up in OTP screen
                        return LoginScreen(shouldTriggerSkip: false);
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                        final blocUser.User user = Fresh.freshUserMap(data, true);
                        UserPreferences.setUser(user);

                        return MainScreen();
                      }
                      // Logx.i(_TAG, 'loading user...');
                      return const LoadingWidget();
                    },
                  );
                } else {
                  return LoginScreen(shouldTriggerSkip: true,);
                }
              },
            );

            // return LoadingWidget();
          },
        ),
        GoRoute(
          name: MyAppRouteConstants.loginRouteName,
          path: '/login/:skip',
          pageBuilder: (context, state) {
            String skipString = state.params['skip']!;

            bool val = false;
            if(skipString == 'true'){
              val = true;
            } else {
              val = false;
            }

            return MaterialPage(child: LoginScreen(
                shouldTriggerSkip: val
            ));
          },
        ),

        GoRoute(
          name: MyAppRouteConstants.homeRouteName,
          path: '/home',
          pageBuilder: (context, state) {
            return const MaterialPage(child: MainScreen());
          },
        ),

        GoRoute(
          name: MyAppRouteConstants.eventRouteName,
          path: '/event/:partyName/:partyChapter',
          pageBuilder: (context, state) {
            return MaterialPage(
                child: EventScreen(
                  partyName: state.params['partyName']!,
                  partyChapter: state.params['partyChapter']!,
                ));
          },
        ),

        // GoRoute(
        //   name: MyAppRouteConstants.eventRouteName,
        //   path: '/artist/:genre/:name',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(
        //         child: ArtistScreen(
        //           partyName: state.params['partyName']!,
        //           partyChapter: state.params['partyChapter']!,
        //         ));
        //   },
        // ),
      ],
      errorPageBuilder: (context, state) {
        return MaterialPage(child: ErrorPage());
      },
      // redirect: (context, state) {
      //   if (!isAuth &&
      //       state.location
      //           .startsWith('/${MyAppRouteConstants.profileRouteName}')) {
      //     return context.namedLocation(MyAppRouteConstants.contactUsRouteName);
      //   } else {
      //     return null;
      //   }
      // },
    );
    return router;
  }

}