import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/user.dart' as blocUser;
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/dark_textfield_widget.dart';
import '../../widgets/parties/party_banner.dart';
import '../main_screen.dart';

class PartyGuestAddEditManagePage extends StatefulWidget {
  PartyGuest partyGuest;
  Party party;
  String task;

  PartyGuestAddEditManagePage(
      {key, required this.partyGuest, required this.party, required this.task})
      : super(key: key);

  @override
  _PartyGuestAddEditManagePageState createState() =>
      _PartyGuestAddEditManagePageState();
}

class _PartyGuestAddEditManagePageState
    extends State<PartyGuestAddEditManagePage> {
  static const String _TAG = 'PartyGuestAddEditPage';

  late blocUser.User bloc_user;

  bool isPhotoChanged = false;

  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  bool hasUserChanged = false;
  bool isCustomerLoading = true;

  late String sGuestCount;
  List<String> guestCounts = [];

  String sGuestStatus = 'couple';
  List<String> guestStatuses = ['couple', 'ladies', 'lgbtq+'];

  String sGender = 'male';
  List<String> genders = [
    'male',
    'female',
    'transgender',
    'non-binary/non-conforming',
    'prefer not to respond'
  ];

  bool isLoggedIn = false;
  String _verificationCode = '';
  TextEditingController _controller = TextEditingController();
  String completePhoneNumber = '';
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    bloc_user = Dummy.getDummyUser();

    FirestoreHelper.pullUser(widget.partyGuest.guestId).then((res) {
      print('successfully pulled in user');

      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
        final blocUser.User _user = Fresh.freshUserMap(map, true);

        setState(() {
          if (_user.phoneNumber == Constants.skipPhoneNumber) {
            //user will be the dummy
            isLoggedIn = false;
          } else {
            bloc_user = _user;
            isLoggedIn = true;
          }
          isCustomerLoading = false;
        });
      } else {
        setState(() {
          isLoggedIn = false;
          isCustomerLoading = false;
        });
      }
    });

    for (int i = 1; i <= widget.party.guestListCount; i++) {
      guestCounts.add(i.toString());
    }
    sGuestCount = widget.partyGuest.guestsCount.toString();
    sGuestStatus = widget.partyGuest.guestStatus;
    sGender = widget.partyGuest.gender;
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('party guest | ${widget.task}'),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return isCustomerLoading
        ? const LoadingWidget()
        : ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              PartyBanner(
                party: widget.party,
                isClickable: false,
                shouldShowButton: false,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: DarkTextFieldWidget(
                  label: 'name \*',
                  text: bloc_user.name,
                  onChanged: (name) {
                    bloc_user = bloc_user.copyWith(name: name);
                    hasUserChanged = true;

                    widget.partyGuest = widget.partyGuest.copyWith(name: name);
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: DarkTextFieldWidget(
                  label: 'surname \*',
                  text: bloc_user.surname,
                  onChanged: (surname) {
                    bloc_user = bloc_user.copyWith(surname: surname);
                    hasUserChanged = true;

                    widget.partyGuest =
                        widget.partyGuest.copyWith(surname: surname);
                  },
                ),
              ),
              widget.task == 'manage'
                  ? Column(
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: DarkTextFieldWidget(
                            label: 'phone number \*',
                            text: bloc_user.phoneNumber.toString(),
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              !isLoggedIn
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'phone number \*',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            child: IntlPhoneField(
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18),
                              decoration: InputDecoration(
                                  labelText: '',
                                  labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  hintStyle: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  counterStyle: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 0.0),
                                  )),
                              controller: _controller,
                              initialCountryCode: 'IN',
                              dropdownTextStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18),
                              pickerDialogStyle: PickerDialogStyle(
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                              onChanged: (phone) {
                                Logx.i(_TAG, phone.completeNumber);
                                completePhoneNumber = phone.completeNumber;
                              },
                              onCountryChanged: (country) {
                                Logx.i(_TAG,
                                    'country changed to: ' + country.name);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: DarkTextFieldWidget(
                    label: 'email${widget.party.isEmailRequired ? ' \*' : ''}',
                    text: bloc_user.email,
                    onChanged: (email) {
                      bloc_user = bloc_user.copyWith(email: email);
                      hasUserChanged = true;

                      widget.partyGuest =
                          widget.partyGuest.copyWith(email: email);
                    }),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'gender \*',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
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
                              errorStyle: TextStyle(
                                  color: Theme.of(context).errorColor,
                                  fontSize: 16.0),
                              hintText: 'please select gender',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 0.0),
                              )),
                          isEmpty: sGender == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight),
                              dropdownColor: Theme.of(context).backgroundColor,
                              value: sGender,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  sGender = newValue!;

                                  bloc_user =
                                      bloc_user.copyWith(gender: sGender);
                                  hasUserChanged = true;

                                  widget.partyGuest = widget.partyGuest
                                      .copyWith(gender: sGender);
                                  state.didChange(newValue);
                                });
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
              ),
              const SizedBox(height: 24),
              guestCounts.length == 1
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'number of guests',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          FormField<String>(
                            builder: (FormFieldState<String> state) {
                              return InputDecorator(
                                key: const ValueKey('guest_count'),
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    errorStyle: TextStyle(
                                        color: Theme.of(context).errorColor,
                                        fontSize: 16.0),
                                    hintText: 'please select guest count',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 0.0),
                                    )),
                                isEmpty: sGuestCount == '',
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    dropdownColor:
                                        Theme.of(context).backgroundColor,
                                    value: sGuestCount,
                                    isDense: true,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        sGuestCount = newValue!;
                                        int count = int.parse(sGuestCount);

                                        widget.partyGuest = widget.partyGuest
                                            .copyWith(guestsCount: count);
                                        widget.partyGuest = widget.partyGuest
                                            .copyWith(guestsRemaining: count);
                                        state.didChange(newValue);
                                      });
                                    },
                                    items: guestCounts.map((String value) {
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
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'guests status',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          key: const ValueKey('guests_status'),
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              errorStyle: TextStyle(
                                  color: Theme.of(context).errorColor,
                                  fontSize: 16.0),
                              hintText: 'please select guest status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 0.0),
                              )),
                          isEmpty: sGuestStatus == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight),
                              dropdownColor: Theme.of(context).backgroundColor,
                              value: sGuestStatus,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  sGuestStatus = newValue!;

                                  widget.partyGuest = widget.partyGuest
                                      .copyWith(guestStatus: sGuestStatus);
                                  state.didChange(newValue);
                                });
                              },
                              items: guestStatuses.map((String value) {
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
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ButtonWidget(
                  text: (widget.task == 'edit' || widget.task == 'manage')
                      ? 'save changes'
                      : 'join list',
                  onClicked: () {
                    if (isDataValid()) {
                      if (isLoggedIn) {
                        showRulesConfirmationDialog(context, false);
                      } else {
                        // need to register the user first
                        _verifyPhone();
                      }
                    } else {
                      Logx.em(
                          _TAG, 'user cannot be entered as data is incomplete');
                    }
                  },
                ),
              ),
              widget.task == 'edit'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: ButtonWidget(
                            text: 'delete',
                            onClicked: () {
                              FirestoreHelper.deletePartyGuest(
                                  widget.partyGuest);

                              Logx.i(_TAG, 'guest list request is deleted');

                              Toaster.longToast(
                                  'guest list request is deleted');
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 12),
            ],
          );
  }

  bool isDataValid() {
    if (widget.partyGuest.name.isEmpty) {
      Logx.em(_TAG, 'name not entered for guest');
      Toaster.longToast('please enter your name');
      return false;
    }
    if (widget.partyGuest.surname.isEmpty) {
      Logx.em(_TAG, 'surname not entered for guest');
      Toaster.longToast('please enter your surname / last name');
      return false;
    }
    if (widget.party.isEmailRequired && widget.partyGuest.email.isEmpty) {
      Logx.em(_TAG, 'email not entered for guest');
      Toaster.longToast('please enter your email');
      return false;
    }

    if (!isLoggedIn && widget.partyGuest.phone.isEmpty) {
      Logx.em(_TAG, 'phone not entered for guest');
      Toaster.longToast('please enter your phone number');
      return false;
    }

    return true;
  }

  showRulesConfirmationDialog(BuildContext context, bool shouldRegisterUser) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        // ScrollController controller = ScrollController();
        // controller.animateTo(controller.position.maxScrollExtent,
        //     duration: const Duration(milliseconds: 1), curve: Curves.fastOutSlowIn);
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.party.eventName + ' | ' + widget.party.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 250,
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('entry rules:\n'),
                        Text(widget.party.guestListRules.toLowerCase()),
                        const Text('\nclub rules:\n'),
                        Text(widget.party.clubRules.toLowerCase()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text("confirm"),
              onPressed: () {
                if (shouldRegisterUser) {
                  PartyGuest freshPartyGuest =
                      Fresh.freshPartyGuest(widget.partyGuest);
                  FirestoreHelper.pushPartyGuest(freshPartyGuest);
                } else {
                  if (hasUserChanged) {
                    blocUser.User freshUser = Fresh.freshUser(bloc_user);
                    if(freshUser.id == UserPreferences.myUser.id){
                      UserPreferences.setUser(freshUser);
                    }
                    FirestoreHelper.pushUser(freshUser);
                  }

                  // need to see if the user already has a guest request
                  widget.partyGuest.guestId = bloc_user.id;

                  FirestoreHelper.pullPartyGuestByUser(
                          widget.partyGuest.guestId, widget.partyGuest.partyId)
                      .then((res) {
                    Logx.i(_TAG, 'pulled in party guest by user');

                    if (res.docs.isEmpty || widget.task == 'edit'  || widget.task == 'manage') {
                      // user has not requested for party guest list, approve
                      PartyGuest freshPartyGuest =
                          Fresh.freshPartyGuest(widget.partyGuest);
                      FirestoreHelper.pushPartyGuest(freshPartyGuest);

                      Logx.i(_TAG, 'guest list request in box office');
                      Toaster.longToast('guest list request in box office');
                    } else {
                      //already requested
                      Logx.i(_TAG, 'duplicate guest list request');
                      Toaster.longToast(
                          'guest list has already been requested');
                    }
                  });
                }

                Navigator.of(ctx).pop();
                Navigator.of(context).pop();

                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => MainScreen(user: bloc_user)));
              },
            ),
          ],
        );
      },
    );
  }

  void _verifyPhone() async {
    Logx.i(_TAG, '_verifyPhone: registering ' + completePhoneNumber.toString());

    if (kIsWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber('${completePhoneNumber}', null)
          .then((firebaseUser) {
        Logx.i(
            _TAG,
            'signInWithPhoneNumber: user verification id ' +
                firebaseUser.verificationId);

        showOTPDialog(context);

        setState(() {
          _verificationCode = firebaseUser.verificationId;
        });
      }).catchError((e, s) {
        Logx.e(_TAG, e, s);
      });
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '${completePhoneNumber}',
          verificationCompleted: (PhoneAuthCredential credential) async {
            Logx.i(_TAG,
                'verifyPhoneNumber: ${completePhoneNumber} is verified. attempting sign in with credentials...');
          },
          verificationFailed: (FirebaseAuthException e) {
            Logx.em(_TAG, 'verificationFailed ' + e.toString());
          },
          codeSent: (String verificationID, int? resendToken) {
            Logx.i(_TAG, 'verification id : ' + verificationID);

            if (mounted) {
              showOTPDialog(context);

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

  showOTPDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'phone number verification',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: FractionallySizedBox(
                        widthFactor: 1,
                        child: OTPVerifyWidget(
                          completePhoneNumber,
                        )),
                  ),
                ),
                Center(
                    child: Text(
                  'enter the six digit code you received on \n${completePhoneNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
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
                        delay: const Duration(seconds: 7),
                        child: Text('didn\'t receive code. ',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 16,
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          Toaster.longToast('refreshing');
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
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
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
      key: GlobalKey<FormState>(),
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

                Toaster.shortToast('verifying ${completePhoneNumber}');
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      Logx.i(_TAG, 'user is in firebase auth');
                      Logx.i(
                          _TAG,
                          'checking for bloc registration, id ' +
                              value.user!.uid);

                      FirestoreHelper.pullUser(value.user!.uid).then((res) {
                        Logx.i(
                            _TAG,
                            "successfully retrieved bloc user for id " +
                                value.user!.uid);

                        if (res.docs.isEmpty) {
                          Logx.i(_TAG,
                              'user is not already registered in bloc, registering...');

                          bloc_user.id = value.user!.uid;
                          bloc_user.phoneNumber =
                              StringUtils.getInt(value.user!.phoneNumber!);

                          FirestoreHelper.pushUser(bloc_user);
                          Logx.i(_TAG, 'registered user ' + bloc_user.id);

                          UserPreferences.setUser(bloc_user);
                          widget.partyGuest.guestId = bloc_user.id;
                          widget.partyGuest.phone =
                              bloc_user.phoneNumber.toString();

                          showRulesConfirmationDialog(context, true);
                        } else {
                          Logx.i(_TAG,
                              'user is a bloc member. navigating to main...');

                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          blocUser.User user = Fresh.freshUserMap(data, true);

                          //update user details
                          user = user.copyWith(name: bloc_user.name);
                          user = user.copyWith(email: bloc_user.email);
                          int time = Timestamp.now().millisecondsSinceEpoch;
                          user = user.copyWith(lastSeenAt: time);
                          FirestoreHelper.pushUser(user);

                          UserPreferences.setUser(user);
                          bloc_user = user;

                          widget.partyGuest.guestId = bloc_user.id;
                          widget.partyGuest.phone =
                              bloc_user.phoneNumber.toString();
                          showRulesConfirmationDialog(context, false);
                        }
                      });
                    }
                  });
                } catch (e) {
                  Logx.em(_TAG, 'otp error ' + e.toString());

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

//  void showOTPModal(BuildContext context) {
//     showModalBottomSheet<void>(
//       isScrollControlled: true,
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           height: 200,
//           margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//           child: Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   Flexible(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 20, right: 20),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Container(
//                             margin: const EdgeInsets.only(bottom: 20),
//                             child: FractionallySizedBox(
//                                 widthFactor: 1,
//                                 child: OTPVerifyWidget(
//                                   completePhoneNumber,
//                                 )),
//                           ),
//                           Center(
//                               child: Text(
//                                 'enter the six digit code you received on \n${completePhoneNumber}',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Theme.of(context).primaryColorDark,
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: 16,
//                                 ),
//                               )),
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 10.0, right: 10, top: 2, bottom: 5),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 DelayedDisplay(
//                                   delay: const Duration(seconds: 9),
//                                   child: Text('didn\'t receive code. ',
//                                       style: TextStyle(
//                                         color: Theme.of(context).primaryColorDark,
//                                         fontSize: 16,
//                                       )),
//                                 ),
//                                 InkWell(
//                                   onTap: () {
//                                     Toaster.longToast('refreshing');
//                                     _verifyPhone();
//                                   },
//                                   child: DelayedDisplay(
//                                     delay: const Duration(seconds: 10),
//                                     child: Text(
//                                       'resend?',
//                                       style: TextStyle(
//                                         color: Theme.of(context).primaryColor,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
