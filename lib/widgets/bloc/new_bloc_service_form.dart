import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../pickers/user_image_picker.dart';

class NewBlocServiceForm extends StatefulWidget {
  NewBlocServiceForm(this.submitFn, this.isLoading);

  final bool isLoading;
  final void Function(
    String serviceName,
    String serviceType,
    String primaryPhone,
    String secondaryPhone,
    String emailId,
    File image,
    BuildContext ctx,
  ) submitFn;

  @override
  State<StatefulWidget> createState() => _NewBlocServiceFormState();
}

class _NewBlocServiceFormState extends State<NewBlocServiceForm> {
  var logger = Logger();

  final _formKey = GlobalKey<FormState>();

  // var _isLogin = true;
  String _serviceName = '';
  String _serviceType = 'Bar';
  String _servicePrimaryPhone = '';

  // String _city = '';
  String _serviceSecondaryPhone = '';
  String _emailAddress = '';
  late File _userImageFile;

  final _serviceTypes = [
    "Bar",
    "Dance Floor",
    "Restaurant",
    "Rooftop",
    "Underground"
  ];

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmitNewBlocService() {
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
        _serviceName.trim(),
        _serviceType.trim(),
        _servicePrimaryPhone.trim(),
        _serviceSecondaryPhone.trim(),
        _emailAddress.trim(),
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
                  key: const ValueKey('bloc_service_name'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid name of the service provided.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                  ),
                  onSaved: (value) {
                    _serviceName = value!;
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
                          hintText: 'Please select expense',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      isEmpty: _serviceType == '',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _serviceType,
                          isDense: true,
                          // onChanged: (String? value){},
                          onChanged: (String? newValue) {
                            setState(() {
                              _serviceType = newValue!;
                              state.didChange(newValue);
                            });
                          },
                          items: _serviceTypes.map((String value) {
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
                //   key: const ValueKey('bloc_service_type'),
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
                //     labelText: 'Service Type',
                //   ),
                //   onSaved: (value) {
                //     _serviceType = value!;
                //   },
                // ),
                TextFormField(
                  key: const ValueKey('primary_phone_number'),
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid primary phone number.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Primary Phone Number',
                  ),
                  onSaved: (value) {
                    _servicePrimaryPhone = value!;
                  },
                ),
                TextFormField(
                  key: const ValueKey('secondary_phone_number'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid secondary phone number.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Secondary Phone Number',
                  ),
                  onSaved: (value) {
                    _serviceSecondaryPhone = value!;
                  },
                ),
                TextFormField(
                  key: const ValueKey('service_email_id'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                  onSaved: (value) {
                    _emailAddress = value!;
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                if (widget.isLoading) const CircularProgressIndicator(),
                if (!widget.isLoading)
                  RaisedButton(
                    child: const Text('Save'),
                    onPressed: _trySubmitNewBlocService,
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