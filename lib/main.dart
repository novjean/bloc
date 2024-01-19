import 'dart:ui';

import 'package:bloc/db/shared_preferences/party_guest_preferences.dart';
import 'package:bloc/db/shared_preferences/table_preferences.dart';
import 'package:bloc/routes/bloc_router.dart';

import 'package:bloc/db/shared_preferences/ui_preferences.dart';
import 'package:bloc/services/firebase_api.dart';
import 'package:bloc/utils/logx.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'db/entity/user.dart' as blocUser;
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
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );

  await FirebaseApi().initNotifications();

  // Listen for Auth changes and .refresh the GoRouter [router]
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    FirestoreHelper.pullUser(user!.uid).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

        final blocUser.User mUser = Fresh.freshUserMap(data, false);
        // UserPreferences.setUser(mUser);
        //
        Logx.dst(_TAG, 'main: auth state change. user ${mUser.name}');
        //
        // BlocRouter.returnRouter(true).refresh();
      } else {
        Logx.em(_TAG, 'user not found');
      }
    });
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

                      textTheme: TextTheme(
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
          }),
    );
  }
}
