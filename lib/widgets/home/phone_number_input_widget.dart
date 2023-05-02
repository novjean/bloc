import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../utils/logx.dart';

class PhoneNumberWidget extends StatelessWidget{
  static const String _TAG = 'PhoneNumberWidget';

  final TextEditingController _controller = TextEditingController();

  String completePhoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'phone number \*',
                style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: IntlPhoneField(
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18),
                decoration: InputDecoration(
                    labelText: '',
                    labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor),
                    hintStyle: TextStyle(
                        color: Theme.of(context).primaryColor),
                    counterStyle: TextStyle(
                        color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 0.0),
                    )),
                controller: _controller,
                initialCountryCode: 'IN',
                dropdownTextStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18),
                pickerDialogStyle: PickerDialogStyle(
                    backgroundColor:
                    Theme.of(context).primaryColor),
                onChanged: (phone) {
                  Logx.i(_TAG, phone.completeNumber);
                  completePhoneNumber = phone.completeNumber;
                },
                onCountryChanged: (country) {
                  Logx.i(_TAG,
                      'country changed to: ' + country.name);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}