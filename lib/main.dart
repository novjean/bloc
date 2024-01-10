import 'dart:ui';

import 'package:bloc/db/shared_preferences/party_guest_preferences.dart';
import 'package:bloc/db/shared_preferences/table_preferences.dart';
import 'package:bloc/routes/bloc_router.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;


import 'package:bloc/db/shared_preferences/ui_preferences.dart';
import 'package:bloc/routes/route_constants.dart';
import 'package:bloc/screens/login_screen.dart';
import 'package:bloc/screens/main_screen.dart';
import 'package:bloc/services/firebase_api.dart';
import 'package:bloc/utils/logx.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'db/shared_preferences/user_preferences.dart';
import 'firebase_options.dart';
import 'helpers/firestore_helper.dart';
import 'helpers/fresh.dart';
import 'providers/cart.dart';
import 'utils/constants.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

const bool kIsWeb = identical(0, 0.0);
late Size mq;

Future<void> main() async {
  const String _TAG = 'main';

  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // shared preferences initialization
  await UserPreferences.init();
  await UiPreferences.init();
  await TablePreferences.init();
  await PartyGuestPreferences.init();

  // disabling landscape until all ui issues are resolved
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(const BlocApp());
  });
}

//
// final GoRouter _router = GoRouter(
//   initialLocation: '/',
//   routes: <RouteBase>[
//     GoRoute(
//       name: RouteConstants.landingRouteName,
//       path: '/',
//       builder: (BuildContext context, GoRouterState state) {
//
//         Logx.ist('router', '${RouteConstants.landingRouteName}');
//
//         return StreamBuilder(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (ctx, userSnapshot) {
//             Logx.i('router', 'checking for auth state changes...');
//
//             switch (userSnapshot.connectionState) {
//               case ConnectionState.waiting:
//               case ConnectionState.none:
//                 {
//                   return const LoadingWidget();
//                   // if (!kIsWeb) {
//                   //   return SplashScreen();
//                   // } else {
//                   //   return const LoadingWidget();
//                   // }
//                 }
//               case ConnectionState.active:
//               case ConnectionState.done:
//                 {
//                   if (userSnapshot.hasData) {
//                     final user = FirebaseAuth.instance.currentUser;
//                     CollectionReference users =
//                     FirestoreHelper.getUsersCollection();
//
//                     return FutureBuilder<DocumentSnapshot>(
//                       future: users.doc(user!.uid).get(),
//                       builder: (BuildContext ctx,
//                           AsyncSnapshot<DocumentSnapshot> snapshot) {
//                         switch (snapshot.connectionState) {
//                           case ConnectionState.waiting:
//                           case ConnectionState.none:
//                             return const LoadingWidget();
//                           case ConnectionState.active:
//                           case ConnectionState.done:
//                             {
//                               if (snapshot.hasError) {
//                                 Logx.em('router',
//                                     'user snapshot has error: ${snapshot.error}');
//                                 return const LoginScreen(
//                                     shouldTriggerSkip: false);
//                               } else if (snapshot.hasData &&
//                                   !snapshot.data!.exists) {
//                                 Logx.i('router',
//                                     'user snapshot has data but not registered in bloc ');
//                                 // user not registered in bloc, will be picked up in OTP screen
//                                 return const LoginScreen(
//                                     shouldTriggerSkip: false);
//                               } else {
//                                 Map<String, dynamic> data = snapshot.data!
//                                     .data() as Map<String, dynamic>;
//                                 final blocUser.User user = Fresh.freshUserMap(data, true);
//                                 UserPreferences.setUser(user);
//
//                                 return const MainScreen();
//                               }
//                             }
//                         }
//                       },
//                     );
//                   } else {
//                     return const LoginScreen(
//                       shouldTriggerSkip: true,
//                     );
//                   }
//                 }
//             }
//           },
//         );
//         // return LoginScreen(shouldTriggerSkip: false);
//       },
//       routes: <RouteBase>[
//       ],
//     ),
//     GoRoute(
//       name: RouteConstants.loginRouteName,
//       path: '/login/:skip',
//       builder: (BuildContext context, GoRouterState state) {
//         String skipString = state.pathParameters['skip']!;
//
//         Logx.ist('bloc_router', 'bloc router: login/:skip ${skipString}');
//
//         bool val = false;
//         if (skipString == 'true') {
//           val = true;
//         } else {
//           val = false;
//         }
//
//         return LoginScreen(shouldTriggerSkip: val);
//       },
//     ),
//   ],
// );

class BlocApp extends StatefulWidget {
  const BlocApp({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<BlocApp> createState() => _BlocAppState();
}

class _BlocAppState extends State<BlocApp> {
  static const String _TAG = 'BlocApp';

  @override
  Widget build(BuildContext context) {
    Logx.i(_TAG, 'bloc app starts');

    final Future<FirebaseApp> initFirebase = Firebase.initializeApp();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
      ],
      child: FutureBuilder(
          // Initialize FlutterFire:
          future: initFirebase,
          builder: (ctx, appSnapshot) {
            switch (appSnapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const LoadingWidget();
              case ConnectionState.active:
              case ConnectionState.done:
                {
                  Logx.i(_TAG, 'firebase initialized');

                  return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    title: kAppTitle,
                    theme: ThemeData(
                      primaryColor: Constants.primary,
                      primaryColorLight: Constants.lightPrimary,
                      primaryColorDark: Constants.darkPrimary,

                      backgroundColor: Constants.background,
                      shadowColor: const Color.fromRGBO(158, 158, 158, 1.0),

                      highlightColor: const Color.fromRGBO(255, 255, 255, 1.0),
                      bottomAppBarColor:
                          const Color.fromRGBO(255, 255, 255, 1.0),

                      // app bar and buttons by default
                      primarySwatch: Colors.brown,
                      fontFamily: Constants.fontDefault,

                      buttonTheme: ButtonTheme.of(context).copyWith(
                        buttonColor: Colors.red,
                        textTheme: ButtonTextTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    routerConfig: BlocRouter.returnRouter(true),

                    // routeInformationProvider: BlocRouter.returnRouter(true).routeInformationProvider,
                    // routeInformationParser:
                    //     BlocRouter.returnRouter(true).routeInformationParser,
                    // routerDelegate:
                    //     BlocRouter.returnRouter(true).routerDelegate,
                  );
                }
            }
          }),
    );
  }
}
