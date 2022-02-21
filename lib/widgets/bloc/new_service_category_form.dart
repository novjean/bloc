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

  // var _isLogin = true;
  String _catName = '';
  String _catType = '';
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
        _catName.trim(),
        _catType.trim(),
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
                    _catName = value!;
                  },
                ),
                displayCategoryTypesDropdown(context),
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

  displayCategoryTypesDropdown(BuildContext context) {
    Stream<List<Category>> _catsStream = widget.dao.getCategoriesStream();
    return Container(
      child: StreamBuilder(
        stream: _catsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading category types...');
          } else {
            List<Category> cats = snapshot.data! as List<Category>;
            List<String> _catTypes = List.empty(growable: true);

            for (int i = 0; i < cats.length; i++) {
              Category cat = cats[i];
              if (i == 0) {
                _catType = cat.name;
              }
              _catTypes.add(cat.name);
            }
            // final List _catTypes = _tempCatTypes;
            _catType = 'Food';

            return FormField<String>(
              builder: (FormFieldState<String> state) {
                return InputDecorator(
                  key: const ValueKey('bloc_service_type'),
                  decoration: InputDecoration(
                      // labelStyle: textStyle,
                      errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 16.0),
                      hintText: 'Please select expense',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  isEmpty: _catType == '',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _catType,
                      isDense: true,
                      // onChanged: (String? value){},
                      onChanged: (String? newValue) {
                        setState(() {
                          _catType = newValue!;
                          state.didChange(newValue);
                        });
                      },
                      items: _catTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
