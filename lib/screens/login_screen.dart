import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/screens/main_screen.dart';
import 'package:bloc/screens/ui/splash_screen.dart';

import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../widgets/ui/Toaster.dart';

class LoginScreen extends StatelessWidget {
  BlocDao dao;

  LoginScreen({key, required this.dao}) : super(key: key);

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        logger.i('checking for auth state changes...');

        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }

        logger.i('user snapshot received...');

        if (userSnapshot.hasData) {
          final user = FirebaseAuth.instance.currentUser;

          CollectionReference users = FirestoreHelper.getUsersCollection();

          return FutureBuilder<DocumentSnapshot>(
            future: users.doc(user!.uid).get(),
            builder:
                (BuildContext ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return LoginWidget(context);
              }

              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                final blocUser.User user = blocUser.User.fromMap(data);

                BlocRepository.insertUser(dao, user);
                UserPreferences.setUser(user);

                return MainScreen(dao: dao, user: user);
              }
              return Text("loading...");
            },
          );
        } else {
          return LoginWidget(context);
        }
      },
    ));
  }

  Widget LoginWidget(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.all(32),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Login",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w500),
            ),

            SizedBox(
              height: 24,
            ),

            TextFormField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: "Phone Number"),
              controller: _phoneController,
            ),

            SizedBox(
              height: 24,
            ),

            Container(
              width: double.infinity,
              child: FlatButton(
                child: Text("Login"),
                textColor: Colors.white,
                padding: EdgeInsets.all(16),
                onPressed: () {
                  //code for sign in
                  final phone = "+91" + _phoneController.text.trim();
                  registerUser(phone, context);
                },
                color: Theme.of(context).accentColor,
              ),
            ),
            SizedBox(height: 24,),
            Container(
              width: double.infinity,
              child: FlatButton(
                child: Text("Register"),
                textColor: Colors.white,
                padding: EdgeInsets.all(16),
                onPressed: () async {
                  final providers = [
                    // AuthUiProvider.anonymous,
                    // AuthUiProvider.email,
                    AuthUiProvider.phone,
                    // AuthUiProvider.apple,
                    // AuthUiProvider.github,
                    // AuthUiProvider.google,
                    // AuthUiProvider.microsoft,
                    // AuthUiProvider.yahoo,
                  ];

                  final result = await FlutterAuthUi.startUi(
                    items: providers,
                    tosAndPrivacyPolicy: TosAndPrivacyPolicy(
                      tosUrl: "https://www.google.com",
                      privacyPolicyUrl: "https://www.google.com",
                    ),
                    androidOption: const AndroidOption(
                      enableSmartLock: false, // default true
                      showLogo: true, // default false
                      overrideTheme: true, // default false
                    ),
                    emailAuthOption: const EmailAuthOption(
                      requireDisplayName: true,
                      // default true
                      enableMailLink: false,
                      // default false
                      handleURL: '',
                      androidPackageName: '',
                      androidMinimumVersion: '',
                    ),
                  );
                  debugPrint(result.toString());
                },
                color: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future registerUser(String strMobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      _auth.verifyPhoneNumber(
          phoneNumber: strMobile,
          timeout: Duration(seconds: 120),
          verificationCompleted: (AuthCredential authCredential) {
            _auth.signInWithCredential(authCredential).then((result) async {
              Toaster.shortToast('login: verification completed!');

              // UserCredential result =
              //     await _auth.signInWithCredential(authCredential);
              User? user = result.user;

              if (user != null) {
                // CollectionReference users = FirestoreHelper.getUsersCollection();

                // FutureBuilder<DocumentSnapshot>(
                //   future: users.doc(user.uid).get(),
                //   builder: (BuildContext ctx,
                //       AsyncSnapshot<DocumentSnapshot> snapshot) {
                //     if (snapshot.connectionState ==
                //         ConnectionState.waiting) {
                //       return const Center(
                //         child: CircularProgressIndicator(),
                //       );
                //     }
                //
                //     if (snapshot.hasError) {
                //       return Text("Something went wrong");
                //     }
                //
                //     if (snapshot.hasData &&
                //         !snapshot.data!.exists) {
                //       blocUser.User registeredUser = blocUser.User(
                //           id: user.uid,
                //           name: 'Superstar',
                //           clearanceLevel: 1,
                //           phoneNumber: StringUtils.getNumberOnly(strMobile),
                //           fcmToken: '',
                //           email: '',
                //           imageUrl: '',
                //           username: '');
                //
                //       FirestoreHelper.insertPhoneUser(registeredUser);
                //       print(strMobile + ' is registered with bloc!');
                //       BlocRepository.insertUser(dao, registeredUser);
                //       UserPreferences.setUser(registeredUser);
                //
                //       Navigator.of(context).push(
                //         MaterialPageRoute(
                //             builder: (context) =>
                //                 MainScreen(user: registeredUser, dao: dao)),
                //       );
                //     }
                //
                //     if (snapshot.connectionState ==
                //         ConnectionState.done) {
                //       Map<String, dynamic> data = snapshot.data!
                //           .data() as Map<String, dynamic>;
                //       final blocUser.User regUser = blocUser.User.fromMap(data);
                //
                //       // mClearanceLevel = user.clearanceLevel;
                //       BlocRepository.insertUser(dao, regUser);
                //       UserPreferences.setUser(regUser);
                //
                //       Navigator.of(context).pushReplacement(
                //         MaterialPageRoute(
                //             builder: (context) =>
                //                 MainScreen(user: regUser, dao: dao)),
                //       );
                //     }
                //     return Text("loading user...");
                //   },
                // );

                // blocUser.User registeredUser = blocUser.User(
                //     id: user.uid,
                //     name: 'Superstar',
                //     clearanceLevel: 1,
                //     phoneNumber: StringUtils.getNumberOnly(strMobile),
                //     fcmToken: '',
                //     email: '',
                //     imageUrl: '',
                //     username: '');
                //
                // await FirestoreHelper.insertPhoneUser(registeredUser);
                // print(strMobile + ' is registered with bloc!');
                // BlocRepository.insertUser(dao, registeredUser);
                // UserPreferences.setUser(registeredUser);
                //
                // await Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(
                //       builder: (context) =>
                //           MainScreen(user: registeredUser, dao: dao)),
                // );
              } else {
                print(strMobile +
                    ' registration failed, user could not be retrieved!');
              }
            }).catchError((e) {
              print(e);
            });
          },
          verificationFailed: (FirebaseAuthException authException) {
            print(authException.message);
          },
          codeSent: (String verificationId, int? forceResendingToken) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Please enter the OTP sent?"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: _codeController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Confirm"),
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: () async {
                          final code = _codeController.text.trim();

                          AuthCredential credential = PhoneAuthProvider.credential(
                              verificationId: verificationId,
                              smsCode: code);
                          UserCredential result = await _auth.signInWithCredential(credential);
                          User? user = result.user;

                          if (user != null) {
                            blocUser.User registeredUser = blocUser.User(
                                id: user.uid,
                                name: 'Superstar',
                                clearanceLevel: 1,
                                phoneNumber:
                                StringUtils.getNumberOnly(strMobile),
                                fcmToken: '',
                                email: '',
                                imageUrl: '',
                                username: '', blocServiceId: '');

                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => MainScreen(
                                      user: registeredUser, dao: dao)),
                            );
                          } else {
                            print(strMobile +
                                ' registration failed, user could not be retrieved!');
                          }
                        },
                      ),
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
            print(verificationId);
            print("Timeout");
          });
    } catch (e) {
      print("failed to verify phone number: ${e}");
    }
  }
}
