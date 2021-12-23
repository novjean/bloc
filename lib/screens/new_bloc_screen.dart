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
  var _isLoading = false;

  void _submitNewBlocForm(
    String addressLine1,
    String addressLine2,
    String city,
    String pinCode,
    File image,
    BuildContext ctx,
  ) async {
    logger.i('_submitNewBlocForm called');

    final user = FirebaseAuth.instance.currentUser;
    try {
      setState(() {
        _isLoading = true;
      });

      var time = Timestamp.now().toString();
      var blocName = (city+addressLine1+pinCode).replaceAll(' ', '');

      // this points to the root cloud storage bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('bloc_image')
          .child(blocName+ '.jpg'); // need to determine a unique id
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('blocs')
          .doc(blocName)
          .set({
        'blocId': blocName,
        'ownerId': user.uid,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'pinCode': pinCode,
        'imageUrl': url,
        'createdAt': time,
      });

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(addressLine1 + " is added to BLOC!"),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      Navigator.of(context).pop();
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message;
        logger.e(message);
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
      logger.e(err);
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
        _submitNewBlocForm,
        _isLoading,
      ),
    );
  }
}
