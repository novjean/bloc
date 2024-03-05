import 'dart:ui';

import 'package:bloc/db/shared_preferences/party_guest_preferences.dart';
import 'package:bloc/routes/bloc_router.dart';

import 'package:bloc/db/shared_preferences/ui_preferences.dart';
import 'package:bloc/services/firebase_api.dart';
import 'package:bloc/utils/logx.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'db/shared_preferences/table_preferences.dart';
import 'db/shared_preferences/user_preferences.dart';
import 'firebase_options.dart';
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

  // Only call clearSavedSettings() during testing to reset internal values.
  // await Upgrader.clearSavedSettings(); // REMOVE this for release builds

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('6Lc_XlYpAAAAAMf1fEA7WkNQBleWV48l1vXRb0Dx'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  if (!kIsWeb) {
    await FirebaseApi().initNotifications();

    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }

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

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Constants.darkPrimary, fontFamily: Constants.fontDefault),
          bodyMedium: TextStyle(color: Constants.darkPrimary, fontFamily: Constants.fontDefault),
          bodySmall: TextStyle(color: Constants.darkPrimary, fontFamily: Constants.fontDefault),
          labelLarge: TextStyle(color: Constants.darkPrimary, fontFamily: Constants.fontDefault),
          labelMedium: TextStyle(color: Constants.darkPrimary, fontFamily: Constants.fontDefault),
          labelSmall: TextStyle(color: Constants.darkPrimary, fontFamily: Constants.fontDefault),
          // You can customize other text styles as well
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Constants.darkPrimary,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: Constants.lightPrimary,
              foregroundColor: Constants.darkPrimary
          ),
        ),
      ),
      routerConfig: BlocRouter.returnRouter(true),
    );
  }
}
