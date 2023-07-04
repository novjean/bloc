import 'dart:io';

import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/db/entity/reservation.dart';
import 'package:bloc/db/entity/user_lounge.dart';
import 'package:bloc/utils/date_time_utils.dart';
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
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../../api/apis.dart';
import '../../db/entity/challenge.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/party_interest.dart';
import '../../db/entity/promoter.dart';
import '../../db/entity/user.dart' as blocUser;
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/dark_textfield_widget.dart';
import '../../widgets/parties/party_banner.dart';
import '../user/reservation_add_edit_screen.dart';

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

  @override
  void initState() {
    if (!UserPreferences.isUserLoggedIn()) {
      bloc_user = Dummy.getDummyUser();
    } else {
      bloc_user = UserPreferences.myUser;
    }

    FirestoreHelper.pullUser(widget.partyGuest.guestId).then((res) {
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

    sPartyId = widget.partyGuest.partyId;
    FirestoreHelper.pullActiveGuestListParties(Timestamp.now().millisecondsSinceEpoch).then((res) {
      if (res.docs.isNotEmpty) {
        // found parties
        List<Party> parties = [];
        List<String> _partyNames = ['all'];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, true);
          parties.add(party);
          String partyTitle = '${party.name} ${party.chapter}';
          _partyNames.add(partyTitle);

          if(party.id == sPartyId){
            sPartyName = partyTitle;
            sParty = party;
          }
        }
        setState(() {
          mParties = parties;
          mPartyNames = _partyNames;
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

    sPromoterId =  widget.partyGuest.promoterId;
    FirestoreHelper.pullPromoters().then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Promoter promoter = Fresh.freshPromoterMap(data, false);
          mPromoters.add(promoter);

          if(promoter.id == sPromoterId){
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
      guestCounts.add(i.toString());
    }
    sGuestCount = widget.partyGuest.guestsCount.toString();
    sGuestStatus = widget.partyGuest.guestStatus;
    sGender = widget.partyGuest.gender;
    super.initState();

    if(UserPreferences.isUserLoggedIn()){
      FirestoreHelper.pullPartyInterest(widget.party.id).then((res) {
        if(res.docs.isNotEmpty){
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          mPartyInterest = Fresh.freshPartyInterestMap(data, false);
          if(!mPartyInterest.userIds.contains(UserPreferences.myUser.id)){
            mPartyInterest.userIds.add(UserPreferences.myUser.id);
            FirestoreHelper.pushPartyInterest(mPartyInterest);
            Logx.d(_TAG, 'user interest recorded for party');
          } else {
            Logx.d(_TAG, 'user interest previously recorded for party');
          }

        } else {
          mPartyInterest = mPartyInterest.copyWith(partyId: widget.party.id, userIds: [UserPreferences.myUser.id]);
          FirestoreHelper.pushPartyInterest(mPartyInterest);

          Logx.d(_TAG, 'party interest created for party');
        }

        if(widget.task == 'manage'){
          if(!mPartyInterest.userIds.contains(widget.partyGuest.guestId)){
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
    return isCustomerLoading && isChallengesLoading
        && _isPartiesLoading && _isPromotersLoading
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
                  label: 'surname *',
                  text: bloc_user.surname,
                  onChanged: (surname) {
                    bloc_user = bloc_user.copyWith(surname: surname);
                    hasUserChanged = true;

                    widget.partyGuest =
                        widget.partyGuest.copyWith(surname: surname);
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
                    label: 'email${widget.party.isEmailRequired ? ' *' : ''}',
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
                            'gender *',
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
                              dropdownColor: Constants.background,
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
                      text: bloc_user.phoneNumber.toString(),
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'party',
                        style: TextStyle(
                            color:
                            Theme.of(context).primaryColorLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    _displayPartiesDropdown(context),
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
                                int level = bloc_user.challengeLevel;
                                level--;
                                setState(() {
                                  bloc_user = bloc_user.copyWith(
                                      challengeLevel: level);
                                  FirestoreHelper.pushUser(bloc_user);
                                });
                              },
                            ),
                            DarkButtonWidget(
                              text: bloc_user.challengeLevel.toString(),
                              onClicked: () {},
                            ),
                            ButtonWidget(
                              text: 'level up',
                              onClicked: () {
                                int level = bloc_user.challengeLevel;
                                level++;
                                setState(() {
                                  bloc_user = bloc_user.copyWith(
                                      challengeLevel: level);
                                  FirestoreHelper.pushUser(bloc_user);
                                });
                              },
                            ),
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
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                        color: Constants.lightPrimary),
                                  ),
                                ),
                              ],
                            ),
                            MultiSelectDialogField(
                              items: mPromoters
                                  .map((e) => MultiSelectItem(
                                  e, '${e.name.toLowerCase()} | ${e.type.toLowerCase()}'))
                                  .toList(),
                              initialValue: sPromoters.map((e) => e).toList(),
                              listType: MultiSelectListType.CHIP,
                              buttonIcon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade700,
                              ),
                              title: const Text('select a promoter'),
                              buttonText: const Text(
                                'select promoter',
                                style: TextStyle(color: Constants.lightPrimary),
                              ),
                              decoration: BoxDecoration(
                                color: Constants.background,
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                border: Border.all(
                                  color: Constants.primary,
                                  width: 0.0,
                                ),
                              ),
                              searchable: true,
                              onConfirm: (values) {
                                sPromoters = values as List<Promoter>;

                                if(sPromoters.isNotEmpty){
                                  sPromoterId = sPromoters.first.id;
                                } else {
                                  sPromoterId = '';
                                }
                                setState(() {
                                  widget.partyGuest = widget.partyGuest.copyWith(promoterId: sPromoterId);
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
                              value: widget.partyGuest.isChallengeClicked,
                              side: MaterialStateBorderSide.resolveWith(
                                    (states) => BorderSide(width: 1.0, color: Constants.primary),
                              ),
                              onChanged: (value) {
                                widget.partyGuest = widget.partyGuest.copyWith(isChallengeClicked: value);
                                PartyGuest freshPartyGuest = Fresh.freshPartyGuest(widget.partyGuest);
                                FirestoreHelper.pushPartyGuest(freshPartyGuest);

                                Logx.i(_TAG, 'guest ${'${widget.partyGuest.name} '} : supported $value');

                                setState(() {});
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
                              value: bloc_user.isBanned,
                              side: MaterialStateBorderSide.resolveWith(
                                    (states) => BorderSide(width: 1.0, color: Constants.primary),
                              ),
                              onChanged: (value) {
                                bloc_user = bloc_user.copyWith(isBanned: value);
                                blocUser.User freshUser = Fresh.freshUser(bloc_user);
                                FirestoreHelper.pushUser(freshUser);

                                Logx.i(_TAG, 'user ${'${bloc_user.name} ${bloc_user.surname}'} : banned $value');
                                Toaster.longToast('user ${'${bloc_user.name} ${bloc_user.surname}'} : banned $value');

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
                        widget.partyGuest = widget.partyGuest.copyWith(isApproved: true);
                        FirestoreHelper.pushPartyGuest(widget.partyGuest);

                        if(widget.party.loungeId.isNotEmpty){
                          FirestoreHelper.pullUserLounge(bloc_user.id, widget.party.loungeId).then((res) {
                            if(res.docs.isEmpty){
                              UserLounge userLounge = Dummy.getDummyUserLounge();
                              userLounge = userLounge.copyWith(loungeId: widget.party.loungeId,
                                userId: bloc_user.id, isAccepted: true);
                              FirestoreHelper.pushUserLounge(userLounge);

                              if(bloc_user.fcmToken.isNotEmpty){
                                String title = widget.party.name;
                                String message = 'welcome to ${widget.party.name} family, your guest list request is approved!';

                                //send a notification
                                Apis.sendPushNotification(bloc_user.fcmToken, title, message);
                              }
                            }
                          });
                        } else {
                          if(bloc_user.fcmToken.isNotEmpty){
                            String title = widget.party.name;
                            String message = 'your guest list request has been approved, see you soon!';

                            //send a notification
                            Apis.sendPushNotification(bloc_user.fcmToken, title, message);
                          }
                        }

                        Logx.i(_TAG, 'party guest ${widget.partyGuest.name} is approved');
                        Toaster.longToast('party guest ${widget.partyGuest.name} is approved');
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
                  text: (widget.task == 'edit' || widget.task == 'manage') ? 'save changes' : 'join list',
                  onClicked: () {
                    if (isDataValid()) {
                      if (isLoggedIn) {
                        if(widget.task == 'manage'){
                          FirestoreHelper.pushPartyGuest(widget.partyGuest);

                          GoRouter.of(context)
                              .pushNamed(RouteConstants.homeRouteName);
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.boxOfficeRouteName);
                        } else if(widget.task == 'edit') {
                          FirestoreHelper.pushPartyGuest(widget.partyGuest);

                          if (hasUserChanged) {
                            blocUser.User freshUser = Fresh.freshUser(bloc_user);
                            if (freshUser.id == UserPreferences.myUser.id) {
                              UserPreferences.setUser(freshUser);
                            }
                            FirestoreHelper.pushUser(freshUser);
                          }
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.homeRouteName);
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.boxOfficeRouteName);
                        } else {
                          showRulesConfirmationDialog(context, false);
                        }
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
                            height: 50,
                            text: 'delete',
                            onClicked: () {
                              FirestoreHelper.deletePartyGuest(widget.partyGuest);
                              Logx.ist(_TAG, 'guest list request is deleted!');
                              Navigator.of(context).pop();
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
                        '${widget.party.eventName} | ${widget.party.name}',
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
                if (isNewUser) {
                  PartyGuest freshPartyGuest =
                      Fresh.freshPartyGuest(widget.partyGuest);
                  FirestoreHelper.pushPartyGuest(freshPartyGuest);

                  HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
                  historyMusic.userId = widget.partyGuest.guestId;
                  historyMusic.genre = widget.party.genre;
                  historyMusic.count = 1;
                  FirestoreHelper.pushHistoryMusic(historyMusic);

                } else {
                  if (hasUserChanged) {
                    blocUser.User freshUser = Fresh.freshUser(bloc_user);
                    if (freshUser.id == UserPreferences.myUser.id) {
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

                    if (res.docs.isEmpty ||
                        widget.task == 'edit' ||
                        widget.task == 'manage') {
                      // user has not requested for party guest list, approve
                      PartyGuest freshPartyGuest =
                          Fresh.freshPartyGuest(widget.partyGuest);
                      FirestoreHelper.pushPartyGuest(freshPartyGuest);

                      Logx.i(_TAG, 'guest list request in box office');
                      Toaster.longToast('guest list request in box office');

                      FirestoreHelper.pullHistoryMusic(widget.partyGuest.guestId, widget.party.genre)
                          .then((res) {
                            if(res.docs.isEmpty){
                              // no history, add new one
                              HistoryMusic historyMusic = Dummy.getDummyHistoryMusic();
                              historyMusic.userId = widget.partyGuest.guestId;
                              historyMusic.genre = widget.party.genre;
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
                      Logx.ist(_TAG, 'guest list has already been requested!');
                    }
                  });
                }

                Navigator.of(ctx).pop();

                if (widget.party.isChallengeActive) {
                  showChallengeDialog(context);
                } else {
                  Navigator.of(context).pop();

                  GoRouter.of(context)
                      .pushNamed(RouteConstants.homeRouteName);
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.boxOfficeRouteName);
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

      GoRouter.of(context)
          .pushNamed(RouteConstants.homeRouteName);
      GoRouter.of(context)
          .pushNamed(RouteConstants.boxOfficeRouteName);
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
                            '#blocCommunity  | ${widget.party.name}',
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

                  widget.partyGuest = widget.partyGuest.copyWith(isChallengeClicked: true);
                  FirestoreHelper.pushPartyGuest(widget.partyGuest);

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
                  Logx.ist(_TAG, 'thank you for supporting us!');

                  widget.partyGuest = widget.partyGuest.copyWith(isChallengeClicked: true);
                  FirestoreHelper.pushPartyGuest(widget.partyGuest);

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
                      final uri = Uri.parse(widget.party.instagramUrl);
                      NetworkUtils.launchInBrowser(uri);
                      break;
                    }
                    case 100:
                      {
                        final urlImage = widget.party.storyImageUrl.isNotEmpty
                            ? widget.party.storyImageUrl
                            : widget.party.imageUrl;
                        final Uri url = Uri.parse(urlImage);
                        final response = await http.get(url);
                        final Uint8List bytes = response.bodyBytes;

                        try {
                          if (kIsWeb) {
                            FileUtils.openFileNewTabForWeb(urlImage);

                            // Image? fromPicker = await ImagePickerWeb.getImageAsWidget();
                          } else {
                            var temp = await getTemporaryDirectory();
                            final path = '${temp.path}/${widget.party.id}.jpg';
                            File(path).writeAsBytesSync(bytes);

                            final files = <XFile>[];
                            files.add(
                                XFile(path, name: '${widget.party.id}.jpg'));

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
                        'reserve table | ${widget.party.name}',
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

                UserPreferences.setUser(bloc_user);
                GoRouter.of(context)
                    .pushNamed(RouteConstants.homeRouteName);
                GoRouter.of(context)
                    .pushNamed(RouteConstants.boxOfficeRouteName);
              },
            ),
            TextButton(
              child: const Text("reserve my table"),
              onPressed: () {
                Reservation reservation  = Dummy.getDummyReservation(Constants.blocServiceId);
                reservation = reservation.copyWith(customerId: widget.partyGuest.guestId);
                reservation = reservation.copyWith(name: '${widget.partyGuest.name} ${widget.partyGuest.surname}');
                int? phoneNumber = int.tryParse(widget.partyGuest.phone);
                reservation = reservation.copyWith(phone: phoneNumber);

                reservation = reservation.copyWith(arrivalDate: widget.party.startTime);
                reservation = reservation.copyWith(arrivalTime: DateTimeUtils.getFormattedTime2(widget.party.startTime));

                reservation = reservation.copyWith(guestsCount: widget.partyGuest.guestsCount);

                Navigator.of(ctx).pop();
                Navigator.of(context).pop();

                UserPreferences.setUser(bloc_user);
                GoRouter.of(context)
                    .pushNamed(RouteConstants.homeRouteName);

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

    if(widget.party.overrideChallengeNum>0){
      for (Challenge challenge in challenges) {
        if (challenge.level == widget.party.overrideChallengeNum) {
          return challenge;
        }
      }
    } else {
      for (Challenge challenge in challenges) {
        if (challenge.level >= bloc_user.challengeLevel) {
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
                'verifyPhoneNumber: $completePhoneNumber is verified. attempting sign in with credentials...');
          },
          verificationFailed: (FirebaseAuthException e) {
            Logx.em(_TAG, 'verificationFailed $e');
          },
          codeSent: (String verificationID, int? resendToken) {
            Logx.i(_TAG, 'verification id : $verificationID');

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
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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

                          bloc_user.id = value.user!.uid;
                          bloc_user.phoneNumber =
                              StringUtils.getInt(value.user!.phoneNumber!);

                          FirestoreHelper.pushUser(bloc_user);
                          Logx.i(_TAG, 'registered user ${bloc_user.id}');

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
      url = widget.party.instagramUrl;
    }
    return url;
  }

  _displayPartiesDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            key: const ValueKey('parties_key'),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorStyle: TextStyle(
                    color: Theme.of(context).errorColor, fontSize: 16.0),
                hintText: 'please select party',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: Constants.primary),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Constants.primary, width: 0.0),
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

                    widget.partyGuest = widget.partyGuest.copyWith(partyId: sPartyId);
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

}