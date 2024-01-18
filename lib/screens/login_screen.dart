import 'package:bloc/screens/otp_screen.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;

import 'package:bloc/screens/ui/splash_screen.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../routes/route_constants.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import '../utils/string_utils.dart';
import '../widgets/ui/toaster.dart';

class LoginScreen extends StatefulWidget {
  final bool shouldTriggerSkip;

  const LoginScreen({Key? key, required this.shouldTriggerSkip})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _TAG = 'LoginScreen';

  final TextEditingController _controller = TextEditingController();
  String completePhoneNumber = '';
  int maxPhoneNumberLength = 10;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();

    if(widget.shouldTriggerSkip){
      _verifyUsingSkipPhone();
    }
  }

  @override
  Widget build(BuildContext context) {
    Logx.d(_TAG, 'login screen: trigger skip ${widget.shouldTriggerSkip}');

    return Scaffold(
      backgroundColor: Constants.background,
      resizeToAvoidBottomInset: false,
      body: widget.shouldTriggerSkip ? const LoadingWidget(): signInWidget()
    );
  }

  Widget signInWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 3,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/icons/logo-adaptive.png"),
                  fit: BoxFit.fitHeight),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(top: 0, right: 20, left: 20),
            child: IntlPhoneField(
              style: const TextStyle(color: Constants.primary, fontSize: 20),
              decoration: const InputDecoration(
                  labelText: 'phone number',
                  labelStyle: TextStyle(color: Constants.primary),
                  hintStyle: TextStyle(color: Constants.primary),
                  counterStyle: TextStyle(color: Constants.primary),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.lightPrimary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide:
                        BorderSide(color: Constants.primary, width: 0.0),
                  )),
              controller: _controller,
              initialCountryCode: 'IN',
              dropdownTextStyle:
                  const TextStyle(color: Constants.primary, fontSize: 20),
              pickerDialogStyle:
                  PickerDialogStyle(backgroundColor: Constants.primary),
              onChanged: (phone) {
                completePhoneNumber = phone.completeNumber;

                if (phone.number.length == maxPhoneNumberLength) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OTPScreen(completePhoneNumber)));
                }
              },
              onCountryChanged: (country) {
                Logx.i(_TAG, 'country changed to: ${country.name}');
                maxPhoneNumberLength = country.maxLength;
              },
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Column(
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      _verifyUsingSkipPhone();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DelayedDisplay(
                        delay: Duration(seconds: 3),
                        child: Text(
                          "skip for now",
                          style:
                              TextStyle(color: Constants.primary, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                  if (completePhoneNumber.isNotEmpty) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OTPScreen(completePhoneNumber)));
                  } else {
                    Logx.i(_TAG,
                        'user entered invalid phone number $completePhoneNumber');
                    Logx.ilt(_TAG, 'please enter a valid phone number');
                  }
                },
                label: const Text(
                  'next',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                icon: const Icon(
                  Icons.moped_sharp,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _verifyUsingSkipPhone() async {
    Logx.i(_TAG, '_verifyUsingSkipPhone');
    String phone = '+911234567890';

    if (kIsWeb) {
      try {
        await FirebaseAuth.instance
            .signInWithPhoneNumber(phone, null)
            .then((user) {
          signInToSkipBloc(user.verificationId);
        }).catchError((e) {
          Logx.em(_TAG, e.toString());
        });
      } on PlatformException catch (e, s) {
        Logx.e(_TAG, e, s);
      } on Exception catch (e, s) {
        Logx.e(_TAG, e, s);
      } catch (e) {
        logger.e(e);
      }
    } else {
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phone,
            verificationCompleted: (PhoneAuthCredential credential) async {
              Logx.i(_TAG,
                  'verifyPhoneNumber: $phone is verified. attempting sign in with credentials...');
              await FirebaseAuth.instance
                  .signInWithCredential(credential)
                  .then((value) async {
                if (value.user != null) {
                  Logx.i(_TAG, 'signInWithCredential: success. user logged in');
                }
              });
            },
            verificationFailed: (FirebaseAuthException e) {
              Logx.em(_TAG, e.message.toString());
            },
            codeSent: (String verificationID, int? resendToken) {
              signInToSkipBloc(verificationID);
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              signInToSkipBloc(verificationId);
            },
            timeout: const Duration(seconds: 120));
      } on PlatformException catch (e, s) {
        Logx.e(_TAG, e, s);
      } on Exception catch (e, s) {
        Logx.e(_TAG, e, s);
      } catch (e) {
        logger.e(e);
        Toaster.longToast('login failed. error: $e');
      }
    }

    return const LoadingWidget();
  }

  void signInToSkipBloc(String verificationId) async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: '123456'))
          .then((value) async {
        if (value.user != null) {
          Logx.i(_TAG,
              'user is in firebase auth. checking for bloc registration...');

          FirestoreHelper.pullUser(value.user!.uid).then((res) {
            if (res.docs.isEmpty) {
              Logx.i(
                  _TAG, 'user is not already registered in bloc, registering');

              blocUser.User registeredUser = Dummy.getDummyUser();
              registeredUser.id = value.user!.uid;
              registeredUser.phoneNumber =
                  StringUtils.getInt(value.user!.phoneNumber!);

              UserPreferences.setUser(registeredUser);

              GoRouter.of(context)
                  .pushReplacementNamed(RouteConstants.landingRouteName);
            } else {
              Logx.i(_TAG, 'user is a bloc member, navigating to main');
              try {
                DocumentSnapshot document = res.docs[0];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                final blocUser.User user = Fresh.freshUserMap(data, false);
                UserPreferences.setUser(user);

                if(mounted) {
                  GoRouter.of(context)
                      .pushReplacementNamed(RouteConstants.landingRouteName);
                }
              } on PlatformException catch (e, s) {
                Logx.e(_TAG, e, s);
              } on Exception catch (e, s) {
                Logx.e(_TAG, e, s);
              } catch (e) {
                logger.e(e);
                Logx.ist(_TAG, 'connection failed, please try signing in again.');
                GoRouter.of(context)
                    .pushReplacementNamed(RouteConstants.loginRouteName, pathParameters: {
                  'skip': 'true',
                });              }
            }
          });
        }
      });
    } on PlatformException catch (e, s) {
      Logx.e(_TAG, e, s);
    } on Exception catch (e, s) {
      Logx.e(_TAG, e, s);
    } catch (e) {
      logger.e(e);
      Toaster.longToast('auto login failed with error: $e');
      FocusScope.of(context).unfocus();
    }
  }
}
