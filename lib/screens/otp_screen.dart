import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/db/shared_preferences/ui_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/screens/profile/profile_add_edit_register_page.dart';
import 'package:bloc/utils/number_utils.dart';
import 'package:bloc/widgets/ui/countdown_timer.dart';
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
  String mPin = '';

  @override
  void initState() {
    _verifyPhone();

    super.initState();

    Logx.ilt(_TAG, 'your code\'s on the way 🚀🔑');
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  _verifyPhone() async {
    Logx.i(_TAG, '_verifyPhone');
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
                'verifyPhoneNumber: ${widget.phone} is verified. code: ${credential.smsCode!}');
            pinController.setText(credential.smsCode!);
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
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Constants.lightPrimary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Constants.background,
      body:
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
        Flexible(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/icons/logo-adaptive.png"),
                  fit: BoxFit.fitHeight),
            ),
          ),
        ),
        const Flexible(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  'In the heart of the city, we\'re serving up sunsets, summer vibes, and that urban oasis! 🌅🌴\n\n Our global feast, crafted by celebrity chef Ameya Mahajani, is a flavor explosion for your taste buds.\n\n Dr. Grace, our co-founder, infuses her passion into every dish and cocktail, creating unforgettable memories with each bite.\n\n At bloc, we\'re not just about food; we\'re the city\'s heartbeat for community, vibes, and epic music events that\'ll have you dancing into the night. \n\n Let\'s create unforgettable moments together! 🌐🎉🍹\n\n#blocCommunity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.lightPrimary,
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
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                    child: Text(
                  'enter the six digit code you received on \n${widget.phone}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Constants.lightPrimary,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                )),
                CountdownTimer(),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10, top: 2, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const DelayedDisplay(
                        delay: Duration(seconds: 9),
                        child: Text('didn\'t receive code. ',
                            style: TextStyle(
                              color: Constants.lightPrimary,
                              fontSize: 16,
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          Toaster.longToast(
                              'please wait, your otp code is being resent...');
                          _verifyPhone();
                        },
                        child: const DelayedDisplay(
                          delay: Duration(seconds: 15),
                          child: Text(
                            'resend?',
                            style: TextStyle(
                              color: Constants.primary,
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
          child: FractionallySizedBox(
              widthFactor: 1,
              child: OtpVerifyWidget(
                widget.phone,
              )),
        ),
        Flexible(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primary,
                  foregroundColor: Constants.darkPrimary,
                  shadowColor: Colors.white30,
                  elevation: 3,
                  minimumSize: const Size.fromHeight(50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: () {
                  _verifyOtpCode();
                },
                label: const Text(
                  'confirm',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                icon: const Icon(
                  Icons.rocket_launch_sharp,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  OtpVerifyWidget(String phone) {
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
              androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              separatorBuilder: (index) => const SizedBox(width: 8),
              closeKeyboardWhenCompleted: true,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              onCompleted: (pin) async {
                debugPrint('onCompleted: $pin');

                setState(() {
                  mPin = pin;
                });
                _verifyOtpCode();
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

  void _verifyOtpCode() async {
    Logx.ist(_TAG, '☎️ contacting HQ');

    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
              verificationId: _verificationCode, smsCode: mPin))
          .then((value) async {
        if (value.user != null) {
          Logx.i(_TAG, 'user is in firebase auth');

          String? fcmToken = '';
          if (!kIsWeb) {
            fcmToken = await FirebaseMessaging.instance.getToken();
          }

          Logx.i(
              _TAG, 'checking for bloc registration by id ${value.user!.uid}');

          await FirestoreHelper.pullUser(value.user!.uid).then((res) async {
            if (res.docs.isEmpty) {
              Logx.i(_TAG,
                  'checking for bloc registration by phone ${widget.phone}');

              int phoneNumber = StringUtils.getInt(widget.phone);
              await FirestoreHelper.pullUserByPhoneNumber(phoneNumber).then((res) async{
                if (res.docs.isNotEmpty) {
                  DocumentSnapshot document = res.docs[0];
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  blocUser.User user = Fresh.freshUserMap(data, true);

                  String oldUserDocId = user.id;
                  await FirestoreHelper.deleteUser(oldUserDocId);

                  await FirestoreHelper.pullPromoterGuestsByBlocUserId(user.id)
                      .then((res) {
                    if (res.docs.isNotEmpty) {
                      for (int i = 0; i < res.docs.length; i++) {
                        DocumentSnapshot document = res.docs[i];
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        PromoterGuest pg =
                            Fresh.freshPromoterGuestMap(data, false);
                        pg = pg.copyWith(blocUserId: value.user!.uid);
                        FirestoreHelper.pushPromoterGuest(pg);
                      }
                    }
                  });

                  user = user.copyWith(id: value.user!.uid);
                  user.lastSeenAt = Timestamp.now().millisecondsSinceEpoch;
                  if (UserPreferences.isUserLoggedIn()) {
                    if (kIsWeb) {
                      user = user.copyWith(
                          isAppUser: false, appVersion: Constants.appVersion);
                    } else {
                      user = user.copyWith(
                          isAppUser: true,
                          appVersion: Constants.appVersion,
                          isIos:
                              Theme.of(context).platform == TargetPlatform.iOS,
                          fcmToken: fcmToken);
                    }
                  }

                  if (user.username.isEmpty) {
                    String username = '';
                    if (user.surname.trim().isNotEmpty) {
                      username =
                          '${user.name.trim().toLowerCase()}_${user.surname.trim().toLowerCase()}';
                    } else {
                      username = user.name.trim().toLowerCase();
                    }

                    //check if username is present in db
                    await FirestoreHelper.pullUserByUsername(username).then((res) {
                      if (res.docs.isNotEmpty) {
                        // username is already taken
                        username = username +
                            NumberUtils.getRandomNumber(1, 999).toString();
                        user = user.copyWith(username: username);
                        FirestoreHelper.pushUser(user);
                        UserPreferences.setUser(user);
                        UiPreferences.setHomePageIndex(0);

                        Logx.ist(_TAG, '👽 yo, welcome to the bloc community!');
                      } else {
                        user = user.copyWith(username: username);
                        FirestoreHelper.pushUser(user);
                        UserPreferences.setUser(user);
                        UiPreferences.setHomePageIndex(0);

                        Logx.ist(_TAG, '👽 yo, welcome to the bloc community!');
                      }
                    });
                  } else {
                    FirestoreHelper.pushUser(user);
                    UserPreferences.setUser(user);
                    UiPreferences.setHomePageIndex(0);

                    Logx.ist(_TAG, '👽 yo, welcome to the bloc community!');
                  }
                } else {
                  Logx.i(_TAG,
                      'user is not already registered in bloc, registering...');

                  blocUser.User registeredUser = Dummy.getDummyUser();
                  registeredUser = registeredUser.copyWith(
                      id: value.user!.uid,
                      phoneNumber: StringUtils.getInt(value.user!.phoneNumber!),
                      fcmToken: fcmToken!);

                  if (kIsWeb) {
                    registeredUser = registeredUser.copyWith(
                        isAppUser: false, appVersion: Constants.appVersion);
                  } else {
                    registeredUser = registeredUser.copyWith(
                        isAppUser: true,
                        appVersion: Constants.appVersion,
                        isIos:
                            Theme.of(context).platform == TargetPlatform.iOS);
                  }

                  await FirestoreHelper.pushUser(registeredUser);
                  UserPreferences.setUser(registeredUser);
                  UiPreferences.setHomePageIndex(0);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => ProfileAddEditRegisterPage(
                            user: registeredUser, task: 'register')),
                  );
                }
              });
            } else {
              Logx.i(_TAG, 'user is a bloc member. navigating to main...');

              DocumentSnapshot document = res.docs[0];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              blocUser.User user;
              if (kIsWeb) {
                user = Fresh.freshUserMap(data, true);
                user = user.copyWith(
                    isAppUser: false, appVersion: Constants.appVersion);
              } else {
                user = Fresh.freshUserMap(data, false);
                user = user.copyWith(
                    isAppUser: true,
                    appVersion: Constants.appVersion,
                    isIos: Theme.of(context).platform == TargetPlatform.iOS,
                    fcmToken: fcmToken!);
              }

              user.lastSeenAt = Timestamp.now().millisecondsSinceEpoch;

              if (user.username.isEmpty) {
                String username = '';
                if (user.surname.trim().isNotEmpty) {
                  username =
                      '${user.name.trim().toLowerCase()}_${user.surname.trim().toLowerCase()}';
                } else {
                  username = user.name.trim().toLowerCase();
                }

                //check if username is present in db
                await FirestoreHelper.pullUserByUsername(username).then((res) {
                  if (res.docs.isNotEmpty) {
                    // username is already taken
                    username = username +
                        NumberUtils.getRandomNumber(1, 999).toString();
                    user = user.copyWith(username: username);
                    FirestoreHelper.pushUser(user);
                    UserPreferences.setUser(user);
                  } else {
                    user = user.copyWith(username: username);
                    FirestoreHelper.pushUser(user);
                    UserPreferences.setUser(user);
                  }
                });
              } else {
                await FirestoreHelper.pushUser(user);
                await UserPreferences.setUser(user);
              }

              UiPreferences.setHomePageIndex(0);
              Toaster.shortToast(
                  'yo ${user.name.toLowerCase()}, welcome back! 🦖');

              GoRouter.of(context).go('/');
            }
          });
        }
      });
    } catch (e) {
      Logx.em(_TAG, 'otp error $e');

      String exception = e.toString();
      if (exception.contains('session-expired')) {
        Toaster.longToast('session got expired, trying again.');
        _verifyPhone();
      } else if (exception.contains('channel-error')) {
        Logx.em(_TAG, exception.toString());
        Toaster.longToast('🐵 Authentication server\'s taking a banana break. Try again and swing back in!');

        GoRouter.of(context).go('/login/true');
      } else {
        Logx.est(_TAG, 'invalid otp. please try again.');
      }
      FocusScope.of(context).unfocus();
    }
  }
}
