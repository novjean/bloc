import 'package:bloc/screens/otp.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;

import 'package:bloc/screens/ui/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../utils/string_utils.dart';
import '../widgets/ui/Toaster.dart';
import 'main_screen.dart';

class TestLoginScreen extends StatefulWidget {
  BlocDao dao;

  TestLoginScreen({key, required this.dao}) : super(key: key);

  @override
  State<TestLoginScreen> createState() => _TestLoginScreenState();
}

class _TestLoginScreenState extends State<TestLoginScreen> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('BLOC'),
        // ),
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
                      Toaster.shortToast('login failed, please try again!');
                      return SignInWidget();
                    }

                    if (snapshot.hasData && !snapshot.data!.exists) {
                      print(
                          'firebase registration complete, user received, registering in bloc.');
                      // blocUser.User registeredUser = blocUser.User(
                      //   id: user.uid,
                      //   name: 'Superstar',
                      //   clearanceLevel: 1,
                      //   phoneNumber: StringUtils.getInt(user.phoneNumber!),
                      //   fcmToken: '',
                      //   email: '',
                      //   imageUrl: '',
                      //   username: '',
                      //   blocServiceId: '',
                      // );
                      //
                      // return MainScreen(dao: widget.dao, user: registeredUser);
                      return Text("loading...");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                      final blocUser.User user = blocUser.User.fromMap(data);

                      BlocRepository.insertUser(widget.dao, user);
                      UserPreferences.setUser(user);

                      return MainScreen(dao: widget.dao, user: user);
                    }
                    return Text("loading...");
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
        Container(
          margin: EdgeInsets.only(top: 60),
          child: Center(
            child: Text(
              'Phone Authentication',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 40, right: 10, left: 10),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Phone Number',
              prefix: Padding(
                padding: EdgeInsets.all(4),
                child: Text('+91'),
              ),
            ),
            maxLength: 10,
            keyboardType: TextInputType.number,
            controller: _controller,
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          width: double.infinity,
          child: FlatButton(
            color: Colors.blue,
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context)=> OTPScreen(_controller.text, widget.dao))
              );
            },
            child: Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}
