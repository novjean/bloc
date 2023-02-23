import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../main.dart';
import '../utils/string_utils.dart';
import '../widgets/ui/toaster.dart';
import 'main_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;

  OTPScreen(this.phone);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            "assets/icons/logo-adaptive.png"),
                        fit: BoxFit.fitHeight
                      // AssetImage(food['image']),
                    ),
                  ),
                ), flex: 1,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Center(
                      child: Text(
                      'We offer you sunsets, balmy summer days and a beachy vibe in the city.\n\n'
                      'Our menu of global cuisine created by Award Winning Chef Ameya Mahajani '
    'is made with the freshest ingredients and accommodates all flavour palates.'
    '\n\nOur co-founder Dr. Grace is passionate about food and she has '
    'worked on detailing the menu so we feature a lot of tastes and '
    'textures from her travels and memories.\n\nBloc is about community, '
    'connection and coming together over some amazing food and drinks.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                      )),
                ),flex: 2,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Center(
                      child: Text(
                        'enter the six digit code you received on +91-${widget.phone}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                      )),
                ),flex: 1,
              ),
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(top: 0, bottom: 20),
                  child: FractionallySizedBox(
                      widthFactor: 1,
                      child: OTPVerify(
                        phone: widget.phone,
                      )),
                ), flex: 1,
              ),
            ]));
  }
}

class OTPVerify extends StatefulWidget {
  OTPVerify({key, required this.phone}) : super(key: key);

  String phone;

  @override
  State<OTPVerify> createState() => _OTPVerifyState();
}

class _OTPVerifyState extends State<OTPVerify> {
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
    if (kIsWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber('+91${widget.phone}', null)
          .then((user) {
        debugPrint('signInWithPhoneNumber: user verification id ' +
            user.verificationId);
        setState(() {
          _verificationCode = user.verificationId;
        });
      }).catchError((e) {
        print('err: ' + e.toString());
      });
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+91${widget.phone}',
          verificationCompleted: (PhoneAuthCredential credential) async {
            print(
                'verifyPhoneNumber: +91${widget.phone} is verified. attempting sign in with credentials...');
            await FirebaseAuth.instance
                .signInWithCredential(credential)
                .then((value) async {
              if (value.user != null) {
                print('signInWithCredential: success. user logged in');
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
          timeout: const Duration(seconds: 120));
    }
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(222, 193, 170, 1);
    const fillColor = Color.fromRGBO(38, 50, 56, 1.0);
    const borderColor = Color.fromRGBO(211, 167, 130, 1);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(222, 193, 170, 1),
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
              // androidSmsAutofillMethod:
              //     AndroidSmsAutofillMethod.smsUserConsentApi,
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

                Toaster.shortToast('verifying +91${widget.phone}');
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      print(
                          'user is in firebase auth. checking for bloc registration...');

                      FirestoreHelper.pullUser(value.user!.uid).then((res) {
                        print("successfully retrieved bloc user for id " +
                            value.user!.uid);

                        if (res.docs.isEmpty) {
                          print(
                              'user is not already registered in bloc, registering...');

                          blocUser.User registeredUser = blocUser.User(
                            id: value.user!.uid,
                            name: '',
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
                                  builder: (context) =>
                                      MainScreen(user: registeredUser)));
                        } else {
                          debugPrint(
                              'user is a bloc member. navigating to main...');

                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          final blocUser.User user =
                              blocUser.User.fromMap(data);
                          UserPreferences.setUser(user);

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MainScreen(user: user)));
                        }
                      });
                    }
                  });
                } catch (e) {
                  FocusScope.of(context).unfocus();
                  Toaster.shortToast('invalid OTP. please try again.');
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
