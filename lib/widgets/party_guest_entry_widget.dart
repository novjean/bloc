import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/ui/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../helpers/firestore_helper.dart';
import '../../main.dart';
import '../../utils/logx.dart';
import '../db/entity/party_guest.dart';
import '../helpers/dummy.dart';
import '../../db/entity/user.dart' as blocUser;


class PartyGuestEntryWidget extends StatefulWidget {
  PartyGuest partyGuest;
  int index;

  PartyGuestEntryWidget({
    required this.partyGuest,
    required this.index,
    Key? key}) : super(key: key);

  @override
  State<PartyGuestEntryWidget> createState() => _PartyGuestEntryWidgetState();
}

class _PartyGuestEntryWidgetState extends State<PartyGuestEntryWidget> {
  static const String _TAG = 'PartyGuestEntryWidget';

  String completePhoneNumber = '';
  int maxPhoneNumberLength = 10;

  late blocUser.User user;

  @override
  void initState() {
    user = Dummy.getDummyUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: mq.width * 0.75,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldWidget(
              label: 'guest name ${widget.index} *',
              text: user.name,
              onChanged: (text) {
                user = user.copyWith(name: text);
              },
            ),
            IntlPhoneField(
              style: const TextStyle(
                  fontSize: 18),
              decoration: const InputDecoration(
                  labelText: 'phone number',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 0.0),
                  )),
              // controller: _controller,
              initialCountryCode: 'IN',
              dropdownTextStyle: const TextStyle(fontSize: 20),
              onChanged: (phone) async {
                Logx.i(_TAG, phone.completeNumber);
                completePhoneNumber = phone.completeNumber;

                if (phone.number.length == maxPhoneNumberLength) {
                  verifyPhoneNumber(phone.completeNumber);
                }
              },
              onCountryChanged: (country) {
                Logx.i(_TAG, 'country changed to: ${country.name}');
                maxPhoneNumberLength = country.maxLength;
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  void verifyPhoneNumber(String sFullNumber) async {
    Logx.ist(_TAG, 'verifying $sFullNumber');

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: sFullNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          Logx.i(_TAG,
              '$sFullNumber is verified and user is registered in bloc.');
        },
        verificationFailed: (FirebaseAuthException e) {
          Logx.em(_TAG, 'verificationFailed $e');
          Logx.i(_TAG, 'verifying $sFullNumber failed with error: $e');

        },
        codeSent: (String verificationID, int? resendToken) {
          Logx.d(_TAG, 'verification id : $verificationID');
          Logx.i(_TAG, 'code sent to $sFullNumber');

          int number = StringUtils.getInt(sFullNumber);

          FirestoreHelper.pullUserByPhoneNumber(number)
              .then((res) {
            if (res.docs.isNotEmpty) {
              // already registered
            } else {
              Logx.i(_TAG,
                  'user is not already registered in bloc, registering...');
              user = user.copyWith(phoneNumber: StringUtils.getInt(completePhoneNumber));
              FirestoreHelper.pushUser(user);
            }
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            setState(() {});
          }
        },
        timeout: const Duration(seconds: 60));
  }

}
