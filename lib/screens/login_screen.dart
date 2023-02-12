import 'package:bloc/screens/otp_screen.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;

import 'package:bloc/screens/ui/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
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
                    logger.e('snapshot has error: ' + snapshot.error.toString());
                    return SignInWidget();
                  }

                  if (snapshot.hasData && !snapshot.data!.exists) {
                    // user not registered in bloc, will be picked up in OTP screen
                    return Center(child: Text("Loading..."));
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final blocUser.User user = blocUser.User.fromMap(data);

                    // BlocRepository.insertUser(widget.dao, user);
                    UserPreferences.setUser(user);

                    return MainScreen(user: user);
                  }
                  return Center(child: Text("Loading..."));
                },
              );
            }
          } else {
            return SignInWidget();
          }
        },
      ),

      // SignInWidget()
    );
  }

  Widget SignInWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Container(
        //   margin: EdgeInsets.only(top: 200),
        //   child: Center(
        //     child: Text(
        //       'bloc',
        //       style: TextStyle(
        //         color: Theme.of(context).primaryColor,
        //         fontWeight: FontWeight.bold,
        //         letterSpacing: 25,
        //         fontSize: 72,
        //       ),
        //     ),
        //   ),
        // ),
        Container(
          height: 200,
          width: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    "assets/icons/logo-adaptive.png"),
                fit: BoxFit.fitHeight
              // AssetImage(food['image']),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 0, right: 20, left: 20),
          child: TextField(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              filled: true,
              hintText: 'phone number',
              fillColor: Colors.grey[100],
              prefix: Padding(
                padding: EdgeInsets.all(4),
                child: Text('+91'),
              ),
            ),
            style: TextStyle(fontSize: 20.0, height: 1.0, color: Colors.black),
            maxLength: 10,
            keyboardType: TextInputType.number,
            controller: _controller,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 40),
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
              String phoneNumberString = _controller.text;

              if(phoneNumberString.length == 10){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        OTPScreen(_controller.text)));
              } else {
                print('user entered invalid phone number' + phoneNumberString);
                Toaster.longToast('please enter a valid phone number');
              }
            },
            child: Text(
              'next',
              style: TextStyle(fontSize: 20),
            ),
          ),
        )
      ],
    );
  }
}
