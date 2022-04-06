import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/screens/owner_screen.dart';
import 'package:bloc/utils/user_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'db/database.dart';
import 'providers/cart.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/const.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // disabling landscape until all ui issues are resolved
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final database =
      await $FloorAppDatabase.databaseBuilder('bloc_database.db').build();
  final dao = database.blocDao;

  runApp(MyApp(dao: dao));
}

class MyApp extends StatelessWidget {
  static int mClearanceLevel = 10;
  final BlocDao dao;

  MyApp({required this.dao});

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

                            CollectionReference users = FirestoreHelper.getUsersCollection();

                            return FutureBuilder<DocumentSnapshot>(
                              future: users.doc(user!.uid).get(),
                              builder: (BuildContext ctx,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Text("Something went wrong");
                                }

                                if (snapshot.hasData &&
                                    !snapshot.data!.exists) {
                                  logger.e('document does not exist');
                                  return const AuthScreen();
                                  // return Text("Document does not exist");
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  Map<String, dynamic> data = snapshot.data!
                                      .data() as Map<String, dynamic>;
                                  final blocUser.User user = UserUtils.getUser(data);

                                  mClearanceLevel = user.clearanceLevel;
                                  // String userId = data['user_id'];
                                  // String username = data['username'];
                                  // String email = data['email'];
                                  // String imageUrl = data['image_url'];
                                  // String name = data['name'];
                                  //
                                  // final blocUser.User user = blocUser.User(
                                  //     userId: userId,
                                  //     username: username,
                                  //     email: email,
                                  //     imageUrl: imageUrl,
                                  //     clearanceLevel : mClearanceLevel,
                                  //     name: name);
                                  BlocRepository.insertUser(dao, user);

                                  logger.i(
                                      'user data received with clearance level ' +
                                          mClearanceLevel.toString());
                                  return MainScreen(dao: dao, user: user);
                                  // return Text("Full Name: ${data['full_name']} ${data['last_name']}");
                                }
                                return Text("loading...");
                              },
                            );
                          } else {
                            return const AuthScreen();
                          }
                        },
                      ),
                routes: {
                  // HomeScreen.routeName: (ctx) => HomeScreen(),
                  // ManagerScreen.routeName: (ctx) => ManagerScreen(),
                  OwnerScreen.routeName: (ctx) => OwnerScreen(),
                  // CityDetailScreen.routeName: (ctx) => CityDetailScreen(),
                  // NewBlocScreen.routeName: (ctx) => NewBlocScreen(),
                  // BlocDetailScreen.routeName: (ctx) => BlocDetailScreen(),
                });
          }),
    );
  }
}
