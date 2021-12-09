import 'dart:io';

import 'package:bloc/pickers/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
// import 'package:loggy/loggy.dart';

class NewBlocForm extends StatefulWidget {
  NewBlocForm(this.submitFn, this.isLoading);

  final bool isLoading;
  final void Function(
      String addressLine1,
      String addressLine2,
      String city,
      String pinCode,
      File image,
      BuildContext ctx,
      ) submitFn;

  @override
  _NewBlocFormState createState() => _NewBlocFormState();
}

class _NewBlocFormState extends State<NewBlocForm> {
  var logger = Logger();

  final _formKey = GlobalKey<FormState>();
  // var _isLogin = true;
  String _addressLine1 = '';
  String _addressLine2 = '';
  String _city = '';
  String _pinCode = '';
  var _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    // this will trigger validator for all the text fields in the form
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick an image.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _addressLine1.trim(),
        _addressLine2.trim(),
        _city.trim(),
        _pinCode.trim(),
        _userImageFile,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserImagePicker(_pickedImage),
                TextFormField(
                  key: ValueKey('address line 1'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid address';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Address Line 1',
                  ),
                  onSaved: (value) {
                    _addressLine1 = value;
                  },
                ),
                TextFormField(
                    key: ValueKey('address line 2'),
                    autocorrect: true,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a valid address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Address Line 2',
                    ),
                    onSaved: (value) {
                      _addressLine2 = value;
                    },
                  ),
                TextFormField(
                  key: ValueKey('city'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid city';                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'City',
                  ),
                  onSaved: (value) {
                    _city = value;
                  },
                ),
                TextFormField(
                  key: ValueKey('pincode'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid pin code';                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Pin Code',
                  ),
                  onSaved: (value) {
                    _pinCode = value;
                  },
                ),
                SizedBox(
                  height: 12,
                ),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  RaisedButton(
                    child: Text('Save'),
                    onPressed: () {
                      logger.i('save button clicked');
                      // _trySubmit;
                    }
                  ),
                if (!widget.isLoading)
                  FlatButton(
                    child: Text('Cancel'),
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
