import 'dart:ui';

import 'package:bloc/db/shared_preferences/party_guest_preferences.dart';
import 'package:bloc/db/shared_preferences/table_preferences.dart';
import 'package:bloc/routes/bloc_router.dart';

import 'package:bloc/db/shared_preferences/ui_preferences.dart';
import 'package:bloc/services/firebase_api.dart';
import 'package:bloc/utils/logx.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
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

  // Listen for Auth changes and .refresh the GoRouter [router]
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    Logx.ist(_TAG, 'main: firebase auth state change, refreshing router');

    BlocRouter.returnRouter(true).refresh();
  });

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
                  );
                }
            }
          }),
    );
  }
}
