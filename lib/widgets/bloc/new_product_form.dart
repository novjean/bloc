import 'dart:io';

import 'package:bloc/db/entity/category.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../pickers/user_image_picker.dart';

class NewProductForm extends StatefulWidget{
  List<Category> categories;
  NewProductForm(this.submitFn, this.isLoading, this.categories);

  final bool isLoading;
  final void Function(
      String productName,
      String categoryType,
      String productCategory,
      String productDescription,
      String productPrice,
      File image,
      BuildContext ctx,
      ) submitFn;

  @override
  State<NewProductForm> createState() => _NewProductFormState();
}

class _NewProductFormState extends State<NewProductForm> {
  var logger = Logger();

  final _formKey = GlobalKey<FormState>();

  // var _isLogin = true;
  String _productName = '';
  late String _productCategory = getFirstCategoryName();
  String _productDescription = '';
  String _productPrice ='';
  late File _userImageFile;

  late final _productCategories = getCategoryTypes();

  List<String> getCategoryTypes() {
    List<String> _categories = [];
    for(Category category in widget.categories){
      _categories.add(category.name);
    }
    return _categories;
  }

  String getFirstCategoryName() {
    return widget.categories[0].name;
  }

  String _categoryType = 'Alcohol';
  late final _categoryTypes = _getCategoryTypes();
  List<String> _getCategoryTypes() {
    List<String> _categoryTypes = [];
    _categoryTypes.add('Alcohol');
    _categoryTypes.add('Food');
    _categoryType = _categoryTypes[0];
    return _categoryTypes;
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmitNewProduct() {
    logger.i('_trySubmitNewProduct called');
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
        _categoryType.trim(),
        _productCategory.trim(),
        _productDescription,
        _productPrice,
        _userImageFile,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                UserImagePicker(_pickedImage, 90, 300),
                TextFormField(
                  key: const ValueKey('product_name'),
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
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      key: const ValueKey('category_type'),
                      decoration: InputDecoration(
                          errorStyle: TextStyle(
                              color: Colors.redAccent, fontSize: 16.0),
                          hintText: 'Please select category type',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      isEmpty: _categoryType == '',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _categoryType,
                          isDense: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              _categoryType = newValue!;
                              state.didChange(newValue);
                            });
                          },
                          items: _categoryTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 2.0),

                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      key: const ValueKey('product_category'),
                      decoration: InputDecoration(
                          errorStyle: TextStyle(
                              color: Colors.redAccent, fontSize: 16.0),
                          hintText: 'Please select product category',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      isEmpty: _productCategory == '',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _productCategory,
                          isDense: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              _productCategory = newValue!;
                              state.didChange(newValue);
                            });
                          },
                          items: _productCategories.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 2.0),


                TextFormField(
                  key: const ValueKey('product_description'),
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
                    onPressed: _trySubmitNewProduct,
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
