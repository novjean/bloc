import 'dart:io';

import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../widgets/bloc/new_service_category_form.dart';

class NewServiceCategoryScreen extends StatefulWidget {
  static const routeName = '/new-service-category-screen';
  BlocService service;

  NewServiceCategoryScreen({key, required this.service}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewServiceCategoryScreenState();
}

class _NewServiceCategoryScreenState extends State<NewServiceCategoryScreen> {
  var logger = Logger();
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.name + ' : Category Form'),
      ),
      // drawer: AppDrawer(),
      body: NewServiceCategoryForm(
        _submitNewServiceCategoryForm, _isLoading,
        // _isLoading,
      ),
    );
  }

  void _submitNewServiceCategoryForm(
      String catName,
      String catType,
      String sequence,
      File image,
      BuildContext ctx,
      ) async {
    logger.i('_submitNewServiceCategoryForm called');

    final user = FirebaseAuth.instance.currentUser;
    try {
      setState(() {
        _isLoading = true;
      });

      var time = Timestamp.now().toString();

      //determine the bloc identifier
      String catId = StringUtils.getRandomString(20);

      // this points to the root cloud storage bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('service_category_image')
          .child(catId + '.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('categories').doc(catId).set({
        'id': catId,
        'name': catName,
        'serviceId':widget.service.id,
        'type': catType,
        'imageUrl': url,
        'ownerId': user!.uid,
        'createdAt': time,
        'sequence': int.parse(sequence),
      });

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(catName + " is added to BLOC Service " + widget.service.name),
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
