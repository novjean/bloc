import 'dart:io';

import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../db/dao/bloc_dao.dart';
import '../../widgets/bloc/new_service_category_form.dart';
import '../../widgets/ui/Toaster.dart';

class NewServiceCategoryScreen extends StatefulWidget {
  static const routeName = '/new-service-category-screen';
  String serviceId;

  NewServiceCategoryScreen({key, required this.serviceId}) : super(key: key);

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
        title: Text('Category | Add'),
      ),
      // drawer: AppDrawer(),
      body: NewServiceCategoryForm(
        _submitNewServiceCategoryForm, widget.serviceId, _isLoading,
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

      //determine the bloc identifier
      String catId = StringUtils.getRandomString(20);

      // this points to the root cloud storage bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('service_category_image')
          .child(catId + '.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      FirebaseFirestore.instance.collection(FirestoreHelper.CATEGORIES).doc(catId).set({
        'id': catId,
        'name': catName,
        'serviceId':widget.serviceId,
        'type': catType,
        'imageUrl': url,
        'ownerId': user!.uid,
        'createdAt': Timestamp.now().millisecondsSinceEpoch,
        'sequence': int.parse(sequence),
      });

      Toaster.shortToast(catName + " is successfully added.");

      Navigator.of(context).pop();
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message!;
        logger.e(message);
      }

      Toaster.shortToast("Error : " + message);

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
