import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../db/entity/user.dart';
import '../../helpers/firestore_helper.dart';
import '../../utils/constants.dart';

class NewServiceTableForm extends StatefulWidget  {
  final bool isLoading;
  final void Function(
      int tableNumber,
      int capacity,
      String captainId,
      bool isActive,
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
  String _captainId = '';
  bool isActive = true;

  late Widget captainSelectWidget;
  late String _tableCaptain = '';

  @override
  void initState() {
    captainSelectWidget = buildCaptainUsers(context);
  }

  buildCaptainUsers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getUsersInRange(
            Constants.CAPTAIN_LEVEL, Constants.MANAGER_LEVEL - 1),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<User> _users = [];
          List<String> _userNames = [];

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
            document.data()! as Map<String, dynamic>;
            final User _user = User.fromMap(data);
            // BlocRepository.insertServiceTable(dao, serviceTable);
            _users.add(_user);
            _userNames.add(_user.name);

            if (i == snapshot.data!.docs.length - 1) {
              _tableCaptain = _users.elementAt(0).name;
              _captainId = _users.elementAt(0).id;

              return Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Captain:'),
                          SizedBox(height: 2.0),
                          FormField<String>(
                            builder: (FormFieldState<String> state) {
                              return InputDecorator(
                                key: const ValueKey('table_captain'),
                                decoration: InputDecoration(
                                    errorStyle:
                                    TextStyle(color: Colors.redAccent, fontSize: 16.0),
                                    hintText: 'Please select captain',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0))),
                                isEmpty: _tableCaptain == '',
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _tableCaptain,
                                    isDense: true,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _tableCaptain = newValue!;

                                        for(User user in _users){
                                          if(user.name.contains(newValue)){
                                            _captainId = user.id;
                                          }
                                        }
                                        state.didChange(newValue);
                                      });
                                    },
                                    items: _userNames.map((String value) {
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
                        ],
                      ),
                    ),
                  ),
                ),
              );
              // return _displayUsers(context, _users);
            }
          }
          return Text('Pulling captain users...');
        });
  }

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
        _captainId,
        isActive,
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
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 0,
                    ), //SizedBox
                    Text(
                      'Available : ',
                      style: TextStyle(fontSize: 17.0),
                    ), //Text
                    SizedBox(width: 10), //SizedBox
                    Checkbox(
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive =  value!;
                        });
                      },
                    ), //Checkbox
                  ], //<Widget>[]
                ),

                const SizedBox(
                  height: 12
                ),
                captainSelectWidget,
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
