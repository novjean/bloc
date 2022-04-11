import 'dart:io';

import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../db/entity/bloc.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/bloc/edit_bloc_form.dart';

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
    String blocId = widget.bloc.id;

    FirestorageHelper.deleteFile(widget.bloc.imageUrl);
    FirestoreHelper.updateBloc(blocId, image);

    Navigator.of(context).pop();


    try {

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