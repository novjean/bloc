import 'dart:io';

import 'package:bloc/widgets/auth/auth_form.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/firestore_helper.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
      String email,
      String password,
      String username,
      File? image,
      bool isLogin,
      BuildContext ctx,
      ) async {
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        UserCredential authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        await FirestoreHelper.insertUser(email, password, image, username);

        print("registered " + email);
      }
    } on PlatformException catch (err) {
      var message = 'an error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message!;
      }

      print("error: " + message);

      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
