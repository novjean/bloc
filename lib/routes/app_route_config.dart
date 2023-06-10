import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/screens/home_screen.dart';
import 'package:bloc/screens/main_screen.dart';
import 'package:bloc/screens/parties/event_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/about.dart';
import '../pages/contact_us.dart';
import '../pages/error_page.dart';
import '../pages/home.dart';
import '../pages/profile.dart';
import '../screens/login_screen.dart';
import 'app_route_constants.dart';

class BlocRouter{

  static GoRouter returnRouter(bool isAuth) {
    GoRouter router = GoRouter(
      routes: [
        GoRoute(
          name: MyAppRouteConstants.landingRouteName,
          path: '/',
          pageBuilder: (context, state) {
            if(UserPreferences.isUserLoggedIn()){
              return MaterialPage(child: MainScreen());
            } else {
              return MaterialPage(child: LoginScreen(shouldTriggerSkip: false,));
            }
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
            return MaterialPage(child: MainScreen());
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

        GoRoute(
          name: MyAppRouteConstants.profileRouteName,
          path: '/profile/:username/:userid',
          pageBuilder: (context, state) {
            return MaterialPage(
                child: Profile(
                  userid: state.params['userid']!,
                  username: state.params['username']!,
                ));
          },
        ),
        GoRoute(
          name: MyAppRouteConstants.aboutRouteName,
          path: '/about',
          pageBuilder: (context, state) {
            return MaterialPage(child: About());
          },
        ),
        GoRoute(
          name: MyAppRouteConstants.contactUsRouteName,
          path: '/contact_us',
          pageBuilder: (context, state) {
            return MaterialPage(child: ContactUS());
          },
        )
      ],
      errorPageBuilder: (context, state) {
        return MaterialPage(child: ErrorPage());
      },
      redirect: (context, state) {
        if (!isAuth &&
            state.location
                .startsWith('/${MyAppRouteConstants.profileRouteName}')) {
          return context.namedLocation(MyAppRouteConstants.contactUsRouteName);
        } else {
          return null;
        }
      },
    );
    return router;
  }

}