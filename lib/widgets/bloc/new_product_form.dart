import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../pickers/user_image_picker.dart';

class NewProductForm extends StatefulWidget{
  NewProductForm(this.submitFn, this.isLoading);

  final bool isLoading;
  final void Function(
      String itemName,
      String itemType,
      String itemDescription,
      String itemPrice,
      File image,
      BuildContext ctx,
      ) submitFn;

  @override
  State<StatefulWidget> createState() => _NewProductFormState();
}

class _NewProductFormState extends State<NewProductForm> {
  var logger = Logger();

  final _formKey = GlobalKey<FormState>();

  // var _isLogin = true;
  String _itemName = '';
  String _itemType = '';
  String _itemDescription = '';
  String _itemPrice ='';
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
        _itemName.trim(),
        _itemType.trim(),
        _itemDescription,
        _itemPrice,
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
                  key: const ValueKey('item_name'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid name of the item.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                  ),
                  onSaved: (value) {
                    _itemName = value!;
                  },
                ),

                TextFormField(
                  key: const ValueKey('item_type'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid type of service.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Item Type',
                  ),
                  onSaved: (value) {
                    _itemType = value!;
                  },
                ),
                TextFormField(
                  key: const ValueKey('item_description'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.sentences,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid description of item.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Item Description',
                  ),
                  onSaved: (value) {
                    _itemDescription = value!;
                  },
                ),

                TextFormField(
                  key: const ValueKey('item_price'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid price for item.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Item Price',
                  ),
                  onSaved: (value) {
                    _itemPrice = value!;
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
