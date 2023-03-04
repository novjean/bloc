import 'package:bloc/screens/otp_screen.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;

import 'package:bloc/screens/ui/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
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

  @override
  Widget build(BuildContext context) {
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
                    final blocUser.User user = blocUser.User.fromMap(data);
                    UserPreferences.setUser(user);

                    return MainScreen(user: user);
                  }
                  return Center(child: Text("user loading..."));
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
                  fit: BoxFit.fitHeight
                  // AssetImage(food['image']),
                  ),
            ),
          ),
          flex: 3,
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
            child: IntlPhoneField(
              style: TextStyle(color: Theme.of(context).primaryColor),
              decoration: InputDecoration(
                labelText: 'phone number',
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              controller: _controller,
              initialCountryCode: 'IN',
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
                // String phoneNumberString = _controller.text;

                if (completePhoneNumber.isNotEmpty) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OTPScreen(completePhoneNumber)));
                } else {
                  print(
                      'user entered invalid phone number' + completePhoneNumber);
                  Toaster.longToast('please enter a valid phone number');
                }
              },
              child: Text(
                'next',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          flex: 1,
        )
      ],
    );
  }
}
