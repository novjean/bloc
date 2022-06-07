import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../db/dao/bloc_dao.dart';
import '../../db/entity/category.dart';
import '../../pickers/user_image_picker.dart';

class NewServiceCategoryForm extends StatefulWidget {
  NewServiceCategoryForm(
      this.submitFn, this.mServiceId, this.dao, this.isLoading);

  final bool isLoading;
  final String mServiceId;
  final BlocDao dao;

  final void Function(
    String catName,
    String catType,
    String sequence,
    File image,
    BuildContext ctx,
  ) submitFn;

  @override
  State<StatefulWidget> createState() => _NewServiceCategoryFormState();
}

class _NewServiceCategoryFormState extends State<NewServiceCategoryForm> {
  var logger = Logger();

  final _formKey = GlobalKey<FormState>();
  String _categoryName = '';
  String _categoryType = 'Alcohol';
  late final _categoryTypes = _getCategoryTypes();

  List<String> _getCategoryTypes() {
    List<String> _categoryTypes = [];
    _categoryTypes.add('Alcohol');
    _categoryTypes.add('Food');
    _categoryType = _categoryTypes[0];
    return _categoryTypes;
  }

  String _catSequence = '';
  late File _userImageFile;

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
        _categoryName.trim(),
        _categoryType.trim(),
        _catSequence,
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
                SizedBox(height: 2.0),
                TextFormField(
                  key: const ValueKey('category_name'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid name of the service category.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                  ),
                  onSaved: (value) {
                    _categoryName = value!;
                  },
                ),
                SizedBox(height: 2.0),
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
                // _displayProductTypeDropdown(context),
                // SizedBox(height: 2.0),
                // _displayCategoryTypeDropdown(context),
                SizedBox(height: 2.0),
                TextFormField(
                  key: const ValueKey('category_sequence'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid sequence.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Category Sequence',
                  ),
                  onSaved: (value) {
                    _catSequence = value!;
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _displayProductTypeDropdown(BuildContext context) {
  //   List<String> _productTypes = List.empty(growable: true);
  //   _productTypes.add('Food');
  //   _productTypes.add('Alcohol');
  //   _productType = _productTypes[0];
  //
  //   return FormField<String>(
  //     builder: (FormFieldState<String> state) {
  //       return InputDecorator(
  //         key: const ValueKey('product_type'),
  //         decoration: InputDecoration(
  //           // labelStyle: textStyle,
  //             errorStyle:
  //             TextStyle(color: Colors.redAccent, fontSize: 16.0),
  //             hintText: 'Please select product type',
  //             border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(5.0))),
  //         isEmpty: _productType == '',
  //         child: DropdownButtonHideUnderline(
  //           child: DropdownButton<String>(
  //             value: _productType,
  //             isDense: true,
  //             onChanged: (String? newValue) {
  //               setState(() {
  //                 _productType = newValue!;
  //                 state.didChange(newValue);
  //               });
  //             },
  //             items: _productTypes.map((String value) {
  //               return DropdownMenuItem<String>(
  //                 value: value,
  //                 child: Text(value),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // _displayCategoryTypeDropdown(BuildContext context) {
  //   return Container(
  //     child: StreamBuilder(
  //       stream: widget.dao.getCategories(),
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return Text('Loading category types...');
  //         } else {
  //           List<Category> cats = snapshot.data! as List<Category>;
  //           List<String> _catTypes = List.empty(growable: true);
  //
  //           for (int i = 0; i < cats.length; i++) {
  //             Category cat = cats[i];
  //             if (i == 0) {
  //               _catType = cat.name;
  //             }
  //             _catTypes.add(cat.name);
  //           }
  //
  //           return FormField<String>(
  //             builder: (FormFieldState<String> state) {
  //               return InputDecorator(
  //                 key: const ValueKey('category_type'),
  //                 decoration: InputDecoration(
  //                     // labelStyle: textStyle,
  //                     errorStyle:
  //                         TextStyle(color: Colors.redAccent, fontSize: 16.0),
  //                     hintText: 'Please select product category',
  //                     border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(5.0))),
  //                 isEmpty: _catType == '',
  //                 child: DropdownButtonHideUnderline(
  //                   child: DropdownButton<String>(
  //                     value: _catType,
  //                     isDense: true,
  //                     onChanged: (String? newValue) {
  //                       setState(() {
  //                         _catType = newValue!;
  //                         state.didChange(newValue);
  //                       });
  //                     },
  //                     items: _catTypes.map((String value) {
  //                       return DropdownMenuItem<String>(
  //                         value: value,
  //                         child: Text(value),
  //                       );
  //                     }).toList(),
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }
}
