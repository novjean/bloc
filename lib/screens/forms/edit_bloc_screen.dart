import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../db/entity/bloc.dart';
import '../../widgets/bloc/edit_bloc_form.dart';
import '../../widgets/ui/Toaster.dart';

class EditBlocScreen extends StatefulWidget {
  static const routeName = '/edit-bloc-form-screen';
  Bloc bloc;

  EditBlocScreen({key, required this.bloc}) : super(key: key);

  @override
  _EditBlocScreenState createState() => _EditBlocScreenState();

}

class _EditBlocScreenState extends State<EditBlocScreen> {
  var logger = Logger();
  var _isLoading = false;

  void _submitBlocForm(
      String blocName,
      String addressLine1,
      String addressLine2,
      // String cityName,
      String pinCode,
      File image,
      BuildContext ctx,
      ) async {
    logger.i('_submitBlocForm called');

    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoading = true;
    });

    var time = Timestamp.now().toString();

    //determine the bloc identifier
    String blocId = widget.bloc.id;

    final firebaseStorage = FirebaseStorage.instance;

    try{
      await firebaseStorage.refFromURL(widget.bloc.imageUrl).delete();

    } on PlatformException catch (err) {
      logger.e(err.message);
      Toaster.shortToast("Photo deletion failed. Check credentials.");
    } catch (err) {
      logger.e(err);
      Toaster.shortToast("Photo deletion failed.");
    }

    try {
      // this points to the root cloud storage bucket
      final ref = firebaseStorage.ref()
          .child('bloc_image')
          .child(blocId + '.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('blocs').doc(blocId)
          .update({'imageUrl': url})
          .then((value) => print("Bloc image updated."))
          .catchError((error) => print("Failed to update bloc image: $error"));

      // await FirebaseFirestore.instance.collection('blocs').doc(blocId).set({
      //   'blocId': blocId,
      //   'name': blocName,
      //   'ownerId': user!.uid,
      //   'addressLine1': addressLine1,
      //   'addressLine2': addressLine2,
      //
      //   // this needs to be sent in
      //   'city': widget.bloc.cityName,
      //
      //   'pinCode': pinCode,
      //   'imageUrl': url,
      //   'createdAt': time,
      // });

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
        title: const Text('Edit BLOC'),
      ),
      // drawer: AppDrawer(),
      body: EditBlocForm(
        widget.bloc,
        _submitBlocForm,
        _isLoading,
      ),
    );
  }

}