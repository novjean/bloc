import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../../db/bloc_repository.dart';
import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/category.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/bloc/new_product_form.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/new-category-item-screen';
  String serviceId;
  BlocDao dao;

  AddProductScreen({key, required this.serviceId, required this.dao})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  var logger = Logger();
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product | Add'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    Future<List<Category>> _future =
        BlocRepository.getCategoriesFuture(widget.dao);

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading categories...');
        } else {
          List<Category> categories = snapshot.data! as List<Category>;

          return NewProductForm(_submitNewProductForm, _isLoading, categories);
        }
      },
    );
  }

  void _submitNewProductForm(
    String productName,
    String categoryType,
    String productCategory,
    String productDescription,
    String productPrice,
    File image,
    BuildContext ctx,
  ) async {
    logger.i('_submitNewProductForm called');

    final user = FirebaseAuth.instance.currentUser;
    try {
      setState(() {
        _isLoading = true;
      });

      //determine the bloc identifier
      String productId = StringUtils.getRandomString(20);

      // this points to the root cloud storage bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_image')
          .child(productId + '.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      FirestoreHelper.insertProduct(
          productId,
          productName,
          categoryType,
          productCategory,
          productDescription,
          productPrice,
          widget.serviceId,
          url,
          user!.uid,
          false);

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(productName + " is added"),
          backgroundColor: Theme.of(ctx).primaryColor,
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
