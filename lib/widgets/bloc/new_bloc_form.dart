import 'dart:io';

import 'package:bloc/pickers/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class NewBlocForm extends StatefulWidget {
  NewBlocForm(this.submitFn, this.isLoading);

  final bool isLoading;
  final void Function(
      String blocName,
      String addressLine1,
      String addressLine2,
      // String city,
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
  String _blocName='';
  String _addressLine1 = '';
  String _addressLine2 = '';
  // String _city = '';
  String _pinCode = '';
  late File _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmitNewBloc() {
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
        _blocName.trim(),
        _addressLine1.trim(),
        _addressLine2.trim(),
        _pinCode.trim(),
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
                UserImagePicker(_pickedImage,90,300),
                TextFormField(
                  key: const ValueKey('bloc_name'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid name of the property';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Club Name',
                  ),
                  onSaved: (value) {
                    _blocName = value!;
                  },
                ),
                TextFormField(
                  key: const ValueKey('address_line_1'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid address';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 1',
                  ),
                  onSaved: (value) {
                    _addressLine1 = value!;
                  },
                ),
                TextFormField(
                    key: const ValueKey('address_line_2'),
                    autocorrect: true,
                    textCapitalization: TextCapitalization.words,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a valid address';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Address Line 2',
                    ),
                    onSaved: (value) {
                      _addressLine2 = value!;
                    },
                  ),
                // TextFormField(
                //   key: const ValueKey('city'),
                //   textCapitalization: TextCapitalization.words,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter a valid city';                    }
                //     return null;
                //   },
                //   decoration: const InputDecoration(
                //     labelText: 'City',
                //   ),
                //   onSaved: (value) {
                //     _city = value!;
                //   },
                // ),
                TextFormField(
                  key: const ValueKey('pincode'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid pin code';                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pin Code',
                  ),
                  onSaved: (value) {
                    _pinCode = value!;
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                if (widget.isLoading) const CircularProgressIndicator(),
                if (!widget.isLoading)
                  RaisedButton(
                    child: const Text('Save'),
                    onPressed: _trySubmitNewBloc,
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
