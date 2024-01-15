import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_tix_tier.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/user.dart' as blocUser;
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/parties/party_banner.dart';
import '../../widgets/tix/party_tix_tier_item.dart';
import '../../widgets/tix/buy_tix_tier_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/dark_button_widget.dart';
import '../../widgets/ui/dark_textfield_widget.dart';
import '../../widgets/ui/textfield_widget.dart';
import 'tix_checkout_screen.dart';

class TixBuyEditScreen extends StatefulWidget {
  Tix tix;
  String task;

  TixBuyEditScreen({key, required this.tix, required this.task})
      : super(key: key);

  @override
  State<TixBuyEditScreen> createState() => _TixBuyEditScreenState();
}

class _TixBuyEditScreenState extends State<TixBuyEditScreen> {
  static const String _TAG = 'TixBuyEditScreen';

  late Party mParty;
  var _isPartyLoading = true;

  List<PartyTixTier> mPartyTixTiers = [];
  var _isPartyTixTiersLoading = true;
  double mPrice = 0;

  List<TixTier> mTixTiers = [];

  // log in
  late blocUser.User mUser;
  String completePhoneNumber = '';
  int maxPhoneNumberLength = 10;
  String _verificationCode = '';

  final TextEditingController _controller = TextEditingController();
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  String _sGender = 'male';
  List<String> genders = [
    'male',
    'female',
    'transgender',
    'non-binary/non-conforming',
    'prefer not to respond'
  ];

  bool testMode = false;

