import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/parties/party_banner.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/logx.dart';
import '../../widgets/ui/textfield_widget.dart';

class BoxOfficeGuestListScreen extends StatefulWidget {
  String partyGuestId;

  BoxOfficeGuestListScreen({Key? key, required this.partyGuestId})
      : super(key: key);

  @override
  State<BoxOfficeGuestListScreen> createState() =>
      _BoxOfficeGuestListScreenState();
}

class _BoxOfficeGuestListScreenState extends State<BoxOfficeGuestListScreen> {
  static const String _TAG = 'ManagePartyGuestScreen';

  late PartyGuest mPartyGuest;
  var _isPartyGuestLoading = true;

  late Party mParty;
  var _isPartyLoading = true;

  int maxGuestsCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('guest list | confirm')),
      body: _buildBody(context),
    );
  }

  @override
  void initState() {
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
    return _isPartyGuestLoading && _isPartyLoading
        ? const LoadingWidget()
        : ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              PartyBanner(
                party: mParty,
                isClickable: false,
                shouldShowButton: false,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: TextFieldWidget(
                  label: 'name',
                  text: mPartyGuest.name,
                  onChanged: (name) {
                    // nothing to do
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: TextFieldWidget(
                    label: 'email',
                    text: mPartyGuest.email,
                    onChanged: (email) {
                      // nothing to do
                    }),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
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
                                  print('decrement guests count to ' +
                                      mPartyGuest.guestsRemaining.toString());
                                }
                              });
                            },
                          ),
                        ),
                        Container(
                          // color: primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,horizontal: 10
                          ),
                          child: Text(mPartyGuest.guestsRemaining.toString(),
                          style: const TextStyle(fontSize: 22),),
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
                                  Logx.i(
                                      _TAG,
                                      'increment guests count to ' +
                                          mPartyGuest.guestsRemaining
                                              .toString());
                                } else {
                                  Logx.i(
                                      _TAG,
                                      'max guests count of ' +
                                          mPartyGuest.guestsRemaining
                                              .toString());
                                  Toaster.shortToast(
                                      'max limit of guest count is hit');
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
                  text: 'confirm ' +
                      (mPartyGuest.guestsRemaining != 0
                          ? mPartyGuest.guestsRemaining.toString()
                          : maxGuestsCount.toString()) +
                      ' entry',
                  onClicked: () {
                    if (mPartyGuest.guestsRemaining == maxGuestsCount) {
                      // assume that all walked in
                      mPartyGuest.guestsRemaining = 0;
                    }

                    FirestoreHelper.pushPartyGuest(mPartyGuest);
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
  }
}
