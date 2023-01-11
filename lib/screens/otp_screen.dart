import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../utils/string_utils.dart';
import '../widgets/ui/Toaster.dart';
import 'main_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final BlocDao dao;

  OTPScreen(this.phone, this.dao);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Column(
                    children: [
                      Container(
                        child: Center(
                          child: Text(
                            'BLOC',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 25,
                              fontSize: 72,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Center(
                            child: Text(
                          'Verify +91-${widget.phone}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Center(
                            child: Text(
                          'Enter the six digit code you received',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )),
                      ),
                    ],
                  )),
              Container(
                margin: EdgeInsets.only(top: 0),
                child: FractionallySizedBox(
                    widthFactor: 1,
                    child: PinputExample(
                      phone: widget.phone,
                      dao: widget.dao,
                    )),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 40),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                    shadowColor: Colors.white30,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    minimumSize: Size(100, 60), //////// HERE
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) =>
                    //         OTPScreen(_controller.text, widget.dao)));
                  },
                  child: Text(
                    'Back',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              )
            ]));
  }
}

class PinputExample extends StatefulWidget {
  PinputExample({key, required this.phone, required this.dao})
      : super(key: key);

  String phone;
  BlocDao dao;

  @override
  State<PinputExample> createState() => _PinputExampleState();
}

class _PinputExampleState extends State<PinputExample> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  String _verificationCode = '';

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              print('signInWithCredential: user logged in');
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationID, int? resendToken) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationCode = verificationId;
          });
        },
        timeout: Duration(seconds: 60));
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(255,235,59,1);
    const fillColor = Color.fromRGBO(38, 50, 56, 1.0);
    const borderColor = Color.fromRGBO(255,193,7,1);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(255,235,59,1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    /// Optionally you can use form to validate the Pinput
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              controller: pinController,
              focusNode: focusNode,
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              // validator: (value) {
                // print('code is ' + _verificationCode);
                // return value == _verificationCode ? null : 'Pin is incorrect';
                // return '';
              // },
              // onClipboardFound: (value) {
              //   debugPrint('onClipboardFound: $value');
              //   pinController.setText(value);
              // },
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) async {
                debugPrint('onCompleted: $pin');

                Toaster.shortToast('Verifying ...');
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      print(
                          'user is in firebase auth. checking for bloc registration...');

                      FirestoreHelper.pullUser(value.user!.uid).then((res) {
                        print("Successfully retrieved bloc user for id " +
                            value.user!.uid);

                        if (res.docs.isEmpty) {
                          print(
                              'user is not already registered in bloc, registering...');

                          blocUser.User registeredUser = blocUser.User(
                            id: value.user!.uid,
                            name: 'Superstar',
                            clearanceLevel: 1,
                            phoneNumber:
                                StringUtils.getInt(value.user!.phoneNumber!),
                            fcmToken: '',
                            email: '',
                            imageUrl: '',
                            username: '',
                            blocServiceId: '',
                          );

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => MainScreen(
                                      dao: widget.dao, user: registeredUser)));
                        } else {
                          debugPrint(
                              'user is a bloc member. navigating to main...');

                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          final blocUser.User user =
                              blocUser.User.fromMap(data);

                          BlocRepository.insertUser(widget.dao, user);
                          UserPreferences.setUser(user);

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MainScreen(dao: widget.dao, user: user)));
                        }
                      });
                    }
                  });
                } catch (e) {
                  FocusScope.of(context).unfocus();
                  Toaster.shortToast('Invalid OTP');
                }
              },
              onChanged: (value) {
                debugPrint('onChanged: $value');
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: focusedBorderColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: Colors.redAccent),
              ),
            ),
          ),
          // TextButton(
          //   onPressed: () async {
          //     formKey.currentState!.validate();
          //   },
          //   child: const Text('Validate'),
          // ),
        ],
      ),
    );
  }
}