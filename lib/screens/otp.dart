import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String phone;

  OTPScreen(this.phone);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late String _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  final BoxDecoration pinPutDecoration = BoxDecoration(
      color: const Color.fromRGBO(43, 46, 66, 1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color.fromRGBO(126, 203, 224, 1),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verificaition')),
      body: Column(children: [
        Container(
            margin: EdgeInsets.only(top: 40),
            child: Center(
                child: Text(
              'Verify +91-${widget.phone}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ))),
        FractionallySizedBox(
            widthFactor: 1,
            child: PinputExample(
              phone: widget.phone,
            )),

        // Padding(
        //   padding: const EdgeInsets.all(30),
        //   child: PinPut(
        //     fieldsCount: 6,
        //     textStyle: const TextStyle(fontSize: 25, color: Colors.white),
        //     eachFieldWidth: 40,
        //     eachFieldHeight: 55,
        //     // onSubmit: (String pin) => _showSnackBar(pin),
        //     focusNode: _pinPutFocusNode,
        //     controller: _pinPutController,
        //     submittedFieldDecoration: pinPutDecoration,
        //     selectedFieldDecoration: pinPutDecoration,
        //     followingFieldDecoration: pinPutDecoration,
        //     pinAnimationType: PinAnimationType.fade,
        //   ),
        // ),
      ]),
    );
  }
}

class PinputExample extends StatefulWidget {
  // const PinputExample({Key? key, this.phone}) : super(key: key);
  PinputExample({key, required this.phone}) : super(key: key);

  String phone;

  @override
  State<PinputExample> createState() => _PinputExampleState();
}

class _PinputExampleState extends State<PinputExample> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

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
              print('user logged in');
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
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
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
              validator: (value) {
                // print('code is ' + _verificationCode);
                // return value == _verificationCode ? null : 'Pin is incorrect';
                return '';
              },
              // onClipboardFound: (value) {
              //   debugPrint('onClipboardFound: $value');
              //   pinController.setText(value);
              // },
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) async {
                debugPrint('onCompleted: $pin');

                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      print('pass to home');
                    }
                  });
                } catch (e) {
                  FocusScope.of(context).unfocus();
                  _scaffoldkey.currentState?.showSnackBar(SnackBar(
                    content: Text('Invalid OTP'),
                  ));
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
          TextButton(
            onPressed: () async {
              formKey.currentState!.validate();
            },
            child: const Text('Validate'),
          ),
        ],
      ),
    );
  }
}
