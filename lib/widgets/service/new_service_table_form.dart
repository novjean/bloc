import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class NewServiceTableForm extends StatefulWidget  {
  final bool isLoading;
  final void Function(
      int tableNumber,
      int capacity,
      BuildContext ctx,
      ) submitFn;

  NewServiceTableForm(this.submitFn, this.isLoading);

  @override
  _NewServiceTableFormState createState() => _NewServiceTableFormState();
}

class _NewServiceTableFormState extends State<NewServiceTableForm> {
  var logger = Logger();

  final _formKey = GlobalKey<FormState>();
  int _tableNumber=  0;
  int _capacity = 1;

  void _trySubmitNewTable() {
    logger.i('trySubmit called');
    // this will trigger validator for all the text fields in the form
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
        _tableNumber,
        _capacity,
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
                TextFormField(
                  key: const ValueKey('table_number'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid table number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Table Number',
                  ),
                  onSaved: (value) {
                    _tableNumber = int.parse(value!);
                  },
                ),
                TextFormField(
                  key: const ValueKey('capacity'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid capacity of table';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Capacity',
                  ),
                  onSaved: (value) {
                    _capacity = int.parse(value!);
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                if (widget.isLoading) const CircularProgressIndicator(),
                if (!widget.isLoading)
                  RaisedButton(
                    child: const Text('Save'),
                    onPressed: _trySubmitNewTable,
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
