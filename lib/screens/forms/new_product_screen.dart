
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../db/bloc_repository.dart';
import '../../db/dao/bloc_dao.dart';
import '../../db/entity/bloc_service.dart';
import '../../db/entity/category.dart';
import '../../utils/string_utils.dart';
import '../../widgets/bloc/new_product_form.dart';

class NewProductScreen extends StatefulWidget {
  static const routeName = '/new-category-item-screen';
  BlocService service;
  BlocDao dao;

  NewProductScreen({key, required this.service, required this.dao}) : super(key: key);

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
        title: Text(widget.service.name + ' : New Product Form'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    Future<List<Category>> _future = BlocRepository.getCategoriesFuture(widget.dao);

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading categories...');
        } else {
          List<Category> categories = snapshot.data! as List<Category>;

          return NewProductForm(
            _submitNewProductForm, _isLoading, categories
            // _isLoading,
          );
        }
      },
    );
  }

  void _submitNewProductForm(
      String productName,
      String productType,
      String productDescription,
      String productPrice,
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
      String productId = StringUtils.getRandomString(20);

      // this points to the root cloud storage bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_image')
          .child(productId + '.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('products').doc(productId).set({
        'id': productId,
        'name': productName,
        'type': productType,
        'description': productDescription,
        'price': int.parse(productPrice),
        'serviceId':widget.service.id,
        'imageUrl': url,
        'ownerId': user!.uid,
        'createdAt': time,
      });

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(productName + " is added to BLOC Service " + widget.service.name),
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
