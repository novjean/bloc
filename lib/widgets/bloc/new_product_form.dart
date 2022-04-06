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
      String productType,
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
  late String _productType = getFirstCategoryName();
  String _productDescription = '';
  String _productPrice ='';
  late File _userImageFile;

  late final _productTypes = getCategoryTypes();

  // [
  //   "Bar",
  //   "Dance Floor",
  //   "Restaurant",
  //   "Rooftop",
  //   "Underground"
  // ];

  List<String> getCategoryTypes() {
    List<String> catsList = [];
    for(Category category in widget.categories){
      catsList.add(category.name);
    }
    return catsList;
  }

  String getFirstCategoryName() {
    return widget.categories[0].name;
  }


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
        _productType.trim(),
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
                      key: const ValueKey('bloc_service_type'),
                      decoration: InputDecoration(
                        // labelStyle: textStyle,
                          errorStyle: TextStyle(
                              color: Colors.redAccent, fontSize: 16.0),
                          hintText: 'Please select bloc type',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      isEmpty: _productType == '',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _productType,
                          isDense: true,
                          // onChanged: (String? value){},
                          onChanged: (String? newValue) {
                            setState(() {
                              _productType = newValue!;
                              state.didChange(newValue);
                            });
                          },
                          items: _productTypes.map((String value) {
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

                // TextFormField(
                //   key: const ValueKey('product_type'),
                //   autocorrect: false,
                //   textCapitalization: TextCapitalization.words,
                //   enableSuggestions: false,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter a valid type of service.';
                //     }
                //     return null;
                //   },
                //   keyboardType: TextInputType.text,
                //   decoration: const InputDecoration(
                //     labelText: 'Product Type',
                //   ),
                //   onSaved: (value) {
                //     _productType = value!;
                //   },
                // ),

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
