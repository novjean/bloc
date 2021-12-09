import 'dart:io';

import 'package:bloc/widgets/app_drawer.dart';
import 'package:bloc/widgets/blocs/new_bloc_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class NewBlocScreen extends StatefulWidget {
  static const routeName = '/new-bloc-screen';

  const NewBlocScreen({Key key}) : super(key: key);

  @override
  _NewBlocScreenState createState() => _NewBlocScreenState();
}

class _NewBlocScreenState extends State<NewBlocScreen> {
  var logger = Logger();
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String addressLine1,
    String addressLine2,
    String city,
    String pinCode,
    File image,
    BuildContext ctx,
  ) async {
    logger.i('_submitAuthForm: ');

    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });

      var time = Timestamp.now();

      // perform image upload here
      // this points to the root cloud storage bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('bloc_image')
          .child(time.toString() + '.jpg'); // need to determine a unique id
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('blocs')
          .doc(authResult.user.uid)
          .set({
        'blocId': time,
        'ownerId': authResult.user.uid,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'pinCode': pinCode,
        'imageUrl': url,
      });

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(addressLine1 + " is added to BLOC!"),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
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
      appBar: AppBar(
        title: const Text('Add New BLOC'),
      ),
      drawer: AppDrawer(),
      body: NewBlocForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
