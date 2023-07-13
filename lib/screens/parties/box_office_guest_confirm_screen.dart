import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/parties/party_banner.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../db/entity/party.dart';
import '../../db/entity/promoter.dart';
import '../../db/entity/promoter_guest.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/textfield_widget.dart';
import '../../db/entity/user.dart' as blocUser;

class BoxOfficeGuestConfirmScreen extends StatefulWidget {
  String partyGuestId;

  BoxOfficeGuestConfirmScreen({Key? key, required this.partyGuestId})
      : super(key: key);

  @override
  State<BoxOfficeGuestConfirmScreen> createState() =>
      _BoxOfficeGuestConfirmScreenState();
}

class _BoxOfficeGuestConfirmScreenState
    extends State<BoxOfficeGuestConfirmScreen> {
  static const String _TAG = 'BoxOfficeGuestConfirmScreen';

  late PartyGuest mPartyGuest;
  var _isPartyGuestLoading = true;

  late Party mParty;
  var _isPartyLoading = true;

  int maxGuestsCount = 0;

  final TextEditingController _controller = TextEditingController();
  String completePhoneNumber = '';
  int maxPhoneNumberLength = 10;

  late blocUser.User mBlocUser;
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  Promoter mPromoter = Dummy.getDummyPromoter();
  var _isPromoterLoading = true;

  var _isUserRegistered = false;
  var _isUserLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: 'confirm guest'),
        titleSpacing: 0,
      ),
      body: _isPartyLoading && _isPartyGuestLoading && _isPromoterLoading && _isUserLoading
          ? const LoadingWidget()
          : _buildBody(context),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    mPartyGuest = Dummy.getDummyPartyGuest(true);
    mBlocUser = Dummy.getDummyUser();

    FirestoreHelper.pullPartyGuest(widget.partyGuestId).then((res) {
      Logx.i(_TAG, "successfully pulled in party guest");

      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        final PartyGuest partyGuest = Fresh.freshPartyGuestMap(data, false);
        mPartyGuest = partyGuest;

        if (mPartyGuest.guestStatus == 'promoter') {
          FirestoreHelper.pullPromoter(mPartyGuest.promoterId).then((res) {
            if (res.docs.isNotEmpty) {
              DocumentSnapshot document = res.docs[0];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              mPromoter = Fresh.freshPromoterMap(data, false);

              setState(() {
                _isPromoterLoading = false;
              });
            } else {
              setState(() {
                _isPromoterLoading = false;
              });
            }
          });

          FirestoreHelper.pullUserByPhoneNumber(
                  StringUtils.getInt(mPartyGuest.phone))
              .then((res) {
            if (res.docs.isNotEmpty) {
              setState(() {
                _isUserRegistered = true;
                _isUserLoading = false;
              });
            } else {
              setState(() {
                _isUserRegistered = false;
                _isUserLoading = false;
              });
            }
          });
        } else {
          setState(() {
            _isPromoterLoading = false;
            _isUserRegistered = true;
            _isUserLoading = false;
          });
        }

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

            setState(() {
              maxGuestsCount = mPartyGuest.guestsRemaining;
              _isPartyLoading = false;
              _isPartyGuestLoading = false;
            });
          } else {
            Logx.i(_TAG, 'no party found!');
            setState(() {
              _isPartyLoading = false;
              _isPartyGuestLoading = false;
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

    super.initState();
  }

  _buildBody(BuildContext context) {
    return _isPartyGuestLoading &&
            _isPartyLoading &&
            _isPromoterLoading &&
            _isUserLoading
        ? const LoadingWidget()
        : ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              PartyBanner(
                party: mParty,
                isClickable: false,
                shouldShowButton: false,
                isGuestListRequested: true,
                shouldShowInterestCount: false,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: TextFieldWidget(
                  label: 'name',
                  text: '${mPartyGuest.name} ${mPartyGuest.surname}',
                  onChanged: (name) {
                    // nothing to do
                  },
                ),
              ),
              const SizedBox(height: 24),
              mPartyGuest.phone != '0'
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextFieldWidget(
                        label: 'phone',
                        text: mPartyGuest.phone,
                        onChanged: (text) {},
                      ),
                    )
                  : Container(
                      margin:
                          const EdgeInsets.only(top: 0, right: 32, left: 32),
                      child: IntlPhoneField(
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                            labelText: 'phone number',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 0.0),
                            )),
                        controller: _controller,
                        initialCountryCode: 'IN',
                        dropdownTextStyle: const TextStyle(fontSize: 20),
                        onChanged: (phone) async {
                          Logx.i(_TAG, phone.completeNumber);
                          completePhoneNumber = phone.completeNumber;

                          if (phone.number.length == maxPhoneNumberLength) {
                            verifyPhoneNumber(phone.completeNumber);
                          }
                        },
                        onCountryChanged: (country) {
                          Logx.i(_TAG, 'country changed to: ${country.name}');
                          maxPhoneNumberLength = country.maxLength;
                        },
                      ),
                    ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextFieldWidget(
                  label: 'promoter',
                  text: mPromoter.name,
                  onChanged: (text) {},
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'guests remaining ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Ink(
                          decoration: ShapeDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: const CircleBorder(),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.remove),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                if (mPartyGuest.guestsRemaining > 0) {
                                  mPartyGuest.guestsRemaining--;
                                  Logx.d(_TAG,
                                      'decrement guests count to ${mPartyGuest.guestsRemaining}');
                                }
                              });
                            },
                          ),
                        ),
                        Container(
                          // color: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 10),
                          child: Text(
                            mPartyGuest.guestsRemaining.toString(),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: const CircleBorder(),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                if (mPartyGuest.guestsRemaining <
                                    maxGuestsCount) {
                                  mPartyGuest.guestsRemaining++;
                                  Logx.i(_TAG,
                                      'increment guests count to ${mPartyGuest.guestsRemaining}');
                                } else {
                                  Logx.ist(_TAG,
                                      'max guests count of ${mPartyGuest.guestsRemaining} is hit');
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ButtonWidget(
                  text:
                      'confirm ${mPartyGuest.guestsRemaining != 0 ? mPartyGuest.guestsRemaining.toString() : maxGuestsCount.toString()} entry',
                  onClicked: () {
                    if (mPartyGuest.guestsRemaining == maxGuestsCount) {
                      // assume that all walked in
                      mPartyGuest.guestsRemaining = 0;
                    }

                    if (mPartyGuest.guestStatus == 'promoter') {
                      FirestoreHelper.pullPromoterGuest(widget.partyGuestId)
                          .then((res) {
                        if (res.docs.isNotEmpty) {
                          DocumentSnapshot document = res.docs[0];
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          PromoterGuest promoterGuest =
                              Fresh.freshPromoterGuestMap(data, false);
                          promoterGuest =
                              promoterGuest.copyWith(hasAttended: true);
                          FirestoreHelper.pushPromoterGuest(promoterGuest);

                          Logx.i(_TAG,
                              'promoter guest ${promoterGuest.name} has attended');
                        } else {
                          Logx.em(_TAG,
                              'promoter guest could not be found for the party guest id: ${mPartyGuest.id}');
                        }
                      });

                      if (mPartyGuest.phone == '0') {
                        if (completePhoneNumber != '0') {
                          mPartyGuest =
                              mPartyGuest.copyWith(phone: completePhoneNumber);
                        }
                      } else if(mPartyGuest.phone != '0' && !_isUserRegistered) {
                        verifyPhoneNumber('91${mPartyGuest.phone}');
                      }
                    }

                    FirestoreHelper.pushPartyGuest(mPartyGuest);
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
  }

  void verifyPhoneNumber(String sFullNumber) async {
    Logx.ist(_TAG, 'verifying $sFullNumber');

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: sFullNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          Logx.ist(_TAG,
              '$sFullNumber is verified and user is registered in bloc.');
        },
        verificationFailed: (FirebaseAuthException e) {
          Logx.em(_TAG, 'verificationFailed $e');
          Logx.ilt(_TAG, 'verifying $sFullNumber failed with error: $e');

        },
        codeSent: (String verificationID, int? resendToken) {
          Logx.d(_TAG, 'verification id : $verificationID');
          Logx.ist(_TAG, 'code sent to $sFullNumber');

          int number = StringUtils.getInt(sFullNumber);

          mPartyGuest = mPartyGuest.copyWith(
              phone: number.toString());
          FirestoreHelper.pushPartyGuest(mPartyGuest);

          FirestoreHelper.pullUserByPhoneNumber(number)
              .then((res) {
            if (res.docs.isNotEmpty) {
              DocumentSnapshot document = res.docs[0];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              blocUser.User user = Fresh.freshUserMap(data, true);

              if (user.isBanned) {
                Toaster.longToast(
                    'BANNED: ${user.name} ${user.surname} with phone ${user.phoneNumber} has been banned previously!');
              }
            } else {
              Logx.i(_TAG,
                  'user is not already registered in bloc, registering...');

              if (!_isUserRegistered) {
                mBlocUser = mBlocUser.copyWith(
                    id: StringUtils.getRandomString(28),
                    name: mPartyGuest.name,
                    phoneNumber: number);

                FirestoreHelper.pushUser(mBlocUser);
              }

              Logx.i(_TAG,
                  '${mBlocUser.name} is registered with id ${mBlocUser.id}');

              FirestoreHelper.pullPromoterGuest(mPartyGuest.id).then((res) {
                if (res.docs.isNotEmpty) {
                  DocumentSnapshot document = res.docs[0];
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  PromoterGuest promoterGuest =
                      Fresh.freshPromoterGuestMap(data, false);
                  promoterGuest = promoterGuest.copyWith(
                      blocUserId: mBlocUser.id,
                      phone: number.toString(),
                      hasAttended: true);
                  FirestoreHelper.pushPromoterGuest(promoterGuest);
                }
              });
            }
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            setState(() {});
          }
        },
        timeout: const Duration(seconds: 60));
  }
}
