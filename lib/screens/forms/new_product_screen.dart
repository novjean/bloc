
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../db/entity/bloc_service.dart';
import '../../utils/string_utils.dart';
import '../../widgets/bloc/new_product_form.dart';

class NewProductScreen extends StatefulWidget {
  static const routeName = '/new-category-item-screen';
  BlocService service;

  NewProductScreen({key, required this.service}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  var logger = Logger();
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.name + ' : Category Item Form'),
      ),
      // drawer: AppDrawer(),
      body: NewProductForm(
        _submitNewItemForm, _isLoading,
        // _isLoading,
      ),
    );
  }

  void _submitNewItemForm(
      String itemName,
      String itemType,
      String itemDescription,
      String itemPrice,
      File image,
      BuildContext ctx,
      ) async {
    logger.i('_submitNewItemForm called');

    final user = FirebaseAuth.instance.currentUser;
    try {
      setState(() {
        _isLoading = true;
      });

      var time = Timestamp.now().toString();

      //determine the bloc identifier
      String itemId = StringUtils.getRandomString(20);

      // this points to the root cloud storage bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('item_image')
          .child(itemId + '.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('items').doc(itemId).set({
        'id': itemId,
        'name': itemName,
        'type': itemType,
        'description': itemDescription,
        'price': int.parse(itemPrice),
        'serviceId':widget.service.id,
        'imageUrl': url,
        'ownerId': user!.uid,
        'createdAt': time,
      });

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(itemName + " is added to BLOC Service " + widget.service.name),
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
