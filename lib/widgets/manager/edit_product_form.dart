import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../db/entity/bloc.dart';
import '../../db/entity/product.dart';
import '../../pickers/edit_image_picker.dart';

class EditProductForm extends StatefulWidget {
  EditProductForm(this.product, this.submitFn, this.isLoading);

  final Product product;
  final bool isLoading;
  final void Function(
      String productName,
      String productDescription,
      String productPrice,
      File image,
      BuildContext ctx,
      ) submitFn;

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  var logger = Logger();

  final _formKey = GlobalKey<FormState>();

  // var _isLogin = true;
  String _productName = '';
  // late String _productType = getFirstCategoryName();
  String _productType = '';
  String _productDescription = '';
  String _productPrice ='';
  late File _userImageFile;

  // late final _productTypes = getCategoryTypes();

  // List<String> getCategoryTypes() {
  //   List<String> catsList = [];
  //   for(Category category in widget.categories){
  //     catsList.add(category.name);
  //   }
  //   return catsList;
  // }

  // String getFirstCategoryName() {
  //   return widget.categories[0].name;
  // }


  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    logger.i('trySubmit called');
    // this will trigger validator for all the text fields in the form
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please pick an image.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
        _productName.trim(),
        // _productType.trim(),
        _productDescription,
        _productPrice,
        _userImageFile,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _productName = widget.product.name;
    _productDescription = widget.product.description;
    _productPrice = widget.product.price.toString();
    _productType = widget.product.type;

    return Card(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EditImagePicker(_pickedImage, widget.product.imageUrl,90,300),
                TextFormField(
                  key: const ValueKey('product_name'),
                  initialValue: _productName,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid name for the product.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                  ),
                  onSaved: (value) {
                    _productName = value!;
                  },
                ),

                TextFormField(
                  key: const ValueKey('product_type'),
                  initialValue: _productType,
                  enabled: false,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Product Type',
                  ),
                  onSaved: (value) {
                    _productType = value!;
                  },
                ),

                TextFormField(
                  key: const ValueKey('product_description'),
                  initialValue: _productDescription,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.sentences,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid description of the product.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Product Description',
                  ),
                  onSaved: (value) {
                    _productDescription = value!;
                  },
                ),

                TextFormField(
                  key: const ValueKey('product_price'),
                  initialValue: _productPrice,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid price for the product.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Product Price',
                  ),
                  onSaved: (value) {
                    _productPrice = value!;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),
                if (widget.isLoading) const CircularProgressIndicator(),
                if (!widget.isLoading)
                  RaisedButton(
                    child: const Text('Save'),
                    onPressed: _trySubmit,
                  ),
                if (!widget.isLoading)
                  FlatButton(
                    child: const Text('Cancel'),
                    textColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
