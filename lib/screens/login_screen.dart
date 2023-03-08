import 'dart:async';

import 'package:bloc/screens/otp_screen.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;

import 'package:bloc/screens/ui/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../utils/string_utils.dart';
import '../widgets/ui/toaster.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _controller = TextEditingController();
  String completePhoneNumber = '';
  bool isIOS = false;

  @override
  Widget build(BuildContext context) {
    isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          print('checking for auth state changes...');

          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          print('user snapshot received...');

          if (userSnapshot.hasData) {
            final user = FirebaseAuth.instance.currentUser;

            CollectionReference users = FirestoreHelper.getUsersCollection();

            if (user!.uid.isEmpty) {
              return SignInWidget();
            } else {
              return FutureBuilder<DocumentSnapshot>(
                future: users.doc(user.uid).get(),
                builder: (BuildContext ctx,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    print('snapshot has error: ' + snapshot.error.toString());
                    return SignInWidget();
                  }

                  if (snapshot.hasData && !snapshot.data!.exists) {
                    // user not registered in bloc, will be picked up in OTP screen
                    //todo: keep an eye on this
                    return SignInWidget();
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final blocUser.User user = Fresh.freshUserMap(data, true);
                    UserPreferences.setUser(user);

                    return MainScreen(user: user);
                  }
                  return const Center(child: Text("user loading..."));
                },
              );
            }
          } else {
            return SignInWidget();
          }
        },
      ),
    );
  }

  Widget SignInWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/icons/logo-adaptive.png"),
                  fit: BoxFit.fitHeight),
            ),
          ),
          flex: 3,
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
            child: IntlPhoneField(
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
              decoration: InputDecoration(
                  labelText: 'phone number',
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                  counterStyle:
                      TextStyle(color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 0.0),
                  )),
              controller: _controller,
              initialCountryCode: 'IN',
              dropdownTextStyle: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
              pickerDialogStyle: PickerDialogStyle(
                  backgroundColor: Theme.of(context).primaryColor),
              onChanged: (phone) {
                print(phone.completeNumber);
                completePhoneNumber = phone.completeNumber;
              },
              onCountryChanged: (country) {
                print('country changed to: ' + country.name);
              },
            ),
          ),
          flex: 1,
        ),
        Flexible(
          child: Column(
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Toaster.longToast('loading menu and events');
                      _verifyUsingSkipPhone();
                    },
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                      child: DelayedDisplay(
                        delay: const Duration(seconds: 3),
                        child: Text(
                          "skip for now",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          flex: 1,
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                shadowColor: Theme.of(context).shadowColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                minimumSize: Size(100, 60), //////// HERE
              ),
              onPressed: () {
                if (completePhoneNumber.isNotEmpty) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OTPScreen(completePhoneNumber)));
                } else {
                  print('user entered invalid phone number' +
                      completePhoneNumber);
                  Toaster.longToast('please enter a valid phone number');
                }
              },
              child: const Text(
                'next',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          flex: 1,
        ),
      ],
    );
  }

  _verifyUsingSkipPhone() async {
    String phone = '+911234567890';

    if (kIsWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber('${phone}', null)
          .then((user) {
        debugPrint('signInWithPhoneNumber: user verification id ' +
            user.verificationId);

        signInToSkipBloc(user.verificationId);
      }).catchError((e) {
        print('err: ' + e.toString());
      });
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '${phone}',
          verificationCompleted: (PhoneAuthCredential credential) async {
            print(
                'verifyPhoneNumber: ${phone} is verified. attempting sign in with credentials...');
            await FirebaseAuth.instance
                .signInWithCredential(credential)
                .then((value) async {
              if (value.user != null) {
                print('signInWithCredential: success. user logged in');
              }
            });
          },
          verificationFailed: (FirebaseAuthException e) {
            print(e.message);
          },
          codeSent: (String verificationID, int? resendToken) {
            signInToSkipBloc(verificationID);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            signInToSkipBloc(verificationId);
          },
          timeout: const Duration(seconds: 120));
    }
  }

  void signInToSkipBloc(String verificationId) async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: '123456'))
          .then((value) async {
        if (value.user != null) {
          print('user is in firebase auth. checking for bloc registration...');

          FirestoreHelper.pullUser(value.user!.uid).then((res) {
            print("successfully retrieved bloc user for id " + value.user!.uid);

            if (res.docs.isEmpty) {
              print('user is not already registered in bloc, registering...');

              blocUser.User registeredUser = Dummy.getDummyUser();
              registeredUser.id = value.user!.uid;
              registeredUser.phoneNumber = StringUtils.getInt(value.user!.phoneNumber!);

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MainScreen(user: registeredUser)));
            } else {
              debugPrint('user is a bloc member. navigating to main...');

              DocumentSnapshot document = res.docs[0];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              final blocUser.User user = Fresh.freshUserMap(data, true);
              UserPreferences.setUser(user);

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MainScreen(user: user)));
            }
          });
        }
      });
    } catch (e) {
      FocusScope.of(context).unfocus();
    }
  }
}
