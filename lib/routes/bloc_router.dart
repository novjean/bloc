import 'package:bloc/screens/account_screen.dart';
import 'package:bloc/screens/bloc/bloc_menu_screen.dart';
import 'package:bloc/screens/box_office/box_office_screen.dart';
import 'package:bloc/screens/main_screen.dart';
import 'package:bloc/screens/parties/event_screen.dart';
import 'package:bloc/screens/refund_policy_screen.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../db/shared_preferences/user_preferences.dart';
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
import '../utils/logx.dart';
import 'route_constants.dart';

class BlocRouter {
  static const String _TAG = 'BlocRouter';

  static GoRouter returnRouter(bool isAuth) {
    GoRouter router = GoRouter(
        navigatorKey: GlobalKey<NavigatorState>(),
        // redirectLimit: 100,
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          name: RouteConstants.landingRouteName,
          path: '/',
          builder: (context, state) {
            // Logx.ist(_TAG, 'bloc router: ${RouteConstants.landingRouteName}');
            if(UserPreferences.myUser.phoneNumber == 0) {
              return LoginScreen(shouldTriggerSkip: false,);
            } else if(UserPreferences.myUser.phoneNumber == 1){
              return LoginScreen(shouldTriggerSkip: true,);
            } else {
              return const MainScreen();
            }
            },
        ),

        GoRoute(
          name: RouteConstants.loginRouteName,
          path: '/login',
          pageBuilder: (context, state) {

            // Logx.ist(_TAG, 'bloc router: event');

            return const MaterialPage(child: Scaffold(body: LoadingWidget(),)
            );
          },routes: [
          GoRoute(
            path: ':skip',
            pageBuilder: (context, state) {
              String skipString = state.pathParameters['skip']!;

              // Logx.ist(_TAG, 'bloc router: login/:skip ${skipString}');

              bool val = false;
              if (skipString == 'true') {
                val = true;
              } else {
                val = false;
              }

              return MaterialPage(child: LoginScreen(shouldTriggerSkip: val));
            },
          ),
        ],
        ),


        GoRoute(
          name: RouteConstants.eventRouteName,
          path: '/event',
          pageBuilder: (context, state) {

            // Logx.ist(_TAG, 'bloc router: event');

            return const MaterialPage(
                child: Scaffold(body: LoadingWidget(),)
            );
          },routes: [
          GoRoute(
            path: ':partyName/:partyChapter',
            pageBuilder: (context, state) {

              // Logx.ist(_TAG, 'bloc router: event/:partyName/:partyChapter');

              String partyName = state.pathParameters['partyName']!;
              String partyChapter = state.pathParameters['partyChapter']!;

              return MaterialPage(
                child: EventScreen(
                  partyName: partyName,
                  partyChapter: partyChapter,
                )
              );
            },
          ),
        ],
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
            String name = state.pathParameters['name']!;
            String genre = state.pathParameters['genre']!;

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
            String id = state.pathParameters['id']!;

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
              blocId: state.pathParameters['id']!,
            ));
          },
        ),

        GoRoute(
          name: RouteConstants.profileRouteName,
          path: '/profile/:username',
          pageBuilder: (context, state) {
            // Logx.ist(_TAG, 'bloc router: /profile/:${state.pathParameters['username']}');

            return MaterialPage(
                child: UserProfileScreen(
              username: state.pathParameters['username']!,
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
