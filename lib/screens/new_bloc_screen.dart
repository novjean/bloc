import 'dart:io';

import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../db/entity/city.dart';
import '../widgets/bloc/new_bloc_form.dart';

class NewBlocScreen extends StatefulWidget {
  static const routeName = '/new-bloc-screen';
  City city;

  NewBlocScreen({key, required this.city}) : super(key: key);

  @override
  _NewBlocScreenState createState() => _NewBlocScreenState(city:city);
}

class _NewBlocScreenState extends State<NewBlocScreen> {
  var logger = Logger();
  var _isLoading = false;
  City city;

  _NewBlocScreenState({required this.city});

  void _submitNewBlocForm(
    String blocName,
    String addressLine1,
    String addressLine2,
    // String cityName,
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

      //determine the bloc identifier
      String blocId = StringUtils.getRandomString(20);

      // this points to the root cloud storage bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('bloc_image')
          .child(blocId + '.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('blocs').doc(blocId).set({
        'blocId': blocId,
        'name': blocName,
        'ownerId': user!.uid,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city.id,
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
        message = err.message!;
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
      // drawer: AppDrawer(),
      body: NewBlocForm(
        _submitNewBlocForm,
        _isLoading,
      ),
    );
  }
}
