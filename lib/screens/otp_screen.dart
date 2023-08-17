import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/db/shared_preferences/ui_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/screens/profile/profile_add_edit_register_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../db/entity/promoter_guest.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../routes/route_constants.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import '../utils/string_utils.dart';
import '../widgets/ui/toaster.dart';

class OTPScreen extends StatefulWidget {
  final String phone;

  OTPScreen(this.phone, {Key? key}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  static const String _TAG = 'OTPScreen';

  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  String _verificationCode = '';

  @override
  void initState() {
    _verifyPhone();
    super.initState();
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
          .signInWithPhoneNumber(widget.phone, null)
          .then((user) {
        Logx.i(_TAG,
            'signInWithPhoneNumber: user verification id ${user.verificationId}');
        setState(() {
          _verificationCode = user.verificationId;
        });
      }).catchError((e, s) {
        Logx.e(_TAG, e, s);
      });
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: widget.phone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            Logx.i(_TAG,
                'verifyPhoneNumber: ${widget.phone} is verified. attempting sign in with credentials...');
          },
          verificationFailed: (FirebaseAuthException e) {
            Logx.i(_TAG, 'verificationFailed $e');
          },
          codeSent: (String verificationID, int? resendToken) {
            Logx.i(_TAG, 'verification id : $verificationID');

            if (mounted) {
              setState(() {
                _verificationCode = verificationID;
              });
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (mounted) {
              setState(() {
                _verificationCode = verificationId;
              });
            }
          },
          timeout: const Duration(seconds: 60));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.background,
          title: const Text(''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Constants.background,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/icons/logo-adaptive.png"),
                        fit: BoxFit.fitHeight
                        ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        'We offer you sunsets, tranquil summer days and a beachy vibe in the city.\n\n'
                        'Our menu of global cuisine created by our celebrity Chef Ameya Mahajani '
                        'is made with the freshest ingredients and accommodates all flavour palates.'
                        '\n\nOur co-founder Dr. Grace is passionate about food and cocktails. She has '
                        'worked on detailing the menu, so we feature a lot of tastes and '
                        'textures from her travels and memories.\n\nBloc is about community, '
                        'connection and coming together over some amazing food and drinks.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                          child: Text(
                        'enter the six digit code you received on \n${widget.phone}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      )),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10, top: 2, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DelayedDisplay(
                              delay: const Duration(seconds: 9),
                              child: Text('didn\'t receive code. ',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 16,
                                  )),
                            ),
                            InkWell(
                              onTap: () {
                                Toaster.longToast('refreshing ');
                                _verifyPhone();
                              },
                              child: DelayedDisplay(
                                delay: const Duration(seconds: 10),
                                child: Text(
                                  'resend?',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: FractionallySizedBox(
                      widthFactor: 1,
                      child: OTPVerifyWidget(
                        widget.phone,
                      )),
                ),
              ),
            ]));
  }

  OTPVerifyWidget(String phone) {
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
              closeKeyboardWhenCompleted: true,
              // validator: (value) {
              // print('code is ' + _verificationCode);
              // return value == _verificationCode ? null : 'pin is incorrect';
              // },
              // onClipboardFound: (value) {
              //   debugPrint('onClipboardFound: $value');
              //   pinController.setText(value);
              // },
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) async {
                debugPrint('onCompleted: $pin');

                Toaster.shortToast('verifying ${widget.phone}');
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      Logx.i(_TAG, 'user is in firebase auth');

                      String? fcmToken = '';

                      if (!kIsWeb) {
                        fcmToken = await FirebaseMessaging.instance.getToken();
                      }

                      Logx.i(_TAG, 'checking for bloc registration by id ${value.user!.uid}');

                      FirestoreHelper.pullUser(value.user!.uid).then((res) {
                        if (res.docs.isEmpty) {

                          Logx.i(_TAG, 'checking for bloc registration by phone ${widget.phone}');

                          int phoneNumber = StringUtils.getInt(widget.phone);
                          FirestoreHelper.pullUserByPhoneNumber(phoneNumber).then((res) {
                            if(res.docs.isNotEmpty) {
                              DocumentSnapshot document = res.docs[0];
                              Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                              blocUser.User user = Fresh.freshUserMap(data, true);

                              String oldUserDocId = user.id;
                              FirestoreHelper.deleteUser(oldUserDocId);

                              FirestoreHelper.pullPromoterGuestsByBlocUserId(user.id).then((res) {
                                    if(res.docs.isNotEmpty){
                                      for (int i = 0; i < res.docs.length; i++) {
                                        DocumentSnapshot document = res.docs[i];
                                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                        PromoterGuest pg = Fresh.freshPromoterGuestMap(data, false);
                                        pg = pg.copyWith(blocUserId: value.user!.uid);
                                        FirestoreHelper.pushPromoterGuest(pg);
                                      }
                                    }
                                  }
                              );

                              user = user.copyWith(id: value.user!.uid,
                                  fcmToken: fcmToken);
                              user.lastSeenAt = Timestamp.now().millisecondsSinceEpoch;
                              if (UserPreferences.isUserLoggedIn()) {
                                if (kIsWeb) {
                                  user.isAppUser = false;
                                } else {
                                  user.isAppUser = true;
                                }
                              }

                              FirestoreHelper.pushUser(user);
                              UserPreferences.setUser(user);
                              UiPreferences.setHomePageIndex(0);

                              Logx.ist(_TAG, 'hey there, welcome to bloc! 🦖');

                              GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                            } else {
                              Logx.i(_TAG, 'user is not already registered in bloc, registering...');

                              blocUser.User registeredUser = Dummy.getDummyUser();
                              registeredUser = registeredUser.copyWith(id: value.user!.uid,
                                  phoneNumber: StringUtils.getInt(value.user!.phoneNumber!),
                                  fcmToken: fcmToken!);

                              if (kIsWeb) {
                                registeredUser.isAppUser = false;
                              } else {
                                registeredUser.isAppUser = true;
                                registeredUser.isIos = Theme.of(context).platform == TargetPlatform.iOS;
                              }

                              FirestoreHelper.pushUser(registeredUser);
                              UserPreferences.setUser(registeredUser);
                              UiPreferences.setHomePageIndex(0);

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileAddEditRegisterPage(user: registeredUser, task: 'register')),
                              );
                            }
                          });
                        } else {
                          Logx.i(_TAG,
                              'user is a bloc member. navigating to main...');

                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          blocUser.User user;
                          if (kIsWeb) {
                            user = Fresh.freshUserMap(data, true);
                            user.isAppUser = false;
                          } else {

                            user = Fresh.freshUserMap(data, false);
                            user.fcmToken = fcmToken!;
                            user.isAppUser = true;
                          }

                          user.lastSeenAt = Timestamp.now().millisecondsSinceEpoch;
                          FirestoreHelper.pushUser(user);
                          UserPreferences.setUser(user);
                          UiPreferences.setHomePageIndex(0);

                          GoRouter.of(context)
                              .pushNamed(RouteConstants.homeRouteName);

                          Toaster.shortToast('hey ${user.name.toLowerCase()}, welcome back! 🦖');
                        }
                      });
                    }
                  });
                } catch (e) {
                  Logx.em(_TAG, 'otp error $e');

                  String exception = e.toString();
                  if (exception.contains('session-expired')) {
                    Toaster.shortToast('session got expired, trying again');
                    _verifyPhone();
                  } else {
                    Toaster.shortToast('invalid otp, please try again');
                  }
                  FocusScope.of(context).unfocus();
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
        ],
      ),
    );
  }

}
