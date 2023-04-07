import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/parties/party_banner.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../widgets/ui/textfield_widget.dart';

class ConfirmGuestListScreen extends StatefulWidget {
  String partyGuestId;

  ConfirmGuestListScreen({required this.partyGuestId});

  @override
  State<ConfirmGuestListScreen> createState() =>
      _ConfirmGuestListScreenState();
}

class _ConfirmGuestListScreenState extends State<ConfirmGuestListScreen> {
  late PartyGuest mPartyGuest;
  var _isPartyGuestLoading = true;

  late Party mParty;
  var _isPartyLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ticket | confirm')),
      body: _buildBody(context),
    );
  }

  @override
  void initState() {
    mPartyGuest = Dummy.getDummyPartyGuest();

    FirestoreHelper.pullPartyGuest(widget.partyGuestId).then((res) {
      print("successfully pulled in party guest");

      if (res.docs.isNotEmpty) {
        PartyGuest partyGuest;
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyGuest partyGuest = Fresh.freshPartyGuestMap(data, false);
          mPartyGuest = partyGuest;
        }

        FirestoreHelper.pullParty(mPartyGuest.partyId).then((res) {
          print("successfully pulled in party");

          if (res.docs.isNotEmpty) {
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              final Party party = Fresh.freshPartyMap(data, true);
              mParty = party;
              // requests.add(partyGuest);
            }

            setState(() {
              _isPartyLoading = false;
              _isPartyGuestLoading = false;
            });
          } else {
            print('no party found!');
            setState(() {
              _isPartyLoading = false;
            });
          }
        });

        // setState(() {
        //   _isPartyGuestLoading = false;
        // });
      } else {
        print('no party guests found!');
        setState(() {
          _isPartyGuestLoading = false;
          _isPartyLoading = false;
        });
      }
    });

    super.initState();
  }

  _buildBody(BuildContext context) {
    return _isPartyGuestLoading && _isPartyLoading ? const LoadingWidget() : ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        PartyBanner(party: mParty, isClickable: false, shouldShowButton: false,),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: TextFieldWidget(
            label: 'name',
            text: mPartyGuest.name,
            onChanged: (name) {

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

              }),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('guests remaining ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (mPartyGuest.guestsRemaining > 0) {
                          mPartyGuest.guestsRemaining--;
                          print('decrement add count to ' +
                              mPartyGuest.guestsRemaining.toString());
                        } else {
                          print('add guest count is at ' +
                              mPartyGuest.guestsRemaining.toString());
                        }
                      });
                    },
                  ),
                  Container(
                    // color: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ),
                      child: ButtonWidget(
                        text: mPartyGuest.guestsRemaining.toString(),
                        onClicked: () {
                          //check if customer is seated
                        },
                      )),
                  // IconButton(
                  //   icon: const Icon(Icons.add),
                  //   onPressed: () {
                  //     setState(() {
                  //       mPartyGuest.guestsCount++;
                  //     });
                  //     print('increment add guest count to ' +
                  //         mPartyGuest.guestsCount.toString());
                  //   },
                  // )
              ],),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ButtonWidget(text: 'confirm', onClicked: () {
            FirestoreHelper.pushPartyGuest(mPartyGuest);
            Navigator.of(context).pop();
          },),
        )

      ],
    );
  }
}
