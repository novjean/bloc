import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/db/entity/user_lounge.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:pinput/pinput.dart';
import 'package:share_plus/share_plus.dart';

import '../../api/apis.dart';
import '../../db/entity/ad_campaign.dart';
import '../../db/entity/challenge.dart';
import '../../db/entity/challenge_action.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/party_interest.dart';
import '../../db/entity/promoter.dart';
import '../../db/entity/reservation.dart';
import '../../db/entity/user.dart' as blocUser;
import '../../db/shared_preferences/party_guest_preferences.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/party_guest_entry_widget.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/dark_textfield_widget.dart';
import '../../widgets/parties/party_banner.dart';

class PartyGuestAddEditManageScreen extends StatefulWidget {
  PartyGuest partyGuest;
  Party party;
  String task;

  PartyGuestAddEditManageScreen(
      {key, required this.partyGuest, required this.party, required this.task})
      : super(key: key);

  @override
  _PartyGuestAddEditManageScreenState createState() =>
      _PartyGuestAddEditManageScreenState();
}

class _PartyGuestAddEditManageScreenState
    extends State<PartyGuestAddEditManageScreen> {
  static const String _TAG = 'PartyGuestAddEditManageScreen';

  bool testMode = true;

  late blocUser.User mBlocUser;
  bool hasUserChanged = false;
  bool _isCustomerLoading = true;

  bool _showSurnameField = true;
  bool _showYearField = true;

  String _sGuestStatus = 'couple';
  final List<String> _guestStatuses = [
    'couple',
    'ladies',
    'lgbtq+',
    'stag',
    'promoter'
  ];

  late String _sGuestCount;
  List<String> _defaultGuestCounts = [];
  List<String> _promoterGuestCounts = [];
  List<String> _coupleGuestCounts = ['2', '3'];
  List<String> _stagGuestCounts = ['1'];
  List<String> _currentGuestCounts = [];

  String _sGender = 'male';
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
  bool _isChallengesLoading = true;

  List<Party> mParties = [];
  var _isPartiesLoading = true;
  List<String> mPartyNames = [];
  Party sParty = Dummy.getDummyParty('');
  String sPartyName = 'all';
  String sPartyId = '';

  PartyInterest mPartyInterest = Dummy.getDummyPartyInterest();

  List<Promoter> mPromoters = [];
  var _isPromotersLoading = true;
  List<Promoter> sPromoters = [];
  String sPromoterId = '';

  final List<String> years = [];
  late String _sYear;

  @override
  void initState() {
    if (!UserPreferences.isUserLoggedIn()) {
      mBlocUser = Dummy.getDummyUser();
    } else {
      // mBlocUser = UserPreferences.myUser;

      if(widget.task == 'manage'){
        mBlocUser = Dummy.getDummyUser();
      } else {
        mBlocUser = UserPreferences.myUser;
      }
    }

    if (widget.partyGuest.surname.isEmpty ||
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL) {
      _showSurnameField = true;
    } else {
      _showSurnameField = false;
    }

    _sYear = mBlocUser.birthYear.toString();

    for (int i = DateTime.now().year; i > DateTime.now().year - 100; i--) {
      years.add(i.toString());
    }

    if (mBlocUser.clearanceLevel < Constants.PROMOTER_LEVEL && widget.task!='manage') {
      _guestStatuses.removeLast();
    }

    if (widget.partyGuest.guestId.isEmpty && widget.task != 'add') {
      // this is promoter guest ideology, and not having to make the call for no guest id
      int phoneNumber = 0;
      try {
        phoneNumber = StringUtils.getInt(widget.partyGuest.phone);
      } catch (e) {
        Logx.em(_TAG, e.toString());
      }

      mBlocUser = mBlocUser.copyWith(
          name: widget.partyGuest.name,
          gender: widget.partyGuest.gender,
          surname: widget.partyGuest.surname,
          phoneNumber: phoneNumber);
      setState(() {
        isLoggedIn = true;
        _isCustomerLoading = false;
      });
    } else {
      FirestoreHelper.pullUser(widget.partyGuest.guestId).then((res) {
        if (res.docs.isNotEmpty) {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
          final blocUser.User user = Fresh.freshUserMap(map, true);

          setState(() {
            if (user.phoneNumber == Constants.skipPhoneNumber) {
              //user will be the dummy
              isLoggedIn = false;
            } else {
              mBlocUser = user;

              if (mBlocUser.birthYear == 2023 ||
                  UserPreferences.myUser.clearanceLevel >=
                      Constants.MANAGER_LEVEL) {
                _showYearField = true;
              } else {
                _showYearField = false;
              }
              _sYear = mBlocUser.birthYear.toString();

              isLoggedIn = true;
            }
            _isCustomerLoading = false;
          });
        } else {
          setState(() {
            isLoggedIn = false;
            _isCustomerLoading = false;
          });
        }
      });
    }

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
          _isChallengesLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no challenges found, setting default');
        setState(() {
          _isChallengesLoading = false;
        });
      }
    });

    sPartyId = widget.partyGuest.partyId;
    FirestoreHelper.pullActiveGuestListParties(
            Timestamp.now().millisecondsSinceEpoch)
        .then((res) {
      if (res.docs.isNotEmpty) {
        // found parties
        List<Party> parties = [];
        List<String> partyNames = ['all'];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, true);
          parties.add(party);
          String partyTitle = '${party.name} ${party.chapter}';
          partyNames.add(partyTitle);

          if (party.id == sPartyId) {
            sPartyName = partyTitle;
            sParty = party;
          }
        }
        setState(() {
          mParties = parties;
          mPartyNames = partyNames;
          _isPartiesLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no parties found!');
        const Center(
          child: Text('no parties assigned yet!'),
        );
        setState(() {
          _isPartiesLoading = false;
        });
      }
    });

    sPromoterId = widget.partyGuest.promoterId;
    FirestoreHelper.pullPromoters().then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Promoter promoter = Fresh.freshPromoterMap(data, false);
          mPromoters.add(promoter);

          if (promoter.id == sPromoterId) {
            sPromoters.add(promoter);
          }
        }
        setState(() {
          _isPromotersLoading = false;
        });
      } else {
        setState(() {
          _isPromotersLoading = false;
        });
      }
    });

    for (int i = 1; i <= widget.party.guestListCount; i++) {
      _defaultGuestCounts.add(i.toString());
    }

    if (!widget.party.isGuestsCountRestricted) {
      _coupleGuestCounts.add('4');
      _stagGuestCounts.add('2');
    }

    for (int i = 1; i <= 20; i++) {
      _promoterGuestCounts.add(i.toString());
    }

    _sGuestStatus = widget.partyGuest.guestStatus;
    _sGuestCount = widget.partyGuest.guestsCount.toString();
    _sGender = widget.partyGuest.gender;

    super.initState();

    if (_sGuestStatus == 'couple') {
      _currentGuestCounts = _coupleGuestCounts;
    } else if (_sGuestStatus == 'stag') {
      _currentGuestCounts = _stagGuestCounts;
    } else if (_sGuestStatus == 'promoter') {
      _currentGuestCounts = _promoterGuestCounts;
    } else {
      _currentGuestCounts = _defaultGuestCounts;
    }

    if (!_currentGuestCounts.contains(_sGuestCount)) {
      _sGuestCount = _currentGuestCounts.last;
      int count = int.parse(_sGuestCount);
      widget.partyGuest = widget.partyGuest
          .copyWith(guestsCount: count, guestsRemaining: count);
    }

    if (UserPreferences.isUserLoggedIn()) {
      FirestoreHelper.pullPartyInterest(widget.party.id).then((res) {
        if (res.docs.isNotEmpty) {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          mPartyInterest = Fresh.freshPartyInterestMap(data, false);
          if (!mPartyInterest.userIds.contains(UserPreferences.myUser.id)) {
            mPartyInterest.userIds.add(UserPreferences.myUser.id);
            FirestoreHelper.pushPartyInterest(mPartyInterest);
            Logx.d(_TAG, 'user interest recorded for party');
          } else {
            Logx.d(_TAG, 'user interest previously recorded for party');
          }
        } else {
          mPartyInterest = mPartyInterest.copyWith(
              partyId: widget.party.id, userIds: [UserPreferences.myUser.id]);
          FirestoreHelper.pushPartyInterest(mPartyInterest);

          Logx.d(_TAG, 'party interest created for party');
        }

        if (widget.task == 'manage') {
          if (!mPartyInterest.userIds.contains(widget.partyGuest.guestId)) {
            mPartyInterest.userIds.add(widget.partyGuest.guestId);
            FirestoreHelper.pushPartyInterest(mPartyInterest);
          }
        }
      });
    }
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
      backgroundColor: Constants.background,
      appBar: AppBar(
        title: AppBarTitle(title: 'guest list'),
        titleSpacing: 0,
        backgroundColor: Constants.background,
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isCustomerLoading &&
            _isChallengesLoading &&
            _isPartiesLoading &&
            _isPromotersLoading
        ? const LoadingWidget()
        : ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              PartyBanner(
                party: widget.party,
                isClickable: false,
                shouldShowButton: false,
                isGuestListRequested: false,
                shouldShowInterestCount: false,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: DarkTextFieldWidget(
                  label: 'name *',
                  text: mBlocUser.name,
                  onChanged: (name) {
                    mBlocUser = mBlocUser.copyWith(name: name);
                    hasUserChanged = true;

                    widget.partyGuest = widget.partyGuest.copyWith(name: name);
                  },
                ),
              ),
              _showSurnameField
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: DarkTextFieldWidget(
                            label: 'surname *',
                            text: mBlocUser.surname,
                            onChanged: (surname) {
                              mBlocUser = mBlocUser.copyWith(surname: surname);
                              hasUserChanged = true;

                              widget.partyGuest =
                                  widget.partyGuest.copyWith(surname: surname);
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              !isLoggedIn
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'phone number \*',
                              style: TextStyle(
                                  color: Constants.lightPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IntlPhoneField(
                            style: const TextStyle(
                                color: Constants.primary, fontSize: 18),
                            decoration: const InputDecoration(
                                labelText: '',
                                labelStyle: TextStyle(color: Constants.primary),
                                hintStyle: TextStyle(color: Constants.primary),
                                counterStyle:
                                    TextStyle(color: Constants.primary),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Constants.primary),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Constants.primary, width: 0.0),
                                )),
                            controller: _controller,
                            initialCountryCode: 'IN',
                            dropdownTextStyle: const TextStyle(
                                color: Constants.primary, fontSize: 18),
                            pickerDialogStyle: PickerDialogStyle(
                                backgroundColor: Constants.primary),
                            onChanged: (phone) {
                              Logx.i(_TAG, phone.completeNumber);
                              completePhoneNumber = phone.completeNumber;
                            },
                            onCountryChanged: (country) {
                              Logx.i(
                                  _TAG, 'country changed to: ${country.name}');
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
                    label: 'email${widget.party.isEmailRequired ? ' *' : ''}',
                    text: mBlocUser.email,
                    onChanged: (email) {
                      mBlocUser = mBlocUser.copyWith(email: email);
                      hasUserChanged = true;

                      widget.partyGuest =
                          widget.partyGuest.copyWith(email: email);
                    }),
              ),
              const SizedBox(height: 24),
              _showYearField
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'year of birth *',
                                  style: TextStyle(
                                      color: Constants.lightPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          FormField<String>(
                            builder: (FormFieldState<String> state) {
                              return InputDecorator(
                                key: const ValueKey('year_dropdown'),
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    errorStyle: const TextStyle(
                                        color: Constants.errorColor,
                                        fontSize: 16.0),
                                    hintText: 'please select year of birth',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                          color: Constants.primary),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Constants.primary, width: 0.0),
                                    )),
                                isEmpty: _sYear == '',
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    style: const TextStyle(
                                        color: Constants.lightPrimary),
                                    dropdownColor: Constants.background,
                                    value: _sYear,
                                    isDense: true,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _sYear = newValue!;
                                        int year = int.parse(_sYear);

                                        mBlocUser =
                                            mBlocUser.copyWith(birthYear: year);
                                        hasUserChanged = true;
                                        state.didChange(newValue);
                                      });
                                    },
                                    items: years.map((String value) {
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
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'gender *',
                            style: TextStyle(
                                color: Constants.lightPrimary,
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
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide:
                                    const BorderSide(color: Constants.primary),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Constants.primary, width: 0.0),
                              )),
                          isEmpty: _sGender == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              style: const TextStyle(
                                  color: Constants.lightPrimary),
                              dropdownColor: Constants.background,
                              value: _sGender,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _sGender = newValue!;

                                  mBlocUser =
                                      mBlocUser.copyWith(gender: _sGender);
                                  hasUserChanged = true;

                                  widget.partyGuest = widget.partyGuest
                                      .copyWith(gender: _sGender);
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'guests status',
                            style: TextStyle(
                                color: Constants.lightPrimary,
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
                              errorStyle: const TextStyle(
                                  color: Constants.errorColor, fontSize: 16.0),
                              hintText: 'please select guest status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: const BorderSide(
                                    color: Constants.lightPrimary),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Constants.lightPrimary, width: 0.0),
                              )),
                          isEmpty: _sGuestStatus == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              style: const TextStyle(
                                  color: Constants.lightPrimary),
                              dropdownColor: Constants.background,
                              value: _sGuestStatus,
                              isDense: true,
                              onChanged: _onStatusChanged,
                              items: _guestStatuses.map((String value) {
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
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'number of guests',
                            style: TextStyle(
                                color: Constants.lightPrimary,
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
                              errorStyle: const TextStyle(
                                  color: Constants.errorColor, fontSize: 16.0),
                              hintText: 'please select guest count',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide:
                                    const BorderSide(color: Constants.primary),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Constants.primary, width: 0.0),
                              )),
                          isEmpty: _sGuestCount == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              style: const TextStyle(
                                  color: Constants.lightPrimary),
                              dropdownColor: Constants.background,
                              value: _sGuestCount,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _sGuestCount = newValue!;
                                  int count = int.parse(_sGuestCount);

                                  widget.partyGuest = widget.partyGuest
                                      .copyWith(guestsCount: count);
                                  widget.partyGuest = widget.partyGuest
                                      .copyWith(guestsRemaining: count);
                                });
                              },
                              items: _currentGuestCounts.map((String value) {
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

              /** admin section **/
              widget.task == 'manage'
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          DarkTextFieldWidget(
                            label: 'phone number *',
                            text: mBlocUser.phoneNumber.toString(),
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 24),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'party',
                              style: TextStyle(
                                  color: Constants.lightPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          _showPartiesDropdown(context),
                          const SizedBox(height: 24),
                          DarkTextFieldWidget(
                            label: 'challenge task',
                            text: findChallenge().title,
                            onChanged: (value) {},
                          ),
                          // const SizedBox(height: 24),
                          // DarkTextFieldWidget(
                          //   label: 'challenge url',
                          //   text: findChallengeUrl(),
                          //   onChanged: (value) {},
                          // ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  'challenge level',
                                  style: TextStyle(
                                      color: Constants.lightPrimary,
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
                                      int level = mBlocUser.challengeLevel;
                                      level--;
                                      setState(() {
                                        mBlocUser = mBlocUser.copyWith(
                                            challengeLevel: level);
                                        FirestoreHelper.pushUser(mBlocUser);
                                      });
                                    },
                                  ),
                                  DarkButtonWidget(
                                    text: mBlocUser.challengeLevel.toString(),
                                    onClicked: () {},
                                  ),
                                  ButtonWidget(
                                    text: 'level up',
                                    onClicked: () {
                                      int level = mBlocUser.challengeLevel;
                                      level++;
                                      setState(() {
                                        mBlocUser = mBlocUser.copyWith(
                                            challengeLevel: level);
                                        FirestoreHelper.pushUser(mBlocUser);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Text('supported: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Constants.lightPrimary,
                                      )),
                                  Checkbox(
                                    value: widget.partyGuest.isChallengeClicked,
                                    side: MaterialStateBorderSide.resolveWith(
                                      (states) => const BorderSide(
                                          width: 1.0, color: Constants.primary),
                                    ),
                                    onChanged: (value) {
                                      widget.partyGuest = widget.partyGuest
                                          .copyWith(isChallengeClicked: value);
                                      PartyGuest freshPartyGuest =
                                          Fresh.freshPartyGuest(
                                              widget.partyGuest);
                                      FirestoreHelper.pushPartyGuest(
                                          freshPartyGuest);

                                      Logx.i(_TAG,
                                          'guest ${'${widget.partyGuest.name} '} : supported $value');

                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('vip ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Constants.lightPrimary,
                                      )),
                                  Checkbox(
                                    value: widget.partyGuest.isVip,
                                    side: MaterialStateBorderSide.resolveWith(
                                      (states) => const BorderSide(
                                          width: 1.0, color: Constants.primary),
                                    ),
                                    onChanged: (value) {
                                      widget.partyGuest = widget.partyGuest
                                          .copyWith(isVip: value);
                                      FirestoreHelper.pushPartyGuest(
                                          widget.partyGuest);

                                      Logx.ist(
                                          _TAG, 'guest vip status: $value');
                                      setState(() {});
                                    },
                                  ),
                                  const Spacer(),
                                  Checkbox(
                                    value: mBlocUser.isBanned,
                                    side: MaterialStateBorderSide.resolveWith(
                                      (states) => const BorderSide(
                                          width: 1.0, color: Constants.primary),
                                    ),
                                    onChanged: (value) {
                                      mBlocUser =
                                          mBlocUser.copyWith(isBanned: value);
                                      blocUser.User freshUser =
                                          Fresh.freshUser(mBlocUser);
                                      FirestoreHelper.pushUser(freshUser);

                                      Logx.i(_TAG,
                                          'user ${'${mBlocUser.name} ${mBlocUser.surname}'} : banned $value');
                                      Toaster.longToast(
                                          'user ${'${mBlocUser.name} ${mBlocUser.surname}'} : banned $value');

                                      setState(() {});
                                    },
                                  ),
                                  const Text(' banned',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Constants.lightPrimary,
                                      )),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('app user ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Constants.lightPrimary,
                                      )),
                                  Checkbox(
                                    value: mBlocUser.isAppUser,
                                    side: MaterialStateBorderSide.resolveWith(
                                      (states) => const BorderSide(
                                          width: 1.0, color: Constants.primary),
                                    ),
                                    onChanged: (value) {
                                      Logx.ist(_TAG,
                                          'app user cannot be changed manually');
                                    },
                                  ),
                                  const Spacer(),
                                  Checkbox(
                                    value: mBlocUser.isAppReviewed,
                                    side: MaterialStateBorderSide.resolveWith(
                                      (states) => const BorderSide(
                                          width: 1.0, color: Constants.primary),
                                    ),
                                    onChanged: (value) {
                                      mBlocUser = mBlocUser.copyWith(
                                          isAppReviewed: value);
                                      blocUser.User freshUser =
                                          Fresh.freshUser(mBlocUser);
                                      FirestoreHelper.pushUser(freshUser);
                                    },
                                  ),
                                  const Text(' app reviewed',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Constants.lightPrimary,
                                      )),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          'promoter',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Constants.lightPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  MultiSelectDialogField(
                                    items: mPromoters
                                        .map((e) => MultiSelectItem(e,
                                            '${e.name.toLowerCase()} | ${e.type.toLowerCase()}'))
                                        .toList(),
                                    initialValue:
                                        sPromoters.map((e) => e).toList(),
                                    listType: MultiSelectListType.CHIP,
                                    buttonIcon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey.shade700,
                                    ),
                                    title: const Text('select a promoter'),
                                    buttonText: const Text(
                                      'select promoter',
                                      style: TextStyle(
                                          color: Constants.lightPrimary),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Constants.background,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      border: Border.all(
                                        color: Constants.primary,
                                        width: 0.0,
                                      ),
                                    ),
                                    searchable: true,
                                    onConfirm: (values) {
                                      sPromoters = values as List<Promoter>;

                                      if (sPromoters.isNotEmpty) {
                                        sPromoterId = sPromoters.first.id;
                                      } else {
                                        sPromoterId = '';
                                      }
                                      setState(() {
                                        widget.partyGuest = widget.partyGuest
                                            .copyWith(promoterId: sPromoterId);
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
                        widget.task == 'manage'
                            ? mBlocUser.appVersion
                            : "* required",
                        style: const TextStyle(
                          color: Constants.primary,
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
                        _showApproveOrNotButton(context),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: ButtonWidget(
                            height: 50,
                            text: 'update',
                            onClicked: () {
                              FirestoreHelper.pushPartyGuest(widget.partyGuest);
                              Logx.ist(
                                  _TAG, 'guest list is successfully updated');
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
                  height: 50,
                  text: (widget.task == 'edit' || widget.task == 'manage')
                      ? 'save changes'
                      : 'join list',
                  onClicked: () {
                    if (widget.task == 'manage') {
                      FirestoreHelper.pushPartyGuest(widget.partyGuest);
                      Logx.ist(_TAG, 'guest list is successfully updated');
                      Navigator.of(context).pop();
                    } else if (widget.task == 'edit') {
                      if (_isDataValid()) {
                        FirestoreHelper.pushPartyGuest(widget.partyGuest);

                        if (hasUserChanged) {
                          blocUser.User freshUser = Fresh.freshUser(mBlocUser);
                          if (freshUser.id == UserPreferences.myUser.id) {
                            UserPreferences.setUser(freshUser);
                          }
                          FirestoreHelper.pushUser(freshUser);
                        }

                        Logx.ist(_TAG, 'guest list has been updated');

                        if ((UserPreferences.myUser.lastReviewTime <
                            Timestamp.now().millisecondsSinceEpoch -
                                (1 * DateTimeUtils.millisecondsWeek))) {
                          if (!UserPreferences.myUser.isAppReviewed) {
                            _showReviewAppDialog(context);
                          } else {
                            //todo: might need to implement challenge logic here
                            Logx.i(_TAG,
                                'app is reviewed, so nothing to do for now');

                            GoRouter.of(context)
                                .pushNamed(RouteConstants.homeRouteName);
                            GoRouter.of(context)
                                .pushNamed(RouteConstants.boxOfficeRouteName);
                          }
                        } else {
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.homeRouteName);
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.boxOfficeRouteName);
                        }
                      }
                    } else {
                      if (_isDataValid()) {
                        if (isLoggedIn) {
                          widget.partyGuest = widget.partyGuest
                              .copyWith(shouldBanUser: mBlocUser.isBanned);

                          if (hasUserChanged) {
                            blocUser.User freshUser =
                                Fresh.freshUser(mBlocUser);
                            if (freshUser.id == UserPreferences.myUser.id) {
                              UserPreferences.setUser(freshUser);
                            }
                            FirestoreHelper.pushUser(freshUser);
                          }

                          if (widget.partyGuest.guestsCount >= 2) {
                            int partyInterestInitCount =
                                mPartyInterest.initCount;
                            partyInterestInitCount +=
                                widget.partyGuest.guestsCount;
                            mPartyInterest = mPartyInterest.copyWith(
                                initCount: partyInterestInitCount);
                            FirestoreHelper.pushPartyInterest(mPartyInterest);

                            if (widget.partyGuest.guestsCount == 2 &&
                                widget.partyGuest.guestStatus == 'couple') {
                              _showRulesConfirmationDialog(context, false);
                            } else {
                              _showGuestsEntryDialog(context);
                            }
                          } else {
                            _showRulesConfirmationDialog(context, false);
                          }
                        } else {
                          // need to register the user first
                          _verifyPhone();
                        }
                      } else {
                        Logx.em(_TAG,
                            'user cannot be entered as data is incomplete');
                      }
                    }
                  },
                ),
              ),
              widget.task == 'edit' || widget.task == 'manage'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 36),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: DarkButtonWidget(
                            height: 50,
                            text: 'delete',
                            onClicked: () {
                              if(mBlocUser.fcmToken.isNotEmpty){
                                _showGuestReviewDialog(context);
                              } else {
                                Navigator.of(context).pop();
                                FirestoreHelper.deletePartyGuest(
                                    widget.partyGuest.id);
                                Logx.ist(_TAG, 'guest list request is deleted!');
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 48),
            ],
          );
  }

  _showApproveOrNotButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ButtonWidget(
        text: !widget.partyGuest.isApproved ? 'approve' : 'un-approve',
        onClicked: () async {
          bool isApproved = !widget.partyGuest.isApproved;

          widget.partyGuest =
              widget.partyGuest.copyWith(isApproved: isApproved);
          FirestoreHelper.pushPartyGuest(widget.partyGuest);

          if (isApproved) {
            if (widget.party.loungeId.isNotEmpty) {
              FirestoreHelper.pullUserLounge(
                  mBlocUser.id, widget.party.loungeId)
                  .then((res) {
                if (res.docs.isEmpty) {
                  UserLounge userLounge = Dummy.getDummyUserLounge();
                  userLounge = userLounge.copyWith(
                      loungeId: widget.party.loungeId,
                      userId: mBlocUser.id,
                      userFcmToken: mBlocUser.fcmToken,
                      isAccepted: true);
                  FirestoreHelper.pushUserLounge(userLounge);

                  if (mBlocUser.fcmToken.isNotEmpty) {
                    String title = widget.party.name;
                    String message =
                        '🥳 yayyy! welcome to ${widget.party.name} family, your guest list for ${widget.party.name} has been approved 🎉, see you and your gang soon! 😎🍾';

                    //send a notification
                    Apis.sendPushNotification(
                        mBlocUser.fcmToken, title, message);
                    Logx.ist(_TAG,
                        'notification has been sent to ${mBlocUser.name} ${mBlocUser.surname}');
                  } else {
                    Logx.d(_TAG,
                        'app user but no fcm token to alert guest approval');
                  }
                } else {
                  if (mBlocUser.fcmToken.isNotEmpty) {
                    String title = widget.party.name;
                    String message =
                        '🥳 yayyy! your guest list for ${widget.party.name} has been approved 🎉, see you and your gang soon! 😎🍾';

                    //send a notification
                    Apis.sendPushNotification(
                        mBlocUser.fcmToken, title, message);
                    Logx.ist(_TAG,
                        'notification has been sent to ${mBlocUser.name} ${mBlocUser.surname}');
                  } else {
                    Logx.d(_TAG,
                        'app user but no fcm token to alert guest approval');
                  }
                }
              });
            } else {
              if (mBlocUser.fcmToken.isNotEmpty) {
                String title = widget.party.name;
                String message =
                    '🥳 yayyy! your guest list for ${widget.party.name} has been approved 🎉, see you and your gang soon! 😎🍾';

                //send a notification
                Apis.sendPushNotification(mBlocUser.fcmToken, title, message);
                Logx.ist(_TAG,
                    'notification has been sent to ${mBlocUser.name} ${mBlocUser.surname}');
              }
            }
            Logx.ist(_TAG, 'party guest ${widget.partyGuest.name} is approved');
          } else {
            Logx.ist(
                _TAG, 'party guest ${widget.partyGuest.name} is unapproved');
          }

          Navigator.of(context).pop();
        },
      ),
    );
  }

  bool _isDataValid() {
    if (widget.partyGuest.name.isEmpty) {
      Logx.em(_TAG, 'name not entered for guest');
      Toaster.longToast('please enter your name');
      return false;
    }
    if (widget.partyGuest.surname.isEmpty) {
      if (mBlocUser.surname.isNotEmpty) {
        widget.partyGuest =
            widget.partyGuest.copyWith(surname: mBlocUser.surname);
      } else {
        Logx.em(_TAG, 'surname not entered for guest');
        Toaster.longToast('please enter your surname / last name');
        return false;
      }
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

  void _onStatusChanged(String? value) {
    setState(() {
      _sGuestStatus = value!;
      widget.partyGuest =
          widget.partyGuest.copyWith(guestStatus: _sGuestStatus);

      if (_sGuestStatus == 'couple') {
        _currentGuestCounts = _coupleGuestCounts;
        _sGuestCount = _currentGuestCounts.first;
      } else if (_sGuestStatus == 'stag') {
        if (widget.party.ticketUrl.isNotEmpty &&
            !widget.party.isTicketsDisabled) {
          _showLimitedGuestListDialog(context);

          // keeping them on as a couple
          _sGuestStatus = 'couple';
          widget.partyGuest = widget.partyGuest.copyWith(guestStatus: 'couple');
          _currentGuestCounts = _coupleGuestCounts;
          _sGuestCount = _currentGuestCounts.first;
        } else {
          _currentGuestCounts = _stagGuestCounts;
          _sGuestCount = _currentGuestCounts.first;
        }
      } else if (_sGuestStatus == 'promoter') {
        _currentGuestCounts = _promoterGuestCounts;
        _sGuestCount = _currentGuestCounts.first;
      } else {
        _currentGuestCounts = _defaultGuestCounts;
        _sGuestCount = _currentGuestCounts.first;
      }

      int count = int.parse(_sGuestCount);
      widget.partyGuest = widget.partyGuest.copyWith(guestsCount: count);
      widget.partyGuest = widget.partyGuest.copyWith(guestsRemaining: count);
    });
  }

  _showGuestsEntryDialog(BuildContext context) {
    int guestCount = widget.partyGuest.guestsCount - 1;

    List<String> guestNames = [];
    for (int i = 0; i < guestCount; i++) {
      guestNames.add('');
    }
    PartyGuestPreferences.setListGuestNames(guestNames);

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            '👫 Roll in smooth: add guests now'.toLowerCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: Colors.black),
          ),
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: guestCount,
              itemBuilder: (BuildContext context, int index) {
                return PartyGuestEntryWidget(
                  partyGuest: widget.partyGuest,
                  index: index + 1,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Constants.darkPrimary),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();

                List<String> guestNames =
                    PartyGuestPreferences.getListGuestNames();
                List<String> names = [];
                for (String name in guestNames) {
                  if (name.trim().isNotEmpty) {
                    names.add(name);
                  }
                }
                widget.partyGuest =
                    widget.partyGuest.copyWith(guestNames: names);

                _showReserveTableDialog(context);
              },
              child: const Text('👍 done',
                  style: TextStyle(color: Constants.primary)),
            ),
          ],
        );
      },
    );
  }

  _showRulesConfirmationDialog(BuildContext context, bool isNewUser) {
    String guestListRules = widget.party.guestListRules.replaceAll(
        '{}', DateTimeUtils.getFormattedTime2(widget.party.guestListEndTime));

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text(
            '🤝 entry and club rules',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text('entry rules:\n'),
                Text(guestListRules.toLowerCase()),
                const Text('\nclub rules:\n'),
                Text(widget.party.clubRules.toLowerCase()),
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
                if (isNewUser) {
                  PartyGuest freshPartyGuest =
                      Fresh.freshPartyGuest(widget.partyGuest);

                  if (!testMode) {
                    FirestoreHelper.pushPartyGuest(freshPartyGuest);
                  }

                  HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
                  historyMusic.userId = widget.partyGuest.guestId;
                  historyMusic.genre = widget.party.genre;
                  historyMusic.count = 1;
                  FirestoreHelper.pushHistoryMusic(historyMusic);
                } else {
                  if (hasUserChanged) {
                    blocUser.User freshUser = Fresh.freshUser(mBlocUser);
                    if (freshUser.id == UserPreferences.myUser.id) {
                      UserPreferences.setUser(freshUser);
                    }
                    FirestoreHelper.pushUser(freshUser);
                  }

                  // need to see if the user already has a guest request
                  widget.partyGuest.guestId = mBlocUser.id;

                  FirestoreHelper.pullPartyGuestByUser(
                          widget.partyGuest.guestId, widget.partyGuest.partyId)
                      .then((res) {
                    Logx.i(_TAG, 'pulled in party guest by user');

                    if (res.docs.isEmpty) {
                      // user has not requested for party guest list, approve
                      PartyGuest freshPartyGuest =
                          Fresh.freshPartyGuest(widget.partyGuest);
                      if (!testMode) {
                        FirestoreHelper.pushPartyGuest(freshPartyGuest);
                      }

                      Logx.ilt(_TAG, 'guest list request in box office');

                      FirestoreHelper.pullHistoryMusic(
                              widget.partyGuest.guestId, widget.party.genre)
                          .then((res) {
                        if (res.docs.isEmpty) {
                          // no history, add new one
                          HistoryMusic historyMusic =
                              Dummy.getDummyHistoryMusic();

                          historyMusic = historyMusic.copyWith(
                              userId: widget.partyGuest.guestId,
                              genre: widget.party.genre,
                              count: 1);
                          FirestoreHelper.pushHistoryMusic(historyMusic);
                        } else {
                          if (res.docs.length > 1) {
                            // that means there are multiple, so consolidate
                            HistoryMusic hm = Dummy.getDummyHistoryMusic();
                            int totalCount = 0;

                            for (int i = 0; i < res.docs.length; i++) {
                              DocumentSnapshot document = res.docs[i];
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              final HistoryMusic historyMusic =
                                  Fresh.freshHistoryMusicMap(data, false);

                              totalCount += historyMusic.count;
                              if (i == 0) {
                                hm = historyMusic;
                              }
                              FirestoreHelper.deleteHistoryMusic(
                                  historyMusic.id);
                            }

                            totalCount = totalCount + 1;
                            hm = hm.copyWith(count: totalCount);
                            FirestoreHelper.pushHistoryMusic(hm);
                          } else {
                            DocumentSnapshot document = res.docs[0];
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;

                            HistoryMusic historyMusic =
                                Fresh.freshHistoryMusicMap(data, false);
                            int newCount = historyMusic.count + 1;
                            historyMusic =
                                historyMusic.copyWith(count: newCount);
                            FirestoreHelper.pushHistoryMusic(historyMusic);
                          }
                        }
                      });

                      if (widget.party.isChallengeActive) {
                        Navigator.of(ctx).pop();
                        _loadChallengeDialog(context);
                      } else {
                        Navigator.of(ctx).pop();

                        GoRouter.of(context)
                            .pushNamed(RouteConstants.homeRouteName);
                        GoRouter.of(context)
                            .pushNamed(RouteConstants.boxOfficeRouteName);
                      }
                    } else {
                      //already requested
                      Logx.ist(_TAG, 'guest list has already been requested!');

                      GoRouter.of(context)
                          .pushNamed(RouteConstants.homeRouteName);
                      GoRouter.of(context)
                          .pushNamed(RouteConstants.boxOfficeRouteName);
                    }
                  });
                }
              },
              child: const Text('👍 accept',
                  style: TextStyle(color: Constants.primary)),
            ),
          ],
        );
      },
    );
  }

  Challenge findChallenge() {
    Challenge returnChallenge = challenges.last;

    if (widget.party.overrideChallengeNum > 0) {
      for (Challenge challenge in challenges) {
        if (challenge.level == widget.party.overrideChallengeNum) {
          return challenge;
        }
      }
    } else {
      for (Challenge challenge in challenges) {
        if (challenge.level >= mBlocUser.challengeLevel) {
          return challenge;
        }
      }
    }

    return returnChallenge;
  }

  _loadChallengeDialog(BuildContext context) {
    Challenge challenge = findChallenge();
    String challengeText = challenge.description;

    if (challengeText.isEmpty) {
      // all challenges are completed
      Navigator.of(context).pop();

      if (kIsWeb) {
        _showDownloadAppDialog(context);
      } else {
        GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
        GoRouter.of(context).pushNamed(RouteConstants.boxOfficeRouteName);
      }
    } else {
      FirestoreHelper.pullChallengeActions(challenge.id).then((res) {
        if (res.docs.isNotEmpty) {
          List<ChallengeAction> cas = [];
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            ChallengeAction ca = Fresh.freshChallengeActionMap(data, false);

            if (ca.actionType == 'instagram_url') {
              ca = ca.copyWith(action: widget.party.instagramUrl);
            } else if (ca.actionType == 'bloc_url') {
              final url =
                  'http://bloc.bar/#/event/${Uri.encodeComponent(widget.party.name)}/${widget.party.chapter}';
              ca = ca.copyWith(action: url);
            }
            cas.add(ca);
          }

          _showChallengeDialog(context, challenge, cas);
        } else {
          _showChallengeDefaultsDialog(context, challenge);
        }
      });
    }
  }

  void _showChallengeDialog(
      BuildContext context, Challenge challenge, List<ChallengeAction> cas) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              '#blocCommunity support & win free 🎟️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    '${challenge.dialogTitle}:\n',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(challenge.description.toLowerCase()),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(ctx).pop();

                  if (kIsWeb) {
                    _showDownloadAppDialog(context);
                  } else {
                    GoRouter.of(context)
                        .pushNamed(RouteConstants.homeRouteName);
                    GoRouter.of(context)
                        .pushNamed(RouteConstants.boxOfficeRouteName);
                  }
                },
              ),
              cas.length > 1
                  ? TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Constants.darkPrimary),
                      ),
                      child: Text(cas[1].buttonTitle,
                          style: const TextStyle(color: Constants.primary)),
                      onPressed: () async {
                        Logx.ist(_TAG, 'thank you for supporting us!');

                        widget.partyGuest = widget.partyGuest
                            .copyWith(isChallengeClicked: true);
                        if (!testMode) {
                          FirestoreHelper.pushPartyGuest(widget.partyGuest);
                          FirestoreHelper.updateChallengeClickCount(
                              challenge.id);
                        }

                        final uri = Uri.parse(cas[1].action);

                        if (cas[1].actionType == 'bloc_url') {
                          Share.share(
                              'Check out ${widget.party.name} on #blocCommunity $uri');
                        } else {
                          NetworkUtils.launchInBrowser(uri);
                        }

                        Navigator.of(ctx).pop();

                        if (kIsWeb) {
                          _showDownloadAppDialog(context);
                        } else {
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.homeRouteName);
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.boxOfficeRouteName);
                        }
                      },
                    )
                  : const SizedBox(),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Constants.darkPrimary),
                ),
                child: Text(cas[0].buttonTitle,
                    style: const TextStyle(color: Constants.primary)),
                onPressed: () async {
                  Logx.ist(_TAG, 'thank you for supporting us!');

                  widget.partyGuest =
                      widget.partyGuest.copyWith(isChallengeClicked: true);
                  if (!testMode) {
                    FirestoreHelper.pushPartyGuest(widget.partyGuest);
                    FirestoreHelper.updateChallengeClickCount(challenge.id);
                  }

                  final uri = Uri.parse(cas[0].action);

                  if (cas[0].actionType == 'bloc_url') {
                    Share.share(
                        'Check out ${widget.party.name} on #blocCommunity $uri');
                  } else {
                    NetworkUtils.launchInBrowser(uri);
                  }

                  Navigator.of(ctx).pop();

                  if (kIsWeb) {
                    _showDownloadAppDialog(context);
                  } else {
                    GoRouter.of(context)
                        .pushNamed(RouteConstants.homeRouteName);
                    GoRouter.of(context)
                        .pushNamed(RouteConstants.boxOfficeRouteName);
                  }
                },
              ),
            ],
          );
        });
  }

  void _showChallengeDefaultsDialog(BuildContext context, Challenge challenge) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              '#blocCommunity support & win free 🎟️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    '${challenge.dialogTitle}:\n',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(challenge.description.toLowerCase()),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(ctx).pop();

                  GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.boxOfficeRouteName);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Constants.darkPrimary),
                ),
                child: Text(challenge.dialogAcceptText,
                    style: const TextStyle(color: Constants.primary)),
                onPressed: () async {
                  Logx.ist(_TAG, 'thank you for supporting us!');

                  widget.partyGuest =
                      widget.partyGuest.copyWith(isChallengeClicked: true);
                  if (!testMode) {
                    FirestoreHelper.pushPartyGuest(widget.partyGuest);
                    FirestoreHelper.updateChallengeClickCount(challenge.id);
                  }

                  if (widget.party.storyImageUrl.isNotEmpty ||
                      widget.party.imageUrl.isNotEmpty) {
                    final urlImage = widget.party.storyImageUrl.isNotEmpty
                        ? widget.party.storyImageUrl
                        : widget.party.imageUrl;
                    if (kIsWeb) {
                      FileUtils.openFileNewTabForWeb(urlImage);
                    } else {
                      FileUtils.sharePhoto(
                          widget.party.id,
                          urlImage,
                          'bloc-${widget.party.name}',
                          ''
                              '${StringUtils.firstFewWords(widget.party.description, 15)}... '
                              '\n\nhey. check out this event at the official bloc app. \n\n🌏 '
                              'https://bloc.bar/#/\n📱 https://bloc.bar/app_store.html\n\n#blocCommunity ❤️‍🔥');
                    }
                  } else {
                    final uri =
                        Uri.parse('https://www.instagram.com/bloc.india/');
                    NetworkUtils.launchInBrowser(uri);
                  }

                  Navigator.of(ctx).pop();
                  GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.boxOfficeRouteName);
                },
              ),
            ],
          );
        });
  }

  _showReserveTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: mq.height * 0.5,
            width: double.maxFinite,
            child: ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Take it to the next level, reserve! 👑',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                ),
                Text(
                    'Would you and your friends like to elevate your event experience during the event? Reserve a table and make the night unforgettable!'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'cancel',
                style: TextStyle(color: Constants.background),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();

                _showRulesConfirmationDialog(context, false);
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text("🛎️ reserve my table",
                  style: TextStyle(color: Constants.primary)),
              onPressed: () {
                Navigator.of(ctx).pop();

                int? phoneNumber = int.tryParse(widget.partyGuest.phone);

                Reservation reservation =
                    Dummy.getDummyReservation(Constants.blocServiceId);
                reservation = reservation.copyWith(
                  customerId: widget.partyGuest.guestId,
                  name:
                      '${widget.partyGuest.name} ${widget.partyGuest.surname}',
                  phone: phoneNumber,
                  arrivalDate: widget.party.startTime,
                  arrivalTime:
                      DateTimeUtils.getFormattedTime2(widget.party.startTime),
                  guestsCount: widget.partyGuest.guestsCount,
                  blocServiceId: widget.party.blocServiceId,
                );

                if (!testMode) {
                  FirestoreHelper.pushReservation(reservation);
                }

                _showRulesConfirmationDialog(context, false);
                Logx.ilt(_TAG,
                    '👑 your table reservation confirmation is at the box office!');
              },
            ),
          ],
        );
      },
    );
  }

  _showLimitedGuestListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: mq.height * 0.5,
            width: double.maxFinite,
            child: ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'very limited guest list event',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                ),
                Text(
                    "This event's all about couples 💏 and ladies 💃🏼, sorry to say but no stags 🕴️ in the mix. "
                    "Grab your passes now while they're priced oh so great, coz at the gate "
                    "you'll wish you'd have got them now. Get your tickets now?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'cancel',
                style: TextStyle(color: Constants.background),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text("🎟️ buy ticket",
                  style: TextStyle(color: Constants.primary)),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();

                final uri = Uri.parse(widget.party.ticketUrl);
                NetworkUtils.launchInBrowser(uri);

                Logx.ist(
                    _TAG, 'thank you for considering to buy the ticket 🤗');
              },
            ),
          ],
        );
      },
    );
  }

  _showPartiesDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            key: const ValueKey('parties_key'),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorStyle: const TextStyle(
                    color: Constants.errorColor, fontSize: 16.0),
                hintText: 'please select party',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Constants.primary),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Constants.primary, width: 0.0),
                )),
            isEmpty: sPartyName == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: const TextStyle(color: Constants.lightPrimary),
                dropdownColor: Constants.background,
                value: sPartyName,
                isDense: true,
                onChanged: (String? newValue) {
                  setState(() {
                    sPartyName = newValue!;

                    for (Party party in mParties) {
                      if ('${party.name} ${party.chapter}' == sPartyName) {
                        sPartyId = party.id;
                        sParty = party;
                        break;
                      }
                    }

                    widget.partyGuest =
                        widget.partyGuest.copyWith(partyId: sPartyId);
                    FirestoreHelper.pushPartyGuest(widget.partyGuest);
                    Logx.ist(_TAG, 'guest list updated to party: $sPartyName');

                    state.didChange(newValue);
                  });
                },
                items: mPartyNames.map((String value) {
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
    );
  }

  /** phone registration **/
  void _verifyPhone() async {
    Logx.i(_TAG, '_verifyPhone: registering $completePhoneNumber');

    if (kIsWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber(completePhoneNumber, null)
          .then((firebaseUser) {
        Logx.i(_TAG,
            'signInWithPhoneNumber: user verification id ${firebaseUser.verificationId}');

        _showOTPDialog(context);

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
                'verifyPhoneNumber: $completePhoneNumber is verified. attempting sign in with credentials...');
          },
          verificationFailed: (FirebaseAuthException e) {
            Logx.em(_TAG, 'verificationFailed $e');
          },
          codeSent: (String verificationID, int? resendToken) {
            Logx.i(_TAG, 'verification id : $verificationID');

            if (mounted) {
              _showOTPDialog(context);

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

  _showOTPDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'phone number verification',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: FractionallySizedBox(
                        widthFactor: 1,
                        child: _showOTPVerifyWidget(
                          completePhoneNumber,
                        )),
                  ),
                ),
                Center(
                    child: Text(
                  'enter the six digit code you received on \n$completePhoneNumber',
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
                        child: const DelayedDisplay(
                          delay: Duration(seconds: 10),
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
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showOTPVerifyWidget(String phone) {
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
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) async {
                debugPrint('onCompleted: $pin');

                Logx.ist(
                    _TAG, 'verifying $completePhoneNumber, please wait...');
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      Logx.i(_TAG, 'user is in firebase auth');
                      Logx.i(_TAG,
                          'checking for bloc registration, id ${value.user!.uid}');

                      FirestoreHelper.pullUser(value.user!.uid).then((res) {
                        if (res.docs.isEmpty) {
                          Logx.i(_TAG,
                              'user is not already registered in bloc, registering...');

                          mBlocUser = mBlocUser.copyWith(
                            id: value.user!.uid,
                            name: widget.partyGuest.name,
                            surname: widget.partyGuest.surname,
                            gender: widget.partyGuest.gender,
                            phoneNumber:
                                StringUtils.getInt(value.user!.phoneNumber!),
                          );

                          if (kIsWeb) {
                            mBlocUser = mBlocUser.copyWith(isAppUser: false);
                          } else {
                            mBlocUser = mBlocUser.copyWith(
                              isAppUser: true,
                              appVersion: Constants.appVersion,
                              isIos: Theme.of(context).platform ==
                                  TargetPlatform.iOS,
                            );
                          }

                          FirestoreHelper.pushUser(mBlocUser);
                          Logx.i(_TAG, 'registered user ${mBlocUser.id}');

                          UserLounge userLounge = Dummy.getDummyUserLounge();
                          userLounge = userLounge.copyWith(
                              userId: mBlocUser.id,
                              userFcmToken: mBlocUser.fcmToken,
                              loungeId: Constants.blocCommunityLoungeId);
                          FirestoreHelper.pushUserLounge(userLounge);

                          UserPreferences.setUser(mBlocUser);

                          widget.partyGuest = widget.partyGuest.copyWith(
                              guestId: mBlocUser.id,
                              phone: mBlocUser.phoneNumber.toString());

                          _showRulesConfirmationDialog(context, true);
                        } else {
                          Logx.i(_TAG,
                              'user is a bloc member. navigating to main...');

                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          blocUser.User user = Fresh.freshUserMap(data, true);

                          //update user details
                          int time = Timestamp.now().millisecondsSinceEpoch;
                          user = user.copyWith(lastSeenAt: time);

                          if (user.name.isEmpty) {
                            user = user.copyWith(name: widget.partyGuest.name);
                          }
                          if (user.surname.isEmpty) {
                            user = user.copyWith(
                                surname: widget.partyGuest.surname);
                          }
                          if (user.email.isEmpty) {
                            user =
                                user.copyWith(email: widget.partyGuest.email);
                          }

                          if (kIsWeb) {
                            user = user.copyWith(isAppUser: false);
                          } else {
                            user = user.copyWith(
                              isAppUser: true,
                              appVersion: Constants.appVersion,
                              isIos: Theme.of(context).platform ==
                                  TargetPlatform.iOS,
                            );
                          }

                          FirestoreHelper.pushUser(user);
                          UserPreferences.setUser(user);
                          mBlocUser = user;

                          widget.partyGuest = widget.partyGuest.copyWith(
                              guestId: mBlocUser.id,
                              phone: mBlocUser.phoneNumber.toString());
                          _showRulesConfirmationDialog(context, false);
                        }
                      });
                    }
                  });
                } catch (e) {
                  Logx.em(_TAG, 'otp error $e');

                  String exception = e.toString();
                  if (exception.contains('session-expired')) {
                    Logx.ist(_TAG, 'session got expired, trying again');
                    _verifyPhone();
                  } else {
                    Logx.ist(_TAG, 'invalid otp, please try again');
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

  _showDownloadAppDialog(BuildContext context) {
    String message =
        '📲 Download our app now and be the first to know when your guest list request is approved! Plus, unlock access to all the amazing community photos and much more! 🎉📸';

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              '🎁 get notified when GL approved',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: Text(message.toLowerCase()),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  _showAdDialog(context);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Constants
                      .darkPrimary), // Set your desired background color
                ),
                child: const Text('🤖 android',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  final uri = Uri.parse(ChallengeUtils.urlBlocPlayStore);
                  NetworkUtils.launchInBrowser(uri);

                  GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.boxOfficeRouteName);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Constants
                      .darkPrimary), // Set your desired background color
                ),
                child: const Text('🍎 ios',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  final uri = Uri.parse(ChallengeUtils.urlBlocAppStore);
                  NetworkUtils.launchInBrowser(uri);

                  GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.boxOfficeRouteName);
                },
              ),
            ],
          );
        });
  }

  void _showReviewAppDialog(BuildContext context) {
    String message =
        '🌟 Love our app? Help us make it even better! Leave a review today and get notified with instant guest list approvals, community photos, and more! 📸🎉';

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              '🍭 review our app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: Text(message.toLowerCase()),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(ctx).pop();

                  GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.boxOfficeRouteName);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Constants.lightPrimary),
                ),
                child: const Text(
                  '🧸 already reviewed',
                ),
                onPressed: () async {
                  blocUser.User user = UserPreferences.myUser;
                  user = user.copyWith(isAppReviewed: true);
                  UserPreferences.setUser(user);
                  FirestoreHelper.pushUser(user);

                  Logx.ist(_TAG, '🃏 thank you for already reviewing us');
                  Navigator.of(ctx).pop();

                  GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.boxOfficeRouteName);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Constants.darkPrimary),
                ),
                child: const Text('🌟 review us',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  final InAppReview inAppReview = InAppReview.instance;
                  bool isAvailable = await inAppReview.isAvailable();

                  if (isAvailable) {
                    inAppReview.requestReview();
                  } else {
                    inAppReview.openStoreListing(
                        appStoreId: Constants.blocAppStoreId);
                  }

                  blocUser.User user = UserPreferences.myUser;
                  user = user.copyWith(
                      isAppReviewed: true,
                      lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
                  UserPreferences.setUser(user);
                  FirestoreHelper.pushUser(user);

                  Navigator.of(ctx).pop();

                  GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.boxOfficeRouteName);
                },
              ),
            ],
          );
        });
  }

  _showGuestReviewDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              'request google review',
              style: TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'request for google review from ${mBlocUser.name} ${mBlocUser.surname}. are you sure you want to ask?'),
            actions: [
              TextButton(
                child: const Text('review bloc'),
                onPressed: () async {
                  if(mBlocUser.fcmToken.isNotEmpty){
                    //send a notification
                    Apis.sendUrlData(mBlocUser.fcmToken, Apis.GoogleReviewBloc, Constants.blocGoogleReview);
                    Logx.ist(_TAG,
                        '${mBlocUser.name} ${mBlocUser.surname} has been notified for a bloc google review 🤞');
                  }

                  Navigator.of(ctx).pop();
                  FirestoreHelper.deletePartyGuest(
                      widget.partyGuest.id);
                  Logx.ist(_TAG, 'guest list request is deleted!');
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('review freq'),
                onPressed: () async {
                  if(mBlocUser.fcmToken.isNotEmpty){
                    //send a notification
                    Apis.sendUrlData(mBlocUser.fcmToken, Apis.GoogleReviewFreq, Constants.freqGoogleReview);
                    Logx.ist(_TAG,
                        '${mBlocUser.name} ${mBlocUser.surname} has been notified for a freq google review 🤞');
                  }

                  Navigator.of(ctx).pop();
                  FirestoreHelper.deletePartyGuest(
                      widget.partyGuest.id);
                  Logx.ist(_TAG, 'guest list request is deleted!');
                  Navigator.of(context).pop();
                },
              ),

              TextButton(
                child: const Text("cancel"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  FirestoreHelper.deletePartyGuest(
                      widget.partyGuest.id);
                  Logx.ist(_TAG, 'guest list request is deleted!');
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _showAdDialog(BuildContext context) {
    FirestoreHelper.pullAdCampaignByStorySize(true).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        AdCampaign adCampaign = Fresh.freshAdCampaignMap(data, false);

        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              content: SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
                child: FadeInImage(
                  placeholder: const AssetImage('assets/icons/logo.png'),
                  image: NetworkImage(adCampaign.imageUrls[0]),
                  fit: BoxFit.cover,
                )
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();

                    GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
                    GoRouter.of(context)
                        .pushNamed(RouteConstants.boxOfficeRouteName);
                  },
                  child: Text('close'),
                ),
              ],
            );
          },
        );
      } else {
        // no ad campaings found
        GoRouter.of(context).pushNamed(RouteConstants.homeRouteName);
        GoRouter.of(context)
            .pushNamed(RouteConstants.boxOfficeRouteName);
      }
    });


  }


}
