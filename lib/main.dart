import 'dart:ui';

import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'db/shared_preferences/user_preferences.dart';
import 'firebase_options.dart';
import 'providers/cart.dart';
import 'screens/ui/splash_screen.dart';
import 'utils/constants.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

/// A constant that is true if the application was compiled to run on the web.
///
/// This implementation takes advantage of the fact that JavaScript does not
/// support integers. In this environment, Dart's doubles and ints are
/// backed by the same kind of object. Thus a double `0.0` is identical
/// to an integer `0`. This is not true for Dart code running in AOT or on the
/// VM.
const bool kIsWeb = identical(0, 0.0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      // 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // disabling landscape until all ui issues are resolved
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await UserPreferences.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
      ],
      child: FutureBuilder(
          // Initialize FlutterFire:
          future: _initialization,
          builder: (ctx, appSnapshot) {
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: kAppTitle,
                theme: ThemeData(
                  //rgba(211,167,130,255)
                  primaryColor: const Color.fromRGBO(211,167,130,1),
                    // 222,193,170
                  primaryColorLight: const Color.fromRGBO(222,193,170,1),
                  primaryColorDark: const Color.fromRGBO(42,33,26,1),

                  backgroundColor: const Color.fromRGBO(38, 50, 56, 1.0),
                  focusColor: const Color.fromRGBO(31, 31, 33, 1.0),
                  shadowColor: const Color.fromRGBO(158, 158, 158, 1.0),

                  highlightColor: const Color.fromRGBO(255, 255, 255, 1.0),
                  bottomAppBarColor: const Color.fromRGBO(255, 255, 255, 1.0),

                  // app bar and buttons by default
                  primarySwatch: Colors.brown,

                  accentColor: Colors.grey,
                  accentColorBrightness: Brightness.dark,
                  buttonTheme: ButtonTheme.of(context).copyWith(
                    buttonColor: Colors.red,
                    textTheme: ButtonTextTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                home: appSnapshot.connectionState != ConnectionState.done
                    ? SplashScreen()
                    : LoginScreen(),

                // routes: {
                // HomeScreen.routeName: (ctx) => HomeScreen(),
                // ManagerScreen.routeName: (ctx) => ManagerScreen(),
                // OwnerScreen.routeName: (ctx) => OwnerScreen(),
                // CityDetailScreen.routeName: (ctx) => CityDetailScreen(),
                // NewBlocScreen.routeName: (ctx) => NewBlocScreen(),
                // BlocDetailScreen.routeName: (ctx) => BlocDetailScreen(),
                // }
                );
          }),
    );
  }

}

