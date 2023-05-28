import 'package:bloc/screens/otp_screen.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;

import 'package:bloc/screens/ui/splash_screen.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../utils/logx.dart';
import '../utils/string_utils.dart';
import '../widgets/ui/toaster.dart';
import 'main_screen.dart';

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
  bool isIOS = false;
  int maxPhoneNumberLength = 10;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomInset : false,
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          Logx.i(_TAG, 'checking for auth state changes...');

          if (userSnapshot.connectionState == ConnectionState.waiting) {
            if (!kIsWeb) {
              return SplashScreen();
            } else {
              return const LoadingWidget();
            }
          }

          Logx.i(_TAG, 'user snapshot received');

          if (userSnapshot.hasData) {
            Logx.i(_TAG, 'user snapshot has data');

            final user = FirebaseAuth.instance.currentUser;

            CollectionReference users = FirestoreHelper.getUsersCollection();

            if (user!.uid.isEmpty || widget.shouldTriggerSkip == false) {
              Logx.i(_TAG, 'user snapshot uid is empty');
              return signInWidget();
            } else {
              return FutureBuilder<DocumentSnapshot>(
                future: users.doc(user.uid).get(),
                builder: (BuildContext ctx,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget();
                  }

                  if (snapshot.hasError) {
                    Logx.em(
                        _TAG,
                        'user snapshot has error: ${snapshot.error}');
                    return signInWidget();
                  }

                  if (snapshot.hasData && !snapshot.data!.exists) {
                    Logx.i(_TAG,
                        'user snapshot has data but not registered in bloc ');
                    // user not registered in bloc, will be picked up in OTP screen
                    return signInWidget();
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final blocUser.User user = Fresh.freshUserMap(data, true);
                    UserPreferences.setUser(user);

                    return MainScreen(user: user);
                  }
                  Logx.i(_TAG, 'loading user...');
                  return const LoadingWidget();
                },
              );
            }
          } else {
            if (widget.shouldTriggerSkip) {
              _verifyUsingSkipPhone();
              return const LoadingWidget();
            } else {
              return signInWidget();
            }
          }
        },
      ),
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
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
              decoration: InputDecoration(
                  labelText: 'phone number',
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                  counterStyle:
                      TextStyle(color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 0.0),
                  )),
              controller: _controller,
              initialCountryCode: 'IN',
              dropdownTextStyle: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
              pickerDialogStyle: PickerDialogStyle(
                  backgroundColor: Theme.of(context).primaryColor),
              onChanged: (phone) {
                Logx.i(_TAG, phone.completeNumber);
                completePhoneNumber = phone.completeNumber;

                if(phone.number.length == maxPhoneNumberLength){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OTPScreen(completePhoneNumber)));
                }
              },
              onCountryChanged: (country) {
                Logx.i(_TAG, 'country changed to: ' + country.name);
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
                      Toaster.longToast('loading menu and events');
                      _verifyUsingSkipPhone();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DelayedDisplay(
                        delay: const Duration(seconds: 3),
                        child: Text(
                          "skip for now",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
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
            margin: const EdgeInsets.only(left: 20, right: 20),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shadowColor: Theme.of(context).shadowColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                minimumSize: const Size(100, 60),
              ),
              onPressed: () {
                if (completePhoneNumber.isNotEmpty) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OTPScreen(completePhoneNumber)));
                } else {
                  Logx.i(
                      _TAG,
                      'user entered invalid phone number $completePhoneNumber');
                  Toaster.longToast('please enter a valid phone number');
                }
              },
              child: const Text(
                'next',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shadowColor: Theme.of(context).shadowColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                minimumSize: const Size(100, 60),
              ),
              onPressed: () {
                _logInWithFacebook();
              },
              child: const Text(
                'facebook',
                style: TextStyle(fontSize: 20),
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
            .signInWithPhoneNumber('${phone}', null)
            .then((user) {
          debugPrint('signInWithPhoneNumber: user verification id ${user.verificationId}');

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
              print(
                  'verifyPhoneNumber: ${phone} is verified. attempting sign in with credentials...');
              await FirebaseAuth.instance
                  .signInWithCredential(credential)
                  .then((value) async {
                if (value.user != null) {
                  Logx.i(_TAG,'signInWithCredential: success. user logged in');
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
      }
    }
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
            Logx.i(_TAG,
                "successfully retrieved bloc user for id ${value.user!.uid}");

            if (res.docs.isEmpty) {
              Logx.i(_TAG,
                  'user is not already registered in bloc, registering...');

              blocUser.User registeredUser = Dummy.getDummyUser();
              registeredUser.id = value.user!.uid;
              registeredUser.phoneNumber =
                  StringUtils.getInt(value.user!.phoneNumber!);

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MainScreen(user: registeredUser)));
            } else {
              Logx.i(_TAG, 'user is a bloc member. navigating to main...');
              try {
                DocumentSnapshot document = res.docs[0];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                final blocUser.User user = Fresh.freshUserMap(data, false);
                UserPreferences.setUser(user);

                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => MainScreen(user: user)));
              } on PlatformException catch (e, s) {
                Logx.e(_TAG, e, s);
              } on Exception catch (e, s) {
                Logx.e(_TAG, e, s);
              } catch (e) {
                logger.e(e);
              }
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
      FocusScope.of(context).unfocus();
    }
  }
}
