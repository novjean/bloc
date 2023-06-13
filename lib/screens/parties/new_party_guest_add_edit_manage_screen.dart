import 'dart:io';

import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/db/entity/reservation.dart';
import 'package:bloc/screens/box_office/box_office_screen.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../../api/apis.dart';
import '../../db/entity/challenge.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/user.dart' as blocUser;
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/app_route_constants.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/dark_textfield_widget.dart';
import '../../widgets/parties/party_banner.dart';
import '../main_screen.dart';
import '../user/reservation_add_edit_screen.dart';

class NewPartyGuestAddEditManageScreen extends StatefulWidget {
  String partyGuestId;
  String task;

  // PartyGuest partyGuest;
  // Party party;
  // String task;

  NewPartyGuestAddEditManageScreen(
      {key, required this.partyGuestId, required this.task})
      : super(key: key);

  @override
  _NewPartyGuestAddEditManageScreenState createState() =>
      _NewPartyGuestAddEditManageScreenState();
}

class _NewPartyGuestAddEditManageScreenState
    extends State<NewPartyGuestAddEditManageScreen> {
  static const String _TAG = 'PartyGuestAddEditManageScreen';

  late blocUser.User mPartyGuestUser;

  bool isPhotoChanged = false;

  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  bool hasUserChanged = false;
  bool isCustomerLoading = true;

  late String sGuestCount;
  List<String> guestCounts = [];

  String sGuestStatus = 'couple';
  List<String> guestStatuses = ['couple', 'ladies', 'lgbtq+', 'stag'];

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
  final TextEditingController _controller = TextEditingController();
  String completePhoneNumber = '';
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  List<Challenge> challenges = [];
  bool isChallengesLoading = true;

  late PartyGuest mPartyGuest;
  var _isPartyGuestLoading = true;

  late Party mParty;
  var _isPartyLoading = true;

  @override
  void initState() {
    if (!UserPreferences.isUserLoggedIn()) {
      mPartyGuestUser = Dummy.getDummyUser();
    } else {
      mPartyGuestUser = UserPreferences.myUser;
    }

    mPartyGuest = Dummy.getDummyPartyGuest();

    FirestoreHelper.pullPartyGuest(widget.partyGuestId).then((res) {
      Logx.i(_TAG, "successfully pulled in party guest");

      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyGuest partyGuest = Fresh.freshPartyGuestMap(data, false);
          mPartyGuest = partyGuest;
        }
        _isPartyGuestLoading = false;

        FirestoreHelper.pullUser(mPartyGuest.guestId).then((res) {
          Logx.i(_TAG, 'successfully pulled in user');

          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final blocUser.User _user = Fresh.freshUserMap(map, true);

            setState(() {
              if (_user.phoneNumber == Constants.skipPhoneNumber) {
                //user will be the dummy
                isLoggedIn = false;
              } else {
                mPartyGuestUser = _user;
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

        FirestoreHelper.pullParty(mPartyGuest.partyId).then((res) {
          Logx.i(_TAG, "successfully pulled in party for partyGuest");

          if (res.docs.isNotEmpty) {
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              final Party party = Fresh.freshPartyMap(data, false);
              mParty = party;
            }

            for (int i = 1; i <= mParty.guestListCount; i++) {
              guestCounts.add(i.toString());
            }
            sGuestCount = mPartyGuest.guestsCount.toString();
            sGuestStatus = mPartyGuest.guestStatus;
            sGender = mPartyGuest.gender;

            setState(() {
              _isPartyLoading = false;
            });
          } else {
            Logx.i(_TAG, 'no party found!');
            Toaster.shortToast('party cannot be found!');
            setState(() {
              _isPartyLoading = false;
            });
          }
        });
      } else {
        Logx.i(_TAG, 'no party guests found!');
        setState(() {
          _isPartyGuestLoading = false;
          _isPartyLoading = false;
        });
      }
    });

    FirestoreHelper.pullChallenges().then((res) {
      if (res.docs.isNotEmpty) {
        Logx.i(_TAG, "successfully pulled in all challenges");

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Challenge challenge = Fresh.freshChallengeMap(data, false);
          challenges.add(challenge);
        }

        setState(() {
          isChallengesLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no challenges found, setting default');
        setState(() {
          isChallengesLoading = false;
        });
      }
    });


    super.initState();
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
    return isCustomerLoading && isChallengesLoading
        ? const LoadingWidget()
        : ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        PartyBanner(
          party: mParty,
          isClickable: false,
          shouldShowButton: false,
          isGuestListRequested: false,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: DarkTextFieldWidget(
            label: 'name \*',
            text: mPartyGuestUser.name,
            onChanged: (name) {
              mPartyGuestUser = mPartyGuestUser.copyWith(name: name);
              hasUserChanged = true;

              mPartyGuest = mPartyGuest.copyWith(name: name);
            },
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: DarkTextFieldWidget(
            label: 'surname \*',
            text: mPartyGuestUser.surname,
            onChanged: (surname) {
              mPartyGuestUser = mPartyGuestUser.copyWith(surname: surname);
              hasUserChanged = true;

              mPartyGuest =
                  mPartyGuest.copyWith(surname: surname);
            },
          ),
        ),
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
              IntlPhoneField(
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
            ],
          ),
        )
            : const SizedBox(),
        !UserPreferences.isUserLoggedIn()
            ? const SizedBox(height: 12)
            : const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: DarkTextFieldWidget(
              label: 'email${mParty.isEmailRequired ? ' *' : ''}',
              text: mPartyGuestUser.email,
              onChanged: (email) {
                mPartyGuestUser = mPartyGuestUser.copyWith(email: email);
                hasUserChanged = true;

                mPartyGuest =
                    mPartyGuest.copyWith(email: email);
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

                            mPartyGuestUser =
                                mPartyGuestUser.copyWith(gender: sGender);
                            hasUserChanged = true;

                            mPartyGuest = mPartyGuest
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

                            mPartyGuest = mPartyGuest
                                .copyWith(guestsCount: count);
                            mPartyGuest = mPartyGuest
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

                            mPartyGuest = mPartyGuest
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
        widget.task == 'manage'
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              DarkTextFieldWidget(
                label: 'phone number *',
                text: mPartyGuestUser.phoneNumber.toString(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 24),
              DarkTextFieldWidget(
                label: 'challenge task',
                text: findChallenge().title,
                onChanged: (value) {},
              ),
              const SizedBox(height: 24),
              DarkTextFieldWidget(
                label: 'challenge url',
                text: findChallengeUrl(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'challenge level *',
                      style: TextStyle(
                          color:
                          Theme.of(context).primaryColorLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      ButtonWidget(
                        text: '  down  ',
                        onClicked: () {
                          int level = mPartyGuestUser.challengeLevel;
                          level--;
                          setState(() {
                            mPartyGuestUser = mPartyGuestUser.copyWith(
                                challengeLevel: level);
                            FirestoreHelper.pushUser(mPartyGuestUser);
                          });
                        },
                      ),
                      DarkButtonWidget(
                        text: mPartyGuestUser.challengeLevel.toString(),
                        onClicked: () {},
                      ),
                      ButtonWidget(
                        text: 'level up',
                        onClicked: () {
                          int level = mPartyGuestUser.challengeLevel;
                          level++;
                          setState(() {
                            mPartyGuestUser = mPartyGuestUser.copyWith(
                                challengeLevel: level);
                            FirestoreHelper.pushUser(mPartyGuestUser);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text('supported: ', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Constants.lightPrimary,
                      )),
                      Checkbox(
                        value: mPartyGuest.isChallengeClicked,
                        onChanged: (value) {
                          mPartyGuest = mPartyGuest.copyWith(isChallengeClicked: value);
                          PartyGuest freshPartyGuest = Fresh.freshPartyGuest(mPartyGuest);
                          FirestoreHelper.pushPartyGuest(freshPartyGuest);

                          Logx.i(_TAG, 'guest ${'${mPartyGuest.name} '} : supported $value');

                          setState(() {
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('banned: ', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Constants.lightPrimary,
                      )),
                      Checkbox(
                        value: mPartyGuestUser.isBanned,
                        onChanged: (value) {
                          mPartyGuestUser = mPartyGuestUser.copyWith(isBanned: value);
                          blocUser.User freshUser = Fresh.freshUser(mPartyGuestUser);
                          FirestoreHelper.pushUser(freshUser);

                          Logx.i(_TAG, 'user ${'${mPartyGuestUser.name} ${mPartyGuestUser.surname}'} : banned $value');
                          Toaster.longToast('user ${'${mPartyGuestUser.name} ${mPartyGuestUser.surname}'} : banned $value');

                          setState(() {
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
            : const SizedBox(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 42, bottom: 5),
              child: DelayedDisplay(
                delay: const Duration(seconds: 1),
                child: Text(
                  "* required",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        widget.task == 'manage'
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ButtonWidget(
                text: 'approve',
                onClicked: () {
                  mPartyGuest = mPartyGuest.copyWith(isApproved: true);
                  FirestoreHelper.pushPartyGuest(mPartyGuest);

                  //here we should notify the user
                  if(mPartyGuestUser.fcmToken.isNotEmpty){
                    String title = mParty.name;
                    String message = 'guest list request has been approved, see you soon!';

                    //send a notification
                    Apis.sendPushNotification(mPartyGuestUser.fcmToken, title, message);
                  }

                  Logx.i(_TAG, 'party guest ${mPartyGuest.name} is approved');
                  Toaster.longToast('party guest ${mPartyGuest.name} is approved');
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        )
            : const SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ButtonWidget(
            text: (widget.task == 'edit' || widget.task == 'manage') ? 'save changes' : 'join list',
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
        widget.task == 'edit' || widget.task == 'manage'
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: DarkButtonWidget(
                text: 'delete',
                onClicked: () {
                  FirestoreHelper.deletePartyGuest(
                      mPartyGuest);

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
        const SizedBox(height: 24),
      ],
    );
  }

  bool isDataValid() {
    if (mPartyGuest.name.isEmpty) {
      Logx.em(_TAG, 'name not entered for guest');
      Toaster.longToast('please enter your name');
      return false;
    }
    if (mPartyGuest.surname.isEmpty) {
      Logx.em(_TAG, 'surname not entered for guest');
      Toaster.longToast('please enter your surname / last name');
      return false;
    }
    if (mParty.isEmailRequired && mPartyGuest.email.isEmpty) {
      Logx.em(_TAG, 'email not entered for guest');
      Toaster.longToast('please enter your email');
      return false;
    }

    if (!isLoggedIn && mPartyGuest.phone.isEmpty) {
      Logx.em(_TAG, 'phone not entered for guest');
      Toaster.longToast('please enter your phone number');
      return false;
    }

    return true;
  }

  showRulesConfirmationDialog(BuildContext context, bool isNewUser) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
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
                        '${mParty.eventName} | ${mParty.name}',
                        style: const TextStyle(fontSize: 18,
                            overflow: TextOverflow.ellipsis),
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
                        Text(mParty.guestListRules.toLowerCase()),
                        const Text('\nclub rules:\n'),
                        Text(mParty.clubRules.toLowerCase()),
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
                if (isNewUser) {
                  PartyGuest freshPartyGuest =
                  Fresh.freshPartyGuest(mPartyGuest);
                  FirestoreHelper.pushPartyGuest(freshPartyGuest);

                  HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
                  historyMusic.userId = mPartyGuest.guestId;
                  historyMusic.genre = mParty.genre;
                  historyMusic.count = 1;
                  FirestoreHelper.pushHistoryMusic(historyMusic);

                } else {
                  if (hasUserChanged) {
                    blocUser.User freshUser = Fresh.freshUser(mPartyGuestUser);
                    if (freshUser.id == UserPreferences.myUser.id) {
                      UserPreferences.setUser(freshUser);
                    }
                    FirestoreHelper.pushUser(freshUser);
                  }

                  // need to see if the user already has a guest request
                  mPartyGuest.guestId = mPartyGuestUser.id;

                  FirestoreHelper.pullPartyGuestByUser(
                      mPartyGuest.guestId, mPartyGuest.partyId)
                      .then((res) {
                    Logx.i(_TAG, 'pulled in party guest by user');

                    if (res.docs.isEmpty ||
                        widget.task == 'edit' ||
                        widget.task == 'manage') {
                      // user has not requested for party guest list, approve
                      PartyGuest freshPartyGuest =
                      Fresh.freshPartyGuest(mPartyGuest);
                      FirestoreHelper.pushPartyGuest(freshPartyGuest);

                      Logx.i(_TAG, 'guest list request in box office');
                      Toaster.longToast('guest list request in box office');

                      FirestoreHelper.pullHistoryMusic(mPartyGuest.guestId, mParty.genre)
                          .then((res) {
                        if(res.docs.isEmpty){
                          // no history, add new one
                          HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
                          historyMusic.userId = mPartyGuest.guestId;
                          historyMusic.genre = mParty.genre;
                          historyMusic.count = 1;
                          FirestoreHelper.pushHistoryMusic(historyMusic);
                        } else {
                          for (int i = 0; i < res.docs.length; i++) {
                            DocumentSnapshot document = res.docs[i];
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            final HistoryMusic historyMusic = Fresh.freshHistoryMusicMap(data, false);
                            historyMusic.count++;
                            FirestoreHelper.pushHistoryMusic(historyMusic);
                          }
                        }
                      });
                    } else {
                      //already requested
                      Logx.i(_TAG, 'duplicate guest list request');
                      Toaster.longToast(
                          'guest list has already been requested');
                    }
                  });
                }

                Navigator.of(ctx).pop();

                if (mParty.isChallengeActive) {
                  showChallengeDialog(context);
                } else {
                  Navigator.of(context).pop();

                  UserPreferences.setUser(mPartyGuestUser);
                  GoRouter.of(context)
                      .pushNamed(MyAppRouteConstants.homeRouteName);


                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //     builder: (context) => MainScreen()));
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BoxOfficeScreen()));
                }
              },
            ),
          ],
        );
      },
    );
  }

  showChallengeDialog(BuildContext context) {
    Challenge challenge = findChallenge();

    String challengeText = challenge.description;

    if (challengeText.isEmpty) {
      // all challenges are completed
      Navigator.of(context).pop();

      UserPreferences.setUser(mPartyGuestUser);
      GoRouter.of(context)
          .pushNamed(MyAppRouteConstants.homeRouteName);

      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     builder: (context) => MainScreen()));
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BoxOfficeScreen()));
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext ctx) {
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
                        Expanded(
                          child: Text(
                            '#blocCommunity  | ${mParty.name}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18),
                          ),
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
                          Text('${challenge.dialogTitle}:\n'),
                          Text(challenge.description.toLowerCase()),
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

                  showReserveTableDialog(context);
                },
              ),
              challenge.dialogAccept2Text.isNotEmpty?
              TextButton(
                child: Text(challenge.dialogAccept2Text),
                onPressed: () async {
                  Logx.i(_TAG, 'user accepts challenge');
                  Toaster.longToast('thank you for supporting us!');

                  mPartyGuest = mPartyGuest.copyWith(isChallengeClicked: true);
                  FirestoreHelper.pushPartyGuest(mPartyGuest);

                  switch (challenge.level) {
                    case 3:{
                      //android download
                      final uri = Uri.parse(ChallengeUtils.urlBlocPlayStore);
                      NetworkUtils.launchInBrowser(uri);
                      break;
                    }
                    default:
                      {
                        final uri =
                        Uri.parse(ChallengeUtils.urlBlocInsta);
                        NetworkUtils.launchInBrowser(uri);
                        break;
                      }
                  }
                },
              )
                  : const SizedBox(),

              TextButton(
                child: Text(challenge.dialogAcceptText),
                onPressed: () async {
                  Logx.i(_TAG, 'user accepts challenge');
                  Toaster.longToast('thank you for supporting us!');

                  mPartyGuest = mPartyGuest.copyWith(isChallengeClicked: true);
                  FirestoreHelper.pushPartyGuest(mPartyGuest);

                  switch (challenge.level) {
                    case 1:
                      {
                        final uri =
                        Uri.parse(ChallengeUtils.urlBlocInsta);
                        NetworkUtils.launchInBrowser(uri);
                        break;
                      }
                    case 2:
                      {
                        final uri = Uri.parse(ChallengeUtils.urlFreqInsta);
                        NetworkUtils.launchInBrowser(uri);
                        break;
                      }
                    case 3:{
                      //ios download
                      final uri = Uri.parse(
                          ChallengeUtils.urlBlocAppStore);
                      NetworkUtils.launchInBrowser(uri);
                      break;
                    }
                    case 4:{
                      //share or invite your friends
                      final uri = Uri.parse(mParty.instagramUrl);
                      NetworkUtils.launchInBrowser(uri);
                      break;
                    }
                    case 100:
                      {
                        final urlImage = mParty.storyImageUrl.isNotEmpty
                            ? mParty.storyImageUrl
                            : mParty.imageUrl;
                        final Uri url = Uri.parse(urlImage);
                        final response = await http.get(url);
                        final Uint8List bytes = response.bodyBytes;

                        try {
                          if (kIsWeb) {
                            FileUtils.openFileNewTabForWeb(urlImage);

                            // Image? fromPicker = await ImagePickerWeb.getImageAsWidget();
                          } else {
                            var temp = await getTemporaryDirectory();
                            final path = '${temp.path}/${mParty.id}.jpg';
                            File(path).writeAsBytesSync(bytes);

                            final files = <XFile>[];
                            files.add(
                                XFile(path, name: '${mParty.id}.jpg'));

                            await Share.shareXFiles(files,
                                text: '#blocCommunity');
                          }
                        } on PlatformException catch (e, s) {
                          Logx.e(_TAG, e, s);
                        } on Exception catch (e, s) {
                          Logx.e(_TAG, e, s);
                        } catch (e) {
                          logger.e(e);
                        }
                        break;
                      }
                    default:
                      {
                        final uri =
                        Uri.parse('https://www.instagram.com/bloc.india/');
                        NetworkUtils.launchInBrowser(uri);
                        break;
                      }
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  showReserveTableDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'reserve table | ${mParty.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text('reserve your table at the trendiest club in town and let us take care of every detail, so you can focus on enjoying a wonderful evening with your loved ones.'),
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
                Navigator.of(context).pop();

                UserPreferences.setUser(mPartyGuestUser);
                GoRouter.of(context)
                    .pushNamed(MyAppRouteConstants.homeRouteName);

                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //     builder: (context) => MainScreen()));
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BoxOfficeScreen()));
              },
            ),
            TextButton(
              child: const Text("reserve my table"),
              onPressed: () {
                Reservation reservation  = Dummy.getDummyReservation(Constants.blocServiceId);
                reservation = reservation.copyWith(customerId: mPartyGuest.guestId);
                reservation = reservation.copyWith(name: '${mPartyGuest.name} ${mPartyGuest.surname}');
                int? phoneNumber = int.tryParse(mPartyGuest.phone);
                reservation = reservation.copyWith(phone: phoneNumber);

                reservation = reservation.copyWith(arrivalDate: mParty.startTime);
                reservation = reservation.copyWith(arrivalTime: DateTimeUtils.getFormattedTime2(mParty.startTime));

                reservation = reservation.copyWith(guestsCount: mPartyGuest.guestsCount);

                Navigator.of(ctx).pop();
                Navigator.of(context).pop();

                UserPreferences.setUser(mPartyGuestUser);
                GoRouter.of(context)
                    .pushNamed(MyAppRouteConstants.homeRouteName);

                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //     builder: (context) => MainScreen()));

                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (ctx) =>
                          ReservationAddEditScreen(
                              reservation: reservation,
                              task: 'add')),
                );
              },
            ),
          ],
        );
      },
    );
  }


  Challenge findChallenge() {
    Challenge returnChallenge = challenges.last;

    if(mParty.overrideChallengeNum>0){
      for (Challenge challenge in challenges) {
        if (challenge.level == mParty.overrideChallengeNum) {
          return challenge;
        }
      }
    } else {
      for (Challenge challenge in challenges) {
        if (challenge.level >= mPartyGuestUser.challengeLevel) {
          return challenge;
        }
      }
    }


    return returnChallenge;
  }

  /** phone registration **/
  void _verifyPhone() async {
    Logx.i(_TAG, '_verifyPhone: registering $completePhoneNumber');

    if (kIsWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber('${completePhoneNumber}', null)
          .then((firebaseUser) {
        Logx.i(
            _TAG,
            'signInWithPhoneNumber: user verification id ${firebaseUser.verificationId}');

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
                    children: const [
                      Text(
                        'phone number verification',
                        style: TextStyle(fontSize: 18),
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
                          'checking for bloc registration, id ${value.user!.uid}');

                      FirestoreHelper.pullUser(value.user!.uid).then((res) {
                        Logx.i(
                            _TAG,
                            "successfully retrieved bloc user for id ${value.user!.uid}");

                        if (res.docs.isEmpty) {
                          Logx.i(_TAG,
                              'user is not already registered in bloc, registering...');

                          mPartyGuestUser.id = value.user!.uid;
                          mPartyGuestUser.phoneNumber =
                              StringUtils.getInt(value.user!.phoneNumber!);

                          FirestoreHelper.pushUser(mPartyGuestUser);
                          Logx.i(_TAG, 'registered user ${mPartyGuestUser.id}');

                          UserPreferences.setUser(mPartyGuestUser);
                          mPartyGuest.guestId = mPartyGuestUser.id;
                          mPartyGuest.phone =
                              mPartyGuestUser.phoneNumber.toString();

                          showRulesConfirmationDialog(context, true);
                        } else {
                          Logx.i(_TAG,
                              'user is a bloc member. navigating to main...');

                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                          blocUser.User user = Fresh.freshUserMap(data, true);

                          //update user details
                          user = user.copyWith(name: mPartyGuestUser.name);
                          user = user.copyWith(email: mPartyGuestUser.email);
                          int time = Timestamp.now().millisecondsSinceEpoch;
                          user = user.copyWith(lastSeenAt: time);
                          FirestoreHelper.pushUser(user);

                          UserPreferences.setUser(user);
                          mPartyGuestUser = user;

                          mPartyGuest.guestId = mPartyGuestUser.id;
                          mPartyGuest.phone =
                              mPartyGuestUser.phoneNumber.toString();
                          showRulesConfirmationDialog(context, false);
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

  findChallengeUrl() {
    String url = ChallengeUtils.challengeUrl(findChallenge());

    if(url == ChallengeUtils.partyInsta){
      url = mParty.instagramUrl;
    }
    return url;
  }
}