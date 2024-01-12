import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';

import 'package:bloc/db/entity/user.dart' as blocUser;
import '../db/entity/promoter_guest.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../widgets/ui/toaster.dart';
import 'constants.dart';
import 'layout_utils.dart';
import 'logx.dart';

class LoginUtils {
  static const String _TAG = 'LoginUtils';

  BuildContext context;

  LoginUtils({required this.context});

  final TextEditingController _controller = TextEditingController();
  String completePhoneNumber = '';
  int maxPhoneNumberLength = 10;

  final formKey = GlobalKey<FormState>();
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  void showLoginDialog() {
    if(kIsWeb){
      _showPhoneNumberDialog(context);
    } else {
      _showQuickLoginDialog(context);
    }
  }

  void _showQuickLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctxDialog) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.background,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: SizedBox(
            height: mq.height * 0.4,
            width: mq.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('please provide phone number 📱',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Constants.lightPrimary,
                        fontWeight: FontWeight.w500)),

                //for adding some space
                SizedBox(height: mq.height * .02),

                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
                    child: IntlPhoneField(
                      style: const TextStyle(
                          color: Constants.primary, fontSize: 20),
                      decoration: const InputDecoration(
                          labelText: 'phone number',
                          labelStyle: TextStyle(color: Constants.primary),
                          hintStyle: TextStyle(color: Constants.primary),
                          counterStyle: TextStyle(color: Constants.primary),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Constants.primary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Constants.primary, width: 0.0),
                          )),
                      controller: _controller,
                      initialCountryCode: 'IN',
                      dropdownTextStyle: const TextStyle(color: Constants.primary, fontSize: 20),
                      pickerDialogStyle: PickerDialogStyle(backgroundColor: Constants.primary),
                      onChanged: (phone) {
                        completePhoneNumber = phone.completeNumber;

                        if (phone.number.length == maxPhoneNumberLength) {
                          _verifyPhone(completePhoneNumber);
                        }
                      },
                      onCountryChanged: (country) {
                        Logx.i(_TAG, 'country changed to: ${country.name}');
                        maxPhoneNumberLength = country.maxLength;
                      },
                    ),
                  ),
                ),

                SizedBox(height: mq.height * .02),

                Text('please enter otp sent to $completePhoneNumber ⏳',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Constants.lightPrimary,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: mq.height * .02),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
                    child: OTPVerifyWidget(completePhoneNumber, ctxDialog),
                  ),
                ),
              ],
            ),
          ),
          actions: [

          ],
        );
      },
    );
  }

  void _showPhoneNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.background,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: SizedBox(
            height: mq.height * 0.2,
            width: mq.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('please provide phone number 📱',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Constants.lightPrimary,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: mq.height * .02),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
                    child: IntlPhoneField(
                      style: const TextStyle(
                          color: Constants.primary, fontSize: 20),
                      decoration: const InputDecoration(
                          labelText: 'phone number',
                          labelStyle: TextStyle(color: Constants.primary),
                          hintStyle: TextStyle(color: Constants.primary),
                          counterStyle: TextStyle(color: Constants.primary),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Constants.primary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Constants.primary, width: 0.0),
                          )),
                      controller: _controller,
                      initialCountryCode: 'IN',
                      dropdownTextStyle: const TextStyle(color: Constants.primary, fontSize: 20),
                      pickerDialogStyle: PickerDialogStyle(backgroundColor: Constants.primary),
                      onChanged: (phone) {
                        Logx.i(_TAG, phone.completeNumber);
                        completePhoneNumber = phone.completeNumber;

                        if (phone.number.length == maxPhoneNumberLength) {
                          _verifyPhone(completePhoneNumber);

                          if(kIsWeb){
                            Navigator.of(context).pop();
                            _showOtpDialog(context);
                          }
                        }
                      },
                      onCountryChanged: (country) {
                        Logx.i(_TAG, 'country changed to: ${country.name}');
                        maxPhoneNumberLength = country.maxLength;
                      },
                    ),
                  ),
                ),

              ],
            ),
          ),
          actions: [
            // TextButton(
            //   child: const Text("exit"),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
            //   },
            // ),
          ],
        );
      },
    );
  }

  _verifyPhone(String completePhoneNumber) async {
    if (kIsWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber(completePhoneNumber, null)
          .then((user) {
        Logx.i(_TAG,
            'signInWithPhoneNumber: user verification id ${user.verificationId}');

        Logx.ist(_TAG, 'otp code has been sent to $completePhoneNumber 🚀');

        UserPreferences.setVerificationId(user.verificationId);
      }).catchError((e, s) {
        Logx.e(_TAG, e, s);
      });
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: completePhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            Logx.i(_TAG,
                'verifyPhoneNumber: $completePhoneNumber is verified. attempting sign in with credentials...');
          },
          verificationFailed: (FirebaseAuthException e) {
            Logx.i(_TAG, 'verificationFailed $e');
          },
          codeSent: (String verificationID, int? resendToken) {
            Logx.i(_TAG, 'verification id : $verificationID');
            Logx.ist(_TAG, 'otp code has been sent to $completePhoneNumber 🚀');

            UserPreferences.setVerificationId(verificationID);
          },
          codeAutoRetrievalTimeout: (String verificationId) {

          },
          timeout: const Duration(seconds: 60));
    }
  }

  void _showOtpDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext ctxDialog) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.background,
          content: SizedBox(
            height: mq.height * 0.2,
            width: mq.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('please enter otp sent to $completePhoneNumber ⏳',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Constants.lightPrimary,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: mq.height * .02),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
                    child: OTPVerifyWidget(completePhoneNumber, ctxDialog),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // TextButton(
            //   child: const Text("exit"),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
            //   },
            // ),
          ],
        );
      },
    );
  }

  OTPVerifyWidget(String phone, BuildContext ctxDialog) {
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
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              controller: pinController,
              focusNode: focusNode,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              closeKeyboardWhenCompleted: true,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) async {
                debugPrint('onCompleted: $pin');

                String verificationCode = UserPreferences.getVerificationId();
                Logx.ist(_TAG, '👩‍🚀 verifying $phone, please wait.');

                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                      verificationId: verificationCode, smsCode: pin))
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
                          Logx.i(_TAG,
                              'checking for bloc registration by phone $completePhoneNumber');

                          int phoneNumber =
                          StringUtils.getInt(completePhoneNumber);
                          FirestoreHelper.pullUserByPhoneNumber(phoneNumber)
                              .then((res) {
                            if (res.docs.isNotEmpty) {
                              DocumentSnapshot document = res.docs[0];
                              Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                              blocUser.User user = Fresh.freshUserMap(data, true);

                              String oldUserDocId = user.id;
                              FirestoreHelper.deleteUser(oldUserDocId);

                              FirestoreHelper.pullPromoterGuestsByBlocUserId(
                                  user.id)
                                  .then((res) {
                                if (res.docs.isNotEmpty) {
                                  for (int i = 0; i < res.docs.length; i++) {
                                    DocumentSnapshot document = res.docs[i];
                                    Map<String, dynamic> data = document.data()!
                                    as Map<String, dynamic>;
                                    final PromoterGuest pg =
                                    Fresh.freshPromoterGuestMap(
                                        data, false);
                                    pg.copyWith(blocUserId: value.user!.uid);
                                    FirestoreHelper.pushPromoterGuest(pg);
                                  }
                                }
                              });

                              user = user.copyWith(
                                  id: value.user!.uid, fcmToken: fcmToken);
                              FirestoreHelper.pushUser(user);

                              UserPreferences.setUser(user);
                              Navigator.of(ctxDialog).pop();

                              LayoutUtils layoutUtils = LayoutUtils(context: context,
                                  blocServiceId: UserPreferences.myUser.blocServiceId);
                              layoutUtils.showTableSelectBottomSheet();

                              Logx.ist(_TAG, '👽 yo, welcome to the bloc community!');
                            } else {
                              Logx.i(_TAG,
                                  'user is not already registered in bloc, registering...');

                              blocUser.User registeredUser = Dummy.getDummyUser();
                              registeredUser.copyWith(
                                  id: value.user!.uid,
                                  phoneNumber: StringUtils.getInt(
                                      value.user!.phoneNumber!),
                                  fcmToken: fcmToken!);

                              UserPreferences.setUser(registeredUser);
                              Navigator.of(ctxDialog).pop();

                              LayoutUtils layoutUtils = LayoutUtils(context: context,
                                  blocServiceId: UserPreferences.myUser.blocServiceId);
                              layoutUtils.showTableSelectBottomSheet();

                              Logx.ist(_TAG, '👽 yo, welcome to the bloc community');
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
                          } else {
                            user = Fresh.freshUserMap(data, false);
                            user.fcmToken = fcmToken!;
                            FirestoreHelper.pushUser(user);
                          }
                          UserPreferences.setUser(user);

                          Navigator.of(ctxDialog).pop();

                          LayoutUtils layoutUtils = LayoutUtils(context: context,
                              blocServiceId: UserPreferences.myUser.blocServiceId);
                          layoutUtils.showTableSelectBottomSheet();

                          Logx.ist(_TAG,
                              'hey ${user.name.toLowerCase()}, welcome back! 🦖');
                        }
                      });
                    }
                  });
                } catch (e) {
                  Logx.em(_TAG, 'otp error $e');

                  String exception = e.toString();
                  if (exception.contains('session-expired')) {
                    Logx.ist(_TAG,'🤦 session got expired, trying again');
                    _verifyPhone(completePhoneNumber);
                    Navigator.pop(context);
                  } else {
                    Logx.ist(_TAG, '🫠 invalid otp, please try again');
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