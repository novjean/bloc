import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/screens/account_screen.dart';
import 'package:bloc/screens/bloc/bloc_menu_screen.dart';
import 'package:bloc/screens/box_office/box_office_screen.dart';
import 'package:bloc/screens/main_screen.dart';
import 'package:bloc/screens/parties/event_screen.dart';
import 'package:bloc/screens/refund_policy_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bloc/db/entity/user.dart' as blocUser;

import '../db/shared_preferences/ui_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../screens/sample_checkout_screen.dart';
import '../screens/contact_us_screen.dart';
import '../screens/delivery_policy_screen.dart';
import '../screens/error_page.dart';
import '../screens/login_screen.dart';
import '../screens/lounge/lounge_chat_screen.dart';
import '../screens/parties/artist_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import '../screens/reservation/reservation_screen.dart';
import '../screens/support/support_screen.dart';
import '../screens/terms_and_conditions_screen.dart';
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
            Logx.ist(_TAG, 'bloc router: ${RouteConstants.landingRouteName}');

            try {
              if(UiPreferences.getRoute() == RouteConstants.eventRouteName){
                Logx.ist(_TAG, 'bloc router: route selected: ${UiPreferences.getRoute()}');

                String eventName = UiPreferences.getEventName();
                String eventChapter = UiPreferences.getEventChapter();

                String partyName = state.params['partyName']!;
                String partyChapter = state.params['partyChapter']!;

                Logx.ist(_TAG, 'bloc router: landing: /event/:$partyName/:$partyChapter');

                UiPreferences.setRoute('');

                return EventScreen(
                  partyName: eventName,
                  partyChapter: eventChapter,
                );
              }
            } catch (e) {
              Logx.em(_TAG, e.toString());
            }

            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                Logx.i(_TAG, 'checking for auth state changes...');

                switch (userSnapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    {
                      return const LoadingWidget();
                      // if (!kIsWeb) {
                      //   return SplashScreen();
                      // } else {
                      //   return const LoadingWidget();
                      // }
                    }
                  case ConnectionState.active:
                  case ConnectionState.done:
                    {
                      if (userSnapshot.hasData) {
                        final user = FirebaseAuth.instance.currentUser;
                        CollectionReference users =
                        FirestoreHelper.getUsersCollection();

                        return FutureBuilder<DocumentSnapshot>(
                          future: users.doc(user!.uid).get(),
                          builder: (BuildContext ctx,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const LoadingWidget();
                              case ConnectionState.active:
                              case ConnectionState.done:
                                {
                                  if (snapshot.hasError) {
                                    Logx.em(_TAG,
                                        'user snapshot has error: ${snapshot.error}');
                                    return const LoginScreen(
                                        shouldTriggerSkip: false);
                                  } else if (snapshot.hasData &&
                                      !snapshot.data!.exists) {
                                    Logx.i(_TAG,
                                        'user snapshot has data but not registered in bloc ');
                                    // user not registered in bloc, will be picked up in OTP screen
                                    return const LoginScreen(
                                        shouldTriggerSkip: false);
                                  } else {
                                    Map<String, dynamic> data = snapshot.data!
                                        .data() as Map<String, dynamic>;
                                    final blocUser.User user = Fresh.freshUserMap(data, true);
                                    UserPreferences.setUser(user);

                                    return const MainScreen();
                                  }
                                }
                            }
                          },
                        );
                      } else {
                        return const LoginScreen(
                          shouldTriggerSkip: true,
                        );
                      }
                    }
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

            Logx.d(_TAG, '/login/:skip ${skipString}');
            Logx.ist(_TAG, 'bloc router: login/:skip ${skipString}');

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
            Logx.d(_TAG, '/home');
            Logx.ist(_TAG, 'bloc router: /home');

            return const MainScreen();
          },
        ),
        GoRoute(
          name: RouteConstants.accountRouteName,
          path: '/account',
          builder: (context, state) {
            Logx.d(_TAG, '/account');

            return AccountScreen();
          },
        ),
        GoRoute(
          name: RouteConstants.contactRouteName,
          path: '/contact',
          builder: (context, state) {
            Logx.d(_TAG, '/contact');

            return ContactUsScreen();
          },
        ),
        GoRoute(
          name: RouteConstants.termsAndConditionsRouteName,
          path: '/t&c',
          builder: (context, state) {
            Logx.d(_TAG, '/t&c');

            return TermsAndConditionsScreen();
          },
        ),
        GoRoute(
          name: RouteConstants.privacyRouteName,
          path: '/privacy',
          builder: (context, state) {
            Logx.d(_TAG, '/privacy');

            return PrivacyPolicyScreen();
          },
        ),
        GoRoute(
          name: RouteConstants.deliveryRouteName,
          path: '/delivery',
          builder: (context, state) {
            Logx.d(_TAG, '/delivery');

            return DeliveryPolicyScreen();
          },
        ),
        GoRoute(
          name: RouteConstants.refundRouteName,
          path: '/refund_and_cancellation',
          builder: (context, state) {
            Logx.d(_TAG, '/refund_and_cancellation');

            return RefundPolicyScreen();
          },
        ),
        GoRoute(
          name: RouteConstants.checkoutRouteName,
          path: '/checkout',
          builder: (context, state) {
            Logx.d(_TAG, '/checkout');

            return SampleCheckoutScreen();
          },
        ),
        GoRoute(
          name: RouteConstants.eventRouteName,
          path: '/event/:partyName/:partyChapter',
          pageBuilder: (context, state) {

            String partyName = state.params['partyName']!;
            String partyChapter = state.params['partyChapter']!;

            try {
              UiPreferences.setRoute(RouteConstants.eventRouteName);
              UiPreferences.setEventName(partyName);
              UiPreferences.setEventChapter(partyChapter);

              Logx.ist(_TAG, 'router: event route selected. event: $partyName');
            } catch (e){
              Logx.em(_TAG, e.toString());
            }

            // Logx.ist(_TAG, 'bloc router: /event/:$partyName/:$partyChapter');

            return MaterialPage(
                child: EventScreen(
              partyName: partyName,
              partyChapter: partyChapter,
            ));
          },
        ),

        // GoRoute(
        //   name: RouteConstants.buyTixRouteName,
        //   path: '/tix/:partyId',
        //   pageBuilder: (context, state) {
        //     String partyId = state.params['partyId']!;
        //
        //     Logx.d(_TAG, '/tix/:$partyId');
        //
        //     return MaterialPage(
        //         child: TixBuyEditScreen(
        //           partyId: partyId,
        //           task: 'buy',
        //         ));
        //   },
        // ),

        GoRoute(
          name: RouteConstants.artistRouteName,
          path: '/artist/:genre/:name',
          pageBuilder: (context, state) {
            String name = state.params['name']!;
            String genre = state.params['genre']!;

            Logx.d(_TAG, '/artist/:$genre/:$name');

            return MaterialPage(
                child: ArtistScreen(
              name: name,
              genre: genre,
            ));
          },
        ),
        GoRoute(
          name: RouteConstants.loungeRouteName,
          path: '/lounge/:id',
          pageBuilder: (context, state) {
            String id = state.params['id']!;

            Logx.d(_TAG, '/lounge/$id');

            return MaterialPage(
                child: LoungeChatScreen(
              loungeId: id,
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
          name: RouteConstants.profileRouteName,
          path: '/profile/:username',
          pageBuilder: (context, state) {
            Logx.ist(_TAG, 'bloc router: /profile/:${state.params['username']}');

            return MaterialPage(
                child: UserProfileScreen(
              username: state.params['username']!,
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

        GoRoute(
          name: RouteConstants.reservationRouteName,
          path: '/reservation',
          pageBuilder: (context, state) {
            return MaterialPage(child: ReservationScreen());
          },
        ),

        GoRoute(
          name: RouteConstants.supportRouteName,
          path: '/support',
          pageBuilder: (context, state) {
            return MaterialPage(child: SupportScreen());
          },
        ),
        GoRoute(
          name: RouteConstants.errorRouteName,
          path: '/error',
          pageBuilder: (context, state) {
            return MaterialPage(child: ErrorPage());
          },
        ),
      ],
      errorPageBuilder: (context, state) {
        return MaterialPage(child: ErrorPage());
      },
        initialLocation: '/'
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