  @override
  void initState() {
    mUser = UserPreferences.getUser();

    FirestoreHelper.pushTix(widget.tix);

    FirestoreHelper.pullParty(widget.tix.partyId).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        final Party party = Fresh.freshPartyMap(data, false);
        mParty = party;

        setState(() {
          _isPartyLoading = false;
        });
      } else {
        //party not found.
        Logx.ist(_TAG, 'party could not be found');
        Navigator.of(context).pop();
      }
    });

    FirestoreHelper.pullPartyTixTiers(widget.tix.partyId).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyTixTier partyTixTier =
              Fresh.freshPartyTixTierMap(data, false);
          mPartyTixTiers.add(partyTixTier);
        }
        setState(() {
          _isPartyTixTiersLoading = false;
        });
      } else {
        //tix tiers are not defined
        setState(() {
          _isPartyTixTiersLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      appBar: AppBar(
        title: AppBarTitle(title: 'buy tix'),
        titleSpacing: 0,
        backgroundColor: Constants.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            if (widget.task == 'buy') {
              for (String tixTierId in widget.tix.tixTierIds) {
                FirestoreHelper.deleteTixTier(tixTierId);
              }
              FirestoreHelper.deleteTix(widget.tix.id);
              Logx.d(_TAG, 'tix deleted from firebase');
            }

            if (kIsWeb) {
              GoRouter.of(context).pushNamed(RouteConstants.eventRouteName,
                  pathParameters: {
                    'partyName': mParty.name,
                    'partyChapter': mParty.chapter
                  });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartyLoading && _isPartyTixTiersLoading
        ? const LoadingWidget()
        : Stack(
            children: [
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  PartyBanner(
                    party: mParty,
                    isClickable: false,
                    shouldShowButton: false,
                    isGuestListRequested: false,
                    shouldShowInterestCount: false,
                  ),
                  widget.task == 'buy'
                      ? _showBuyTixTiers(context)
                      : _showTixTiers(context),
                  const SizedBox(
                    height: 70,
                  ),
                ],
              ),
              // Floating Container at the bottom
              Positioned(
                  left: 0, right: 0, bottom: 0, child: _loadTixTiers(context)),
            ],
          );
  }

  _showBuyTixTiers(BuildContext context) {
    return SizedBox(
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: mPartyTixTiers.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            PartyTixTier partyTixTier = mPartyTixTiers[index];

            return PartyTixTierItem(
              partyTixTier: partyTixTier,
              tixId: widget.tix.id,
            );
          }),
    );
  }

  _showTixTiers(BuildContext context) {
    if (widget.tix.tixTierIds.isNotEmpty) {
      FirestoreHelper.pullTixTiers(widget.tix.partyId).then((res) {
        if (res.docs.isNotEmpty) {
          List<TixTier> tixTiers = [];
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final TixTier tixTier = Fresh.freshTixTierMap(data, false);

            if (widget.tix.tixTierIds.contains(tixTier.id)) {
              tixTiers.add(tixTier);
            }
          }

          return SizedBox(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: tixTiers.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (ctx, index) {
                  TixTier tixTier = tixTiers[index];

                  return BuyTixTierItem(
                    tixTier: tixTier,
                  );
                }),
          );
        } else {
          Logx.em(_TAG, 'no tix tiers found for ${widget.tix.partyId}');
        }
      });
    } else {
      return const Center(
          child: Text(
        'pricing tier is not revealed yet!',
        style: TextStyle(color: Constants.primary),
      ));
    }
  }

  _loadTixTiers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getTixTiers(widget.tix.id),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                if (snapshot.data!.docs.isNotEmpty) {
                  mPrice = 0;

                  try {
                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      DocumentSnapshot document = snapshot.data!.docs[i];
                      Map<String, dynamic> map =
                          document.data()! as Map<String, dynamic>;
                      final TixTier tixTier = Fresh.freshTixTierMap(map, false);
                      mTixTiers.add(tixTier);

                      mPrice += tixTier.tixTierCount * tixTier.tixTierPrice;
                    }
                    return _showTixPriceProceed(context);
                  } on Exception catch (e, s) {
                    Logx.e(_TAG, e, s);
                  } catch (e) {
                    Logx.em(_TAG, 'error loading tix tiers : $e');
                  }
                } else {
                  return _showTixPriceProceed(context);
                }
              }
          }
          return const LoadingWidget();
        });
  }

  _showTixPriceProceed(BuildContext context) {
    return Container(
      color: Constants.primary,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'total  \u20B9 ${mPrice.toStringAsFixed(0)}',
          ),
          DarkButtonWidget(
            text: 'proceed',
            onClicked: () async {
              if (UserPreferences.isUserLoggedIn()) {
                _handlePurchaseTicket();
              } else {
                Logx.d(_TAG, 'user is not logged in. logging them in...');

                _showPhoneNumberEnterDialog(context);
              }
            },
          )
        ],
      ),
    );
  }

  void _handlePurchaseTicket() {
    if(!kIsWeb){
      if (mPrice > 0) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => TixCheckoutScreen(
                tix: widget.tix,
                party: mParty,
              )),
        );
      } else {
        Logx.ilt(_TAG, 'please select a ticket to purchase');
      }
    } else {
      if(UserPreferences.isUserLoggedIn()){
        widget.tix = widget.tix.copyWith(
          total: mPrice,
            userId: mUser.id,
            userPhone: mUser.phoneNumber.toString(),
            userEmail: mUser.email,
            userName: mUser.username,
            result: 'purchase pending: user is in web mode');
        FirestoreHelper.pushTix(widget.tix);
      }

      DialogUtils.showDownloadAppTixDialog(context);
    }
  }

  _showPhoneNumberEnterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text(
            '🎩 sign in',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            width: double.maxFinite,
            height: 130,
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'phone number',
                          style: TextStyle(
                              color: Constants.darkPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IntlPhoneField(
                        style: const TextStyle(
                            color: Constants.darkPrimary, fontSize: 18),
                        decoration: const InputDecoration(
                            labelText: '',
                            labelStyle: TextStyle(color: Constants.darkPrimary),
                            hintStyle: TextStyle(color: Constants.darkPrimary),
                            counterStyle:
                                TextStyle(color: Constants.darkPrimary),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Constants.darkPrimary),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Constants.darkPrimary, width: 0.0),
                            )),
                        controller: _controller,
                        initialCountryCode: 'IN',
                        dropdownTextStyle: const TextStyle(
                            color: Constants.darkPrimary, fontSize: 18),
                        pickerDialogStyle: PickerDialogStyle(
                            backgroundColor: Constants.primary),
                        onChanged: (phone) {
                          Logx.i(_TAG, phone.completeNumber);
                          completePhoneNumber = phone.completeNumber;

                          if (phone.number.length == maxPhoneNumberLength) {
                            Navigator.of(context).pop();
                            _verifyPhone();
                          }
                        },
                        onCountryChanged: (country) {
                          Logx.i(_TAG, 'country changed to: ${country.name}');
                          maxPhoneNumberLength = country.maxLength;
                        },
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Constants.darkPrimary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _verifyPhone();
              },
              child: const Text('👍 continue',
                  style: TextStyle(color: Constants.primary)),
            ),
          ],
        );
      },
    );
  }

  void _verifyPhone() async {
    Logx.i(_TAG, '_verifyPhone: registering $completePhoneNumber');
    Logx.ilt(_TAG, 'verifying $completePhoneNumber ...');

    if (kIsWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber(completePhoneNumber, null)
          .then((firebaseUser) {
        Logx.i(_TAG,
            'signInWithPhoneNumber: user verification id ${firebaseUser.verificationId}');

        _handleContinueLogin();

        setState(() {
          _verificationCode = firebaseUser.verificationId;
        });
      }).catchError((e, s) {
        Logx.e(_TAG, e, s);
      });
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: completePhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            Logx.i(_TAG,
                'verifyPhoneNumber: $completePhoneNumber is verified. signing in with credentials...');
          },
          verificationFailed: (FirebaseAuthException e) {
            Logx.em(_TAG, 'verificationFailed $e');
          },
          codeSent: (String verificationID, int? resendToken) {
            Logx.i(_TAG, 'verification id : $verificationID');

            _handleContinueLogin();

            setState(() {
              _verificationCode = verificationID;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() {
              _verificationCode = verificationId;
            });
          },
          timeout: const Duration(seconds: 60));
    }
  }

  void _handleContinueLogin() {
    int phoneNumber = StringUtils.getInt(completePhoneNumber);

    Logx.i(_TAG, 'checking for bloc registration, phone: $phoneNumber');

    FirestoreHelper.pullUserByPhoneNumber(phoneNumber).then((res) {
      if (res.docs.isNotEmpty) {
        // user is already registered
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        blocUser.User user = Fresh.freshUserMap(data, true);

        setState(() {
          mUser = user;
          Logx.d(_TAG,
              'bloc registration found for $phoneNumber: ${mUser.name} ${mUser.surname}');
        });

        _showOTPDialog();
      } else {
        // user is not registered
        blocUser.User user = Dummy.getDummyUser();

        setState(() {
          mUser = user;
          Logx.d(_TAG, 'bloc registration not found for $phoneNumber');
        });

        _showOTPDialog();
      }
    });
  }

  _showOTPDialog() {
    const focusedBorderColor = Color.fromRGBO(42, 33, 26, 1);
    const fillColor = Color.fromRGBO(38, 50, 56, 1.0);
    const borderColor = Color.fromRGBO(42, 33, 26, 1);

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

    bool isRegisteredUser = mUser.phoneNumber != 0;
    // if (testMode) {
    //   isRegisteredUser = false;
    // }

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            isRegisteredUser ? '💂 enter one-time password' : '🧞 register & purchase',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Colors.black),
          ),
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(19.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            width: double.maxFinite,
            height: !isRegisteredUser ? 340 : 120,
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !isRegisteredUser
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10,
                                      bottom: 10 ),
                                  child: TextFieldWidget(
                                    label: 'name *',
                                    text: mUser.name,
                                    onChanged: (text) {
                                      mUser = mUser.copyWith(name: text);
                                    },
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),

                      !isRegisteredUser ?
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'gender *',
                                    style: TextStyle(
                                        color: Constants.darkPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            FormField<String>(
                              builder: (FormFieldState<String> state) {
                                return InputDecorator(
                                  key: const ValueKey('gender_dropdown'),
                                  decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      errorStyle: const TextStyle(
                                          color: Constants.errorColor, fontSize: 16.0),
                                      hintText: 'please select gender',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(19.0),
                                        borderSide:
                                        const BorderSide(color: Constants.darkPrimary),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Constants.darkPrimary, width: 0.0),
                                      )),
                                  isEmpty: _sGender == '',
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      style: const TextStyle(
                                          color: Constants.darkPrimary),
                                      dropdownColor: Constants.primary,
                                      value: _sGender,
                                      isDense: true,
                                      onChanged: (String? newValue) {
                                        _sGender = newValue!;
                                        mUser = mUser.copyWith(gender: _sGender);
                                        state.didChange(newValue);
                                      },
                                      items: genders.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                      ),
                        ): const SizedBox(),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'otp',
                          style: TextStyle(
                              color: Constants.darkPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Form(
                        key: GlobalKey<FormState>(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Directionality(
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
                                hapticFeedbackType:
                                    HapticFeedbackType.lightImpact,
                                onCompleted: (pin) async {
                                  debugPrint('onCompleted: $pin');

                                  try {
                                    await FirebaseAuth.instance
                                        .signInWithCredential(
                                            PhoneAuthProvider.credential(
                                                verificationId:
                                                    _verificationCode,
                                                smsCode: pin))
                                        .then((value) async {
                                      if (value.user != null) {
                                        Logx.i(_TAG,
                                            '$completePhoneNumber is in firebase auth');

                                        if (!isRegisteredUser) {
                                          Logx.d(_TAG,
                                              'user is not registered, registering...');

                                          mUser = mUser.copyWith(
                                            id: value.user!.uid,
                                            phoneNumber: StringUtils.getInt(completePhoneNumber),
                                          );

                                          if (kIsWeb) {
                                            mUser = mUser.copyWith(
                                                isAppUser: false);
                                          } else {
                                            mUser = mUser.copyWith(
                                              isAppUser: true,
                                              appVersion: Constants.appVersion,
                                              isIos:
                                                  Theme.of(context).platform ==
                                                      TargetPlatform.iOS,
                                            );
                                          }

                                          if (!testMode) {
                                            FirestoreHelper.pushUser(mUser);
                                            Logx.i(_TAG,
                                                'registered user ${mUser.name} ${mUser.surname}');

                                            UserPreferences.setUser(mUser);
                                          }

                                          Navigator.of(context).pop();
                                          _handlePurchaseTicket();
                                        } else {
                                          Logx.d(_TAG,
                                              'user is registered. ${mUser.name} ${mUser.phoneNumber}');

                                          int time = Timestamp.now().millisecondsSinceEpoch;
                                          mUser = mUser.copyWith(lastSeenAt: time);

                                          if (kIsWeb) {
                                            mUser = mUser.copyWith(
                                                isAppUser: false);
                                          } else {
                                            mUser = mUser.copyWith(
                                              isAppUser: true,
                                              appVersion: Constants.appVersion,
                                              isIos:
                                                  Theme.of(context).platform ==
                                                      TargetPlatform.iOS,
                                            );
                                          }

                                          if (!testMode) {
                                            FirestoreHelper.pushUser(mUser);
                                            Logx.i(_TAG,
                                                'registered user ${mUser.name} ${mUser.surname}');

                                            UserPreferences.setUser(mUser);
                                          }

                                          Navigator.of(context).pop();
                                          _handlePurchaseTicket();
                                        }
                                      } else {
                                        Logx.em(_TAG,
                                            'firebase auth sign in with creds returned user null');

                                        String title = '🤷 sign in failed';
                                        String message =
                                            'unfortunately, the sign in was not successful . please try again 🫠';
                                        DialogUtils.showTextDialog(
                                            context, title, message);

                                        Navigator.of(context).pop();
                                      }
                                    });
                                  } catch (e) {
                                    Logx.em(_TAG, 'otp error $e');

                                    String exception = e.toString();
                                    if (exception.contains('session-expired')) {
                                      Logx.ist(_TAG,
                                          'session got expired, trying again');
                                      _verifyPhone();
                                    } else {
                                      Logx.ist(_TAG,
                                          'invalid otp, please try again');
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
                                  decoration:
                                      defaultPinTheme.decoration!.copyWith(
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: focusedBorderColor),
                                  ),
                                ),
                                submittedPinTheme: defaultPinTheme.copyWith(
                                  decoration:
                                      defaultPinTheme.decoration!.copyWith(
                                    color: fillColor,
                                    borderRadius: BorderRadius.circular(19),
                                    border:
                                        Border.all(color: focusedBorderColor),
                                  ),
                                ),
                                errorPinTheme: defaultPinTheme.copyBorderWith(
                                  border: Border.all(color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('close',
                  style: TextStyle(color: Constants.darkPrimary)),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Constants.darkPrimary),
              ),
              onPressed: () {
                Navigator.of(context).pop();

                _handlePurchaseTicket();
              },
              child: const Text('🎫 purchase',
                  style: TextStyle(color: Constants.primary)),
            ),
          ],
        );
      },
    );
  }
}
