import 'dart:ui';

import 'package:bloc/db/shared_preferences/party_guest_preferences.dart';
import 'package:bloc/db/shared_preferences/table_preferences.dart';
import 'package:bloc/routes/bloc_router.dart';

import 'package:bloc/db/shared_preferences/ui_preferences.dart';
import 'package:bloc/services/firebase_api.dart';
import 'package:bloc/services/notification_service.dart';
import 'package:bloc/utils/logx.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  await NotificationService.initializeNotification();

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
  ]).then((value){
    runApp(const BlocApp());
  });
}

class BlocApp extends StatefulWidget {
  const BlocApp({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<BlocApp> createState() => _BlocAppState();
}

class _BlocAppState extends State<BlocApp> {
  static const String _TAG = 'BlocApp';

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

            if(appSnapshot.connectionState == ConnectionState.done){
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: kAppTitle,
                theme: ThemeData(
                  primaryColor: Constants.primary,
                  // 222,193,170
                  primaryColorLight: Constants.lightPrimary,
                  primaryColorDark: Constants.darkPrimary,

                  backgroundColor: Constants.background,
                  // focusColor: const Color.fromRGBO(31, 31, 33, 1.0),
                  shadowColor: const Color.fromRGBO(158, 158, 158, 1.0),

                  highlightColor: const Color.fromRGBO(255, 255, 255, 1.0),
                  bottomAppBarColor: const Color.fromRGBO(255, 255, 255, 1.0),

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
                routeInformationParser: BlocRouter.returnRouter(true).routeInformationParser,
                routerDelegate: BlocRouter.returnRouter(true).routerDelegate,
              );
            } else {
              return const LoadingWidget();
            }
          }),
    );
  }
}



