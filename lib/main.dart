import 'package:bloc/screens/city_detail_screen.dart';
import 'package:bloc/screens/manager_screen.dart';
import 'package:bloc/screens/new_bloc_screen.dart';
import 'package:bloc/screens/owner_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({key}) : super(key: key);

  static int mClearanceLevel;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (ctx, appSnapshot) {
          return MaterialApp(
              title: 'BLOC',
              theme: ThemeData(
                primarySwatch: Colors.red,
                backgroundColor: Colors.red,
                accentColor: Colors.deepPurple,
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
                  : StreamBuilder(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (ctx, userSnapshot) {
                        logger.i('checking for auth state changes...');

                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SplashScreen();
                        }

                        logger.i('user snapshot received...');

                        if (userSnapshot.hasData) {
                          final user = FirebaseAuth.instance.currentUser;
                          return FutureBuilder(
                            future: FirebaseFirestore.instance.collection('users')
                                .doc(user.uid).get(),
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final userData = snapshot.data;
                              mClearanceLevel = userData['clearance_level'];
                              logger.i('user data received with clearance level ' + mClearanceLevel.toString());

                              return HomeScreen();
                            },
                          );
                          // return HomeScreen();
                        } else {

                          return const AuthScreen();
                        }
                      }),
              routes: {
                HomeScreen.routeName: (ctx) => HomeScreen(),
                ManagerScreen.routeName: (ctx) => ManagerScreen(),
                OwnerScreen.routeName: (ctx) => OwnerScreen(),
                CityDetailScreen.routeName: (ctx) => CityDetailScreen(),
                NewBlocScreen.routeName: (ctx) => NewBlocScreen(),
              });
        });
  }
}
