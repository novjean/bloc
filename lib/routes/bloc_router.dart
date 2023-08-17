import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/screens/bloc/bloc_menu_screen.dart';
import 'package:bloc/screens/box_office/box_office_screen.dart';
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
import '../screens/lounge/lounge_chat_screen.dart';
import '../screens/parties/artist_screen.dart';
import '../screens/ui/splash_screen.dart';
import '../utils/logx.dart';
import '../widgets/ui/loading_widget.dart';
import 'route_constants.dart';

class BlocRouter {
  static const String _TAG = 'BlocRouter';

  static GoRouter returnRouter(bool isAuth) {
    GoRouter router = GoRouter(
      navigatorKey: BlocApp.navigatorKey,
      routes: [
        GoRoute(
          name: RouteConstants.landingRouteName,
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
                  CollectionReference users =
                      FirestoreHelper.getUsersCollection();

                  return FutureBuilder<DocumentSnapshot>(
                    future: users.doc(user!.uid).get(),
                    builder: (BuildContext ctx,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingWidget();
                      }

                      if (snapshot.hasError) {
                        Logx.em(
                            _TAG, 'user snapshot has error: ${snapshot.error}');
                        return const LoginScreen(shouldTriggerSkip: false);
                      }

                      if (snapshot.hasData && !snapshot.data!.exists) {
                        Logx.i(_TAG,
                            'user snapshot has data but not registered in bloc ');
                        // user not registered in bloc, will be picked up in OTP screen
                        return const LoginScreen(shouldTriggerSkip: false);
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final blocUser.User user =
                            Fresh.freshUserMap(data, true);
                        UserPreferences.setUser(user);

                        return const MainScreen();
                      }
                      return const LoadingWidget();
                    },
                  );
                } else {
                  return const LoginScreen(
                    shouldTriggerSkip: true,
                  );
                }
              },
            );
          },
        ),
        GoRoute(
          name: RouteConstants.loginRouteName,
          path: '/login/:skip',
          pageBuilder: (context, state) {
            String skipString = state.params['skip']!;

            bool val = false;
            if (skipString == 'true') {
              val = true;
            } else {
              val = false;
            }

            return MaterialPage(child: LoginScreen(shouldTriggerSkip: val));
          },
        ),
        GoRoute(
          name: RouteConstants.homeRouteName,
          path: '/home',
          builder: (context, state) {
            return MainScreen();
          },
        ),
        GoRoute(
          name: RouteConstants.eventRouteName,
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
          name: RouteConstants.artistRouteName,
          path: '/artist/:genre/:name',
          pageBuilder: (context, state) {
            return MaterialPage(
                child: ArtistScreen(
              name: state.params['name']!,
              genre: state.params['genre']!,
            ));
          },
        ),
        GoRoute(
          name: RouteConstants.loungeRouteName,
          path: '/lounge/:id',
          pageBuilder: (context, state) {
            return MaterialPage(
                child: LoungeChatScreen(
              loungeId: state.params['id']!,
            ));
          },
        ),
        GoRoute(
          name: RouteConstants.menuRouteName,
          path: '/menu/:id',
          pageBuilder: (context, state) {
            return MaterialPage(
                child: BlocMenuScreen(
              blocId: state.params['id']!,
            ));
          },
        ),
        GoRoute(
          name: RouteConstants.boxOfficeRouteName,
          path: '/box_office',
          pageBuilder: (context, state) {
            return MaterialPage(child: BoxOfficeScreen());
          },
        ),
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
