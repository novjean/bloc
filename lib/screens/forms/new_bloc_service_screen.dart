import 'dart:io';

import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../db/entity/bloc.dart';
import '../../widgets/bloc/new_bloc_service_form.dart';

class NewBlocServiceScreen extends StatefulWidget {
  static const routeName = '/new-bloc-service-screen';
  Bloc bloc;

  NewBlocServiceScreen({key, required this.bloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewBlocServiceScreenState();
}

class _NewBlocServiceScreenState extends State<NewBlocServiceScreen> {
  var logger = Logger();
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bloc.name + ' : Service Form'),
      ),
      // drawer: AppDrawer(),
      body: NewBlocServiceForm(
        _submitNewBlocServiceForm, _isLoading,
        // _isLoading,
      ),
    );
  }

  void _submitNewBlocServiceForm(
    String serviceName,
    String serviceType,
    String primaryPhone,
    String secondaryPhone,
    String emailId,
    File image,
    BuildContext ctx,
  ) async {
    logger.i('_submitNewBlocServiceForm called');

    final user = FirebaseAuth.instance.currentUser;
    try {
      setState(() {
        _isLoading = true;
      });

      var time = Timestamp.now().toString();

      //determine the bloc identifier
      String blocServiceId = StringUtils.getRandomString(20);

      // this points to the root cloud storage bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('bloc_service_image')
          .child(blocServiceId + '.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('services').doc(blocServiceId).set({
        'id': blocServiceId,
        'name': serviceName,
        'blocId':widget.bloc.id,
        'type': serviceType,
        'primaryPhone': primaryPhone,
        'secondaryPhone': secondaryPhone,
        'emailId': emailId,
        'imageUrl': url,
        'ownerId': user!.uid,
        'createdAt': time,
      });

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(serviceName + " is added to BLOC " + widget.bloc.name),
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
}
