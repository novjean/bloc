import 'package:bloc/screens/manager_screen.dart';
import 'package:bloc/screens/owner_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({key}) : super(key: key);

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
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SplashScreen();
                        }
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
                              int clearanceLevel = userData['clearance_level'];
                              return HomeScreen(clearanceLevel);
                            },
                          );
                          // return HomeScreen();
                        }
                        return const AuthScreen();
                      }),
              routes: {
                ManagerScreen.routeName: (ctx) => ManagerScreen(),
                OwnerScreen.routeName: (ctx) => OwnerScreen(),
              });
        });
  }
}
