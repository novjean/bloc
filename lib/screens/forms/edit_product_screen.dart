import 'dart:io';

import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../db/entity/bloc.dart';
import '../../db/entity/product.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/bloc/edit_bloc_form.dart';
import '../../widgets/manager/edit_product_form.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-bloc-form-screen';
  Product product;

  EditProductScreen({key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();

}

class _EditProductScreenState extends State<EditProductScreen> {
  var logger = Logger();
  var _isLoading = false;

  void _submitProductForm(
      String productName,
      // String productType,
      String productDescription,
      String productPrice,
      File image,
      BuildContext ctx,
      ) async {
    logger.i('_submitProductForm called');

    setState(() {
      _isLoading = true;
    });

    String productId = widget.product.id;

    FirestorageHelper.deleteFile(widget.product.imageUrl);
    FirestoreHelper.updateProduct(productId, image);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      // drawer: AppDrawer(),
      body: EditProductForm(
        widget.product,
        _submitProductForm,
        _isLoading,
      ),
    );
  }

}